set -u
export ANDROID_HOME=$HOME/Library/Android/sdk PATH=$HOME/flutter-3.47.8/bin:$HOME/Library/Android/sdk/platform-tools:$PATH
LAB() { bash /tmp/lab_bundle.sh "$@" </dev/null; }
W=relshots; OUT=$HOME/PointerStudioShots; P=com.dailypointer.test

ser() { local s; for s in $(adb devices | awk '/^emulator-/{print $1}'); do [ "$(adb -s $s emu avd name </dev/null 2>/dev/null | head -1 | tr -d '\r')" = "$1" ] && { echo $s; return; }; done; }
for kind in phone tablet7 tablet10; do
  D=$(LAB claim $W $kind 2>/dev/null | tail -1); [ -n "$D" ] || { echo "claim $kind failed"; continue; }
  TAG=play_$kind; echo "claimed $D for $kind"
  for i in $(seq 1 60); do S=$(ser "$D"); [ -n "$S" ] && [ "$(adb -s $S shell getprop sys.boot_completed </dev/null 2>/dev/null | tr -d '\r')" = 1 ] && break; sleep 5; done
  echo "serial $S"
  adb -s $S uninstall $P </dev/null >/dev/null 2>&1
  LAB install $W "$D" 2>&1 | tail -1
  LAB seed $W "$D" 2>&1 | tail -1
  adb -s $S shell am force-stop $P </dev/null
  adb -s $S exec-out run-as $P cat shared_prefs/FlutterSharedPreferences.xml </dev/null > /tmp/fp.xml
  python3 - /tmp/fp.xml <<'PY'
import sys, xml.etree.ElementTree as ET
p=sys.argv[1]; r=ET.parse(p).getroot()
for k in ('flutter.pointer_favorites','flutter.pointer_current_pointing_id'):
    for e in r.findall(f"*[@name='{k}']"): r.remove(e)
e=ET.SubElement(r,'string',name='flutter.pointer_favorites'); e.text='["zen-1","dir-1","con-1","adv-1","adv-2","zen-2","dir-2","con-2"]'
e=ET.SubElement(r,'string',name='flutter.pointer_current_pointing_id'); e.text='con-1'
open(p,'w').write("<?xml version='1.0' encoding='utf-8' standalone='yes' ?>\n"+ET.tostring(r,encoding='unicode'))
PY
  adb -s $S shell "run-as $P sh -c 'cat > shared_prefs/FlutterSharedPreferences.xml'" < /tmp/fp.xml
  adb -s $S shell settings put global sysui_demo_allowed 1 </dev/null
  for c in "enter" "clock -e hhmm 0941" "battery -e level 100 -e plugged false" "network -e wifi show -e level 4 -e fully true" "network -e mobile hide" "notifications -e visible false"; do adb -s $S shell am broadcast -a com.android.systemui.demo -e command $c </dev/null >/dev/null; done
  for mode in light dark; do
    if [ $mode = dark ]; then adb -s $S shell cmd uimode night yes </dev/null >/dev/null; else adb -s $S shell cmd uimode night no </dev/null >/dev/null; fi
    adb -s $S shell am force-stop $P </dev/null
    c=$(adb -s $S shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER $P </dev/null | tr -d '\r' | tail -1); adb -s $S shell am start -W -n "$c" </dev/null >/dev/null; sleep 12
    LAB screenshot "$D" ${TAG}_${mode}_1_today >/dev/null
    LAB tap $W "$D" "Library tab" >/dev/null 2>&1 && sleep 6 && LAB screenshot "$D" ${TAG}_${mode}_2_library >/dev/null
    LAB tap $W "$D" "Saved tab" >/dev/null 2>&1 && sleep 6 && LAB screenshot "$D" ${TAG}_${mode}_3_saved >/dev/null
    LAB tap $W "$D" "Library tab" >/dev/null 2>&1; sleep 3
    LAB tap $W "$D" "Who Am I?. The fundamental inquiry. 1 min." >/dev/null 2>&1 && sleep 15 && LAB screenshot "$D" ${TAG}_${mode}_4_inquiry >/dev/null || echo "no inquiry row on $TAG"
  done
  adb -s $S shell cmd uimode night no </dev/null >/dev/null; adb -s $S shell am broadcast -a com.android.systemui.demo -e command exit </dev/null >/dev/null
  LAB release $W "$D" | tail -1
done
ls $OUT | grep '^play_'
