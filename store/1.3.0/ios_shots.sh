set -u
export PATH=$HOME/flutter-3.47.8/bin:/opt/homebrew/bin:$PATH LC_ALL=en_US.UTF-8
OUT=$HOME/PointerStudioShots/store-1.3.0; mkdir -p "$OUT"
R=$HOME/PointerStudio-release; P=com.dailypointer
[ -d $R/build/ios/iphonesimulator/Runner.app ] || { echo NOAPP; exit 1; }
APP=$R/build/ios/iphonesimulator/Runner.app
labels() { axe describe-ui --udid "$1" 2>/dev/null | python3 -c '
import json,sys
def walk(n):
    if isinstance(n,list):
        for c in n: yield from walk(c)
    elif isinstance(n,dict):
        if n.get("AXLabel"): yield n["AXLabel"], n.get("frame",{})
        for c in n.get("children",[]): yield from walk(c)
for l,f in walk(json.load(sys.stdin)): print(l.replace("\n"," ")[:90], "|", f.get("x"),f.get("y"),f.get("width"),f.get("height"))'; }
tap_prefix() { local u=$1 pre=$2 line x y w h; line=$(labels "$u" | grep -m1 "^$pre") || return 1
  read -r x y w h <<<"$(echo "$line" | awk -F'|' '{print $2}')"; axe tap -x $(python3 -c "print(int($x+$w/2))") -y $(python3 -c "print(int($y+$h/2))") --udid "$u" >/dev/null; }
shot() { xcrun simctl io "$1" screenshot "$OUT/$2.png" >/dev/null 2>&1 && echo "shot $2"; }
for spec in "Store iPhone 6.9|com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max|iphone69" "Store iPad 13|com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB|ipad13"; do
  IFS='|' read -r NAME TYPE TAG <<<"$spec"
  U=$(xcrun simctl list devices | sed -nE "s/^ +$NAME \(([0-9A-F-]+)\).*/\1/p" | head -1)
  [ -n "$U" ] || U=$(xcrun simctl create "$NAME" "$TYPE" com.apple.CoreSimulator.SimRuntime.iOS-27-0)
  xcrun simctl boot "$U" 2>/dev/null; xcrun simctl bootstatus "$U" -b >/dev/null; xcrun simctl terminate "$U" com.apple.Preferences 2>/dev/null
  xcrun simctl status_bar "$U" override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
  xcrun simctl uninstall "$U" $P 2>/dev/null; xcrun simctl install "$U" "$APP"
  C=$(xcrun simctl get_app_container "$U" $P data); PL="$C/Library/Preferences/$P.plist"; mkdir -p "$C/Library/Preferences"
  python3 - "$PL" <<'PY'
import plistlib, sys, os, json
p = sys.argv[1]
d = plistlib.load(open(p, 'rb')) if os.path.exists(p) else {}
d['flutter.pointer_onboarding_completed'] = True
d['flutter.pointer_favorites'] = json.dumps(["zen-1", "dir-1", "con-1", "adv-1"])
d['flutter.pointer_current_pointing_id'] = 'con-1'
plistlib.dump(d, open(p, 'wb'))
PY
  for mode in light dark; do
    xcrun simctl ui "$U" appearance $mode; xcrun simctl terminate "$U" $P 2>/dev/null; xcrun simctl launch "$U" $P >/dev/null; sleep 7
    shot "$U" "${TAG}_${mode}_1_today"
    [ $mode = light ] && labels "$U" > "$OUT/${TAG}_labels_today.txt"
    axe tap --label "Library tab" --wait-timeout 5 --udid "$U" >/dev/null 2>&1; sleep 3; [ "$TAG" = iphone69 ] && axe swipe --start-x 220 --start-y 700 --end-x 220 --end-y 560 --duration 0.6 --udid "$U" >/dev/null 2>&1; sleep 5; shot "$U" "${TAG}_${mode}_2_library"
    axe tap --label "Saved tab" --wait-timeout 5 --udid "$U" >/dev/null 2>&1; sleep 6; shot "$U" "${TAG}_${mode}_3_saved"
    axe tap --label "Library tab" --wait-timeout 5 --udid "$U" >/dev/null 2>&1; sleep 3
    if axe tap --label "Who Am I?. The fundamental inquiry. 1 min." --wait-timeout 5 --udid "$U" >/dev/null 2>&1; then sleep 8; shot "$U" "${TAG}_${mode}_4_inquiry"; else echo "no inquiry row on $TAG"; fi
  done
  xcrun simctl ui "$U" appearance light
done
ls "$OUT"
