#!/bin/bash
# =============================================================================
# DEPRECATED - Use Maestro instead
# =============================================================================
# This script has been replaced by Maestro for cross-platform E2E testing.
#
# Migration guide:
#   Old: ./scripts/ios_test_helper.sh tap 50 50
#   New: maestro test maestro/flows/04_home_interactions.yaml
#
#   Old: ./scripts/ios_test_helper.sh click "Home"
#   New: In YAML: - tapOn: "Home"
#
#   Old: ./scripts/ios_test_helper.sh screenshot output.png
#   New: In YAML: - takeScreenshot: "output"
#
# Run Maestro tests: maestro test maestro/flows/
# =============================================================================
#
# iOS Simulator Test Helper - Screen-size independent testing (LEGACY)
# Uses percentages to calculate tap coordinates via simctl/idb
# Mirrors adb_test_helper.sh functionality for cross-platform testing

set -e

# Get booted simulator UDID
get_simulator_udid() {
    xcrun simctl list devices booted -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for device in devices:
        if device.get('state') == 'Booted':
            print(device.get('udid', ''))
            sys.exit(0)
" 2>/dev/null
}

SIMULATOR_UDID=$(get_simulator_udid)

# Get screen dimensions (defaults for common devices)
get_screen_size() {
    SCREEN_WIDTH=393
    SCREEN_HEIGHT=852
    
    if [ -z "$SIMULATOR_UDID" ]; then
        echo "Warning: No booted simulator, using iPhone 15 defaults"
        return
    fi
    
    local device_name=$(xcrun simctl list devices booted | grep -v "^--" | grep -v "^==" | head -1 | sed 's/^[[:space:]]*//')
    
    case "$device_name" in
        *"iPhone 15 Pro Max"*|*"iPhone 14 Pro Max"*)
            SCREEN_WIDTH=430; SCREEN_HEIGHT=932 ;;
        *"iPhone 15"*|*"iPhone 14"*)
            SCREEN_WIDTH=393; SCREEN_HEIGHT=852 ;;
        *"iPhone SE"*)
            SCREEN_WIDTH=375; SCREEN_HEIGHT=667 ;;
        *"iPad Pro 12.9"*)
            SCREEN_WIDTH=1024; SCREEN_HEIGHT=1366 ;;
        *"iPad Pro 11"*|*"iPad Air"*)
            SCREEN_WIDTH=834; SCREEN_HEIGHT=1194 ;;
    esac
    
    echo "Simulator: $device_name"
    echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT} points"
}

get_screen_size

# Tap at percentage of screen
tap_percent() {
    local x=$((SCREEN_WIDTH * $1 / 100))
    local y=$((SCREEN_HEIGHT * $2 / 100))
    echo "Tapping at ${x},${y} (${1}%,${2}%)"
    
    if command -v idb &> /dev/null && [ -n "$SIMULATOR_UDID" ]; then
        idb ui tap --udid "$SIMULATOR_UDID" $x $y
    else
        echo "Note: For reliable taps, install idb: brew install idb-companion"
    fi
}

# Swipe with percentages
swipe_percent() {
    local x1=$((SCREEN_WIDTH * $1 / 100))
    local y1=$((SCREEN_HEIGHT * $2 / 100))
    local x2=$((SCREEN_WIDTH * $3 / 100))
    local y2=$((SCREEN_HEIGHT * $4 / 100))
    local duration=${5:-300}
    echo "Swiping from ${x1},${y1} to ${x2},${y2}"
    
    if command -v idb &> /dev/null && [ -n "$SIMULATOR_UDID" ]; then
        idb ui swipe --udid "$SIMULATOR_UDID" $x1 $y1 $x2 $y2 --duration $duration
    else
        echo "Note: Swipe requires idb: brew install idb-companion"
    fi
}

# List accessible elements
list_elements() {
    echo "=== Accessibility Elements ==="
    if command -v idb &> /dev/null && [ -n "$SIMULATOR_UDID" ]; then
        idb ui describe-all --udid "$SIMULATOR_UDID" 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    def print_elem(e, indent=0):
        label = e.get('AXLabel', '') or e.get('AXIdentifier', '')
        if label:
            print('  ' * indent + label)
        for c in e.get('children', []):
            print_elem(c, indent + 1)
    print_elem(data)
except: pass
" 2>/dev/null
    else
        echo "Note: Element listing requires idb: brew install idb-companion"
    fi
}

# Find element by accessibility label
find_element() {
    local label="$1"
    if command -v idb &> /dev/null && [ -n "$SIMULATOR_UDID" ]; then
        idb ui describe-all --udid "$SIMULATOR_UDID" 2>/dev/null | python3 -c "
import json, sys
label = '$label'.lower()
def find_e(e):
    ax = (e.get('AXLabel', '') or e.get('AXIdentifier', '') or '').lower()
    if label in ax:
        f = e.get('AXFrame', {})
        x, y = int(f.get('X', 0) + f.get('Width', 0)/2), int(f.get('Y', 0) + f.get('Height', 0)/2)
        print(f'Found: {e.get(\"AXLabel\", \"\")} at {x},{y}')
        return True
    for c in e.get('children', []):
        if find_e(c): return True
    return False
data = json.load(sys.stdin)
if not find_e(data): print('Not found: $label')
" 2>/dev/null
    fi
}

# Tap element by accessibility label
tap_element() {
    local label="$1"
    if command -v idb &> /dev/null && [ -n "$SIMULATOR_UDID" ]; then
        coords=$(idb ui describe-all --udid "$SIMULATOR_UDID" 2>/dev/null | python3 -c "
import json, sys
label = '$label'.lower()
def find_e(e):
    ax = (e.get('AXLabel', '') or e.get('AXIdentifier', '') or '').lower()
    if label in ax:
        f = e.get('AXFrame', {})
        print(int(f.get('X', 0) + f.get('Width', 0)/2), int(f.get('Y', 0) + f.get('Height', 0)/2))
        return True
    for c in e.get('children', []):
        if find_e(c): return True
data = json.load(sys.stdin)
find_e(data)
" 2>/dev/null)
        if [ -n "$coords" ]; then
            x=$(echo "$coords" | awk '{print $1}')
            y=$(echo "$coords" | awk '{print $2}')
            echo "Tapping '$label' at ${x},${y}"
            idb ui tap --udid "$SIMULATOR_UDID" $x $y
        else
            echo "Element not found: $label"
        fi
    else
        echo "Note: Element tapping requires idb: brew install idb-companion"
    fi
}

# Screenshot
screenshot() {
    local output="${1:-screenshot_$(date +%Y%m%d_%H%M%S).png}"
    if [ -n "$SIMULATOR_UDID" ]; then
        xcrun simctl io "$SIMULATOR_UDID" screenshot "$output"
        echo "Screenshot saved: $output"
    else
        echo "Error: No simulator booted"
    fi
}

# Launch app
launch_app() {
    local bundle="${1:-com.dailypointer}"
    if [ -n "$SIMULATOR_UDID" ]; then
        xcrun simctl launch "$SIMULATOR_UDID" "$bundle"
        echo "Launched: $bundle"
    fi
}

# Analyze layout
analyze_layout() {
    echo "=== Layout Analysis ==="
    echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT} points"
    if [ -n "$SIMULATOR_UDID" ]; then
        echo "Simulator: $SIMULATOR_UDID"
    else
        echo "No simulator booted"
    fi
}

# Command router
case "$1" in
    "tap") tap_percent $2 $3 ;;
    "swipe") swipe_percent $2 $3 $4 $5 $6 ;;
    "find") find_element "$2" ;;
    "click"|"tap_element") tap_element "$2" ;;
    "list") list_elements ;;
    "analyze") analyze_layout ;;
    "screenshot") screenshot "$2" ;;
    "launch") launch_app "$2" ;;
    "home") tap_element "Home" ;;
    "library") tap_element "Library" ;;
    "settings") tap_element "Settings" ;;
    "inquiry") tap_element "Inquiry" ;;
    "next") tap_element "Next" ;;
    *)
        echo "iOS Simulator Test Helper"
        echo "========================="
        echo "Mirrors adb_test_helper.sh for cross-platform testing"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  tap X_PCT Y_PCT          - Tap at percentage of screen"
        echo "  swipe X1 Y1 X2 Y2 [MS]   - Swipe between percentages"
        echo "  find 'label'             - Find element by accessibility label"
        echo "  click 'label'            - Tap element by accessibility label"
        echo "  list                     - List all accessible elements"
        echo "  analyze                  - Analyze screen layout"
        echo "  screenshot [file]        - Take screenshot"
        echo "  launch [bundle_id]       - Launch app (default: com.dailypointer)"
        echo "  home|library|settings|inquiry|next - Navigate tabs"
        echo ""
        echo "Dependencies: Xcode, optional: idb (brew install idb-companion)"
        echo ""
        echo "Simulator: ${SIMULATOR_UDID:-'None booted'}"
        echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT} points"
        ;;
esac
