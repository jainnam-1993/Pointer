#!/usr/bin/env bash
# Retake every store screenshot set for Here Now and judge it, in one command. Run on the devdesk.
#
#   retake_all.sh <commit> [phase ...] [--publish]
#
# Phases, in order (default: all): build ios play render panel
#   build   sync the lab worker clone (relshots) on the Studio to <commit>, build the iOS simulator app and the debug APK
#   ios     claim Store iPhone 6.9 and Store iPad 13 through lab.sh, seed, shoot (ios_shots.sh)
#   play    claim a phone clone, Store_Tablet7 and Store_Tablet10 through lab.sh, seed, shoot (play_shots.sh)
#   render  copy the shots here, render captioned frames (render_captions.py) and contact sheets
#   panel   run DesignPanel on each of the 5 captioned sets; prints the verdict per set
# --publish  publish only the SHIP sets to the "07 Release" review stream, with the verdict line in the note.
# Exit status: 0 when every set is SHIP, 1 otherwise. Nothing here uploads to a store.
set -euo pipefail
COMMIT=${1:?usage: retake_all.sh <commit> [phase ...] [--publish]}; shift
PUBLISH=0; PHASES=()
for a in "$@"; do if [ "$a" = --publish ]; then PUBLISH=1; else PHASES+=("$a"); fi; done
[ ${#PHASES[@]} -gt 0 ] || PHASES=(build ios play render panel)

HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
LABDIR=$HOME/.claude/skills/MobileDeviceLab/scripts
RA=/workplace/jainnam/AgentResearch/PointerOptimize
SHOTS=$RA/store-1.3.0; CAP=$RA/store-1.3.0-captioned; PANEL=$RA/store-1.3.0-final-panel
DEVICES=(iphone69 ipad13 play_phone play_tablet7 play_tablet10)
W=relshots
log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*"; }
studio() { ssh -o BatchMode=yes studio "$@" 2>&1 | grep -v atuin || true; }
lab() { bash "$LABDIR/bundle.sh" pointer | ssh -o BatchMode=yes studio bash -s -- "$@" 2>&1 | grep -v atuin || true; }
push_scripts() {
  bash "$LABDIR/bundle.sh" pointer > /tmp/retake_lab_bundle.sh
  scp -q /tmp/retake_lab_bundle.sh studio:/tmp/lab_bundle.sh
  scp -q "$HERE/ios_shots.sh" "$HERE/play_shots.sh" studio:/tmp/
}

phase_build() {
  log "build: $COMMIT"
  push_scripts
  lab sync $W overhaul/2026-10 >/dev/null
  studio "bash -lc 'export PATH=\$HOME/flutter-3.47.8/bin:\$PATH JAVA_HOME=/opt/homebrew/opt/openjdk@17 ANDROID_HOME=\$HOME/Library/Android/sdk
    cd ~/PointerStudio-$W && git fetch -q origin && git checkout -q -f $COMMIT && git log --oneline -1
    flutter pub get >/dev/null && (cd ios && pod install >/dev/null 2>&1)
    flutter build ios --simulator --debug >/tmp/retake_ios_build.log 2>&1 && echo ios-build-ok || { echo ios-build-FAIL; tail -5 /tmp/retake_ios_build.log; }
    flutter build apk --debug >/tmp/retake_apk_build.log 2>&1 && echo apk-build-ok || { echo apk-build-FAIL; tail -5 /tmp/retake_apk_build.log; }'"
}

phase_ios() {
  log "ios: claim and shoot"
  push_scripts
  lab claim $W store-iphone | tail -1; lab claim $W store-ipad | tail -1
  studio "rm -f ~/PointerStudioShots/store-1.3.0/*; R=\$HOME/PointerStudio-$W bash /tmp/ios_shots.sh </dev/null" | grep -vE '^shot ' || true
  lab release $W | tail -2
}

phase_play() {
  log "play: claim and shoot"
  push_scripts
  studio "rm -f ~/PointerStudioShots/play_*; bash /tmp/play_shots.sh </dev/null" | grep -E 'claimed|released|fail|no inquiry' || true
}

phase_render() {
  log "render: copy, caption, sheets"
  mkdir -p "$SHOTS" "$CAP"; rm -f "$SHOTS"/*.png "$CAP"/*.png
  scp -q 'studio:PointerStudioShots/store-1.3.0/*.png' 'studio:PointerStudioShots/play_*.png' "$SHOTS/"
  ls "$SHOTS"/*.png | wc -l | xargs echo "raw shots:"
  "$HERE/render_captions.py" "$SHOTS" "$CAP" "$REPO/assets/fonts"
  rm -rf "$PANEL"; mkdir -p "$PANEL"
  uv run --quiet --with pillow -- python -I - "$CAP" "$PANEL" "${DEVICES[@]}" <<'PY'
import glob, os, sys
from PIL import Image
cap, panel, *devs = sys.argv[1:]
for dev in devs:
    os.makedirs(f'{panel}/{dev}', exist_ok=True)
    for mode in ('light', 'dark'):
        fs = sorted(glob.glob(f'{cap}/{dev}_{mode}_*_captioned.png'))
        if not fs:
            print('missing', dev, mode); continue
        th = [Image.open(f).convert('RGB') for f in fs]
        th = [t.resize((int(t.width * 900 / t.height), 900)) for t in th]
        s = Image.new('RGB', (sum(t.width for t in th) + 20 * (len(th) + 1), 940), (128, 128, 128)); x = 20
        for t in th:
            s.paste(t, (x, 20)); x += t.width + 20
        s.save(f'{panel}/{dev}/{dev}_{mode}_sheet.png')
print('sheets ok')
PY
}

phase_panel() {
  log "panel: 5 sets in parallel"
  local ref1="$SHOTS/play_phone_light_1_today.png" ref2="$SHOTS/iphone69_dark_1_today.png" d
  for d in "${DEVICES[@]}"; do
    # LITELLM_API_KEY comes from the zsh profile, as the DesignPanel skill expects.
    ( cd "$REPO" && zsh -c 'source ~/.zshrc >/dev/null 2>&1; "$0" "$1" --intent "$2" --ref "$3" --ref "$4" --no-default-refs' \
        "$LABDIR/design_panel.py" "$PANEL/$d" \
        "Captioned store listing frames for Here Now, a calm meditation app: $d, four frames (Today, Library, Saved, Guided Inquiry), Newsreader caption over the app screenshot on the app's background, light and dark sheets" \
        "$ref1" "$ref2" > "$PANEL/$d/run.log" 2>&1; echo $? > "$PANEL/$d/exit" ) &
  done
  wait
  ALL=0
  for d in "${DEVICES[@]}"; do
    local e v; e=$(cat "$PANEL/$d/exit"); v=$(head -1 "$PANEL/$d/verdict.md" 2>/dev/null | sed 's/^# Design panel: //')
    echo "$d: ${v:-ERROR} (exit $e)"
    [ "$e" = 0 ] || ALL=1
    if [ "$e" = 0 ] && [ $PUBLISH = 1 ]; then
      local line; line=$(grep -m1 -E '^SHIP|hig=' "$PANEL/$d/verdict.md" || echo SHIP)
      mkdir -p "$PANEL/$d/publish"; ln -f "$CAP/${d}_"*_captioned.png "$PANEL/$d/publish/"
      ~/.claude/skills/ReviewFolders/scripts/review_add.sh "07 Release" "Store screenshots $d $COMMIT" "$PANEL/$d/publish" "Panel $line" "$COMMIT" | tail -1
    fi
  done
  return $ALL
}

T0=$(date +%s); RC=0
for p in "${PHASES[@]}"; do
  t=$(date +%s); "phase_$p" || RC=$?; log "$p took $(( $(date +%s) - t )) s"
done
log "total $(( $(date +%s) - T0 )) s, exit $RC"
exit $RC
