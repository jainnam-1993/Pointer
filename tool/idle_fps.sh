#!/usr/bin/env bash
# Count the frames the running app's Flutter SurfaceView presents over a window,
# using SurfaceFlinger timestats (works on non-debuggable profile/release builds).
#
# Usage: tool/idle_fps.sh [seconds=10] [package=com.dailypointer] [adb serial]
# Launch the app and let it sit on the screen to measure first, for example:
#   adb shell am start -n com.dailypointer/.MainActivity; sleep 15; tool/idle_fps.sh
# Prints: frames=<N> seconds=<S> fps=<N/S>
#
# Why not the integration test: under LiveTestWidgetsFlutterBinding every frame
# schedules the next one (flutter_test binding.dart handleDrawFrame), so any app
# reads at the vsync rate there. gfxinfo does not see Flutter's SurfaceView.
set -euo pipefail
secs="${1:-10}"
pkg="${2:-com.dailypointer}"
adb=(adb)
[ -n "${3:-}" ] && adb=(adb -s "$3")

sf() { "${adb[@]}" shell dumpsys SurfaceFlinger --timestats "$@" </dev/null; }

sf -disable >/dev/null
sf -clear >/dev/null
sf -enable >/dev/null
sleep "$secs"
dump="$(sf -dump)"
sf -disable >/dev/null
sf -clear >/dev/null

frames="$(printf '%s\n' "$dump" | awk -v pkg="$pkg" '
  /layerName/ { want = ($0 ~ "SurfaceView" && index($0, pkg) > 0) }
  want && /totalFrames/ { gsub(/[^0-9]/, "", $0); total += $0; want = 0 }
  END { print total + 0 }')"

awk -v f="$frames" -v s="$secs" 'BEGIN { printf "frames=%d seconds=%d fps=%.1f\n", f, s, f / s }'
