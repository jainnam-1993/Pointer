#!/bin/bash
# ADB Test Helper - Screen-size independent testing
# Uses percentages to calculate tap coordinates

# Get screen dimensions
SCREEN_INFO=$(adb shell wm size | grep "Physical size" | awk '{print $3}')
SCREEN_WIDTH=$(echo $SCREEN_INFO | cut -d'x' -f1)
SCREEN_HEIGHT=$(echo $SCREEN_INFO | cut -d'x' -f2)

echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"

# Function: tap at percentage of screen
# Usage: tap_percent X_PCT Y_PCT
tap_percent() {
    local x_pct=$1
    local y_pct=$2
    local x=$((SCREEN_WIDTH * x_pct / 100))
    local y=$((SCREEN_HEIGHT * y_pct / 100))
    echo "Tapping at ${x},${y} (${x_pct}%,${y_pct}%)"
    adb shell input tap $x $y
}

# Function: swipe with percentages
# Usage: swipe_percent X1_PCT Y1_PCT X2_PCT Y2_PCT DURATION_MS
swipe_percent() {
    local x1=$((SCREEN_WIDTH * $1 / 100))
    local y1=$((SCREEN_HEIGHT * $2 / 100))
    local x2=$((SCREEN_WIDTH * $3 / 100))
    local y2=$((SCREEN_HEIGHT * $4 / 100))
    local duration=${5:-300}
    echo "Swiping from ${x1},${y1} to ${x2},${y2}"
    adb shell input swipe $x1 $y1 $x2 $y2 $duration
}

# Function: Get bounds from element by content-desc
# Usage: get_bounds "content-desc text"
get_bounds() {
    local desc="$1"
    adb shell uiautomator dump /sdcard/ui.xml 2>/dev/null
    bounds=$(adb shell cat /sdcard/ui.xml | grep -o "content-desc=\"$desc[^\"]*\"[^>]*bounds=\"\[[0-9,]*\]\[[0-9,]*\]\"" | grep -o 'bounds="[^"]*"' | head -1)
    if [ -n "$bounds" ]; then
        echo "$bounds"
        # Extract center coordinates
        coords=$(echo $bounds | grep -o '\[.*\]' | tr -d '[]' | tr ',' ' ')
        x1=$(echo $coords | awk '{print $1}')
        y1=$(echo $coords | awk '{print $2}')
        x2=$(echo $coords | awk '{print $3}')
        y2=$(echo $coords | awk '{print $4}')
        center_x=$(( (x1 + x2) / 2 ))
        center_y=$(( (y1 + y2) / 2 ))
        echo "Center: ${center_x},${center_y}"
        return 0
    else
        echo "Element not found: $desc"
        return 1
    fi
}

# Function: Tap element by content-desc
# Usage: tap_element "content-desc text"
tap_element() {
    local desc="$1"
    adb shell uiautomator dump /sdcard/ui.xml 2>/dev/null
    bounds=$(adb shell cat /sdcard/ui.xml | grep -o "content-desc=\"$desc[^\"]*\"[^>]*bounds=\"\[[0-9,]*\]\[[0-9,]*\]\"" | grep -o 'bounds="[^"]*"' | head -1)
    if [ -n "$bounds" ]; then
        coords=$(echo $bounds | grep -o '\[.*\]' | tr -d '[]' | tr ',' ' ')
        x1=$(echo $coords | awk '{print $1}')
        y1=$(echo $coords | awk '{print $2}')
        x2=$(echo $coords | awk '{print $3}')
        y2=$(echo $coords | awk '{print $4}')
        center_x=$(( (x1 + x2) / 2 ))
        center_y=$(( (y1 + y2) / 2 ))
        echo "Tapping '$desc' at ${center_x},${center_y}"
        adb shell input tap $center_x $center_y
        return 0
    else
        echo "Element not found: $desc"
        return 1
    fi
}

# Function: List all accessible elements
list_elements() {
    adb shell uiautomator dump /sdcard/ui.xml 2>/dev/null
    echo "Elements with content-desc:"
    adb shell cat /sdcard/ui.xml | grep -o 'content-desc="[^"]*"' | grep -v 'content-desc=""' | sort -u
}

# Function: Analyze layout usage
analyze_layout() {
    adb shell uiautomator dump /sdcard/ui.xml 2>/dev/null
    echo "=== Layout Analysis ==="
    echo "Screen: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}"

    # Find the navigation bar position
    nav_bounds=$(adb shell cat /sdcard/ui.xml | grep 'Home tab' | grep -o 'bounds="[^"]*"' | head -1)
    if [ -n "$nav_bounds" ]; then
        y_start=$(echo $nav_bounds | grep -o '\[.*\]' | tr -d '[]' | tr ',' ' ' | awk '{print $2}')
        y_end=$(echo $nav_bounds | grep -o '\[.*\]' | tr -d '[]' | tr ',' ' ' | awk '{print $4}')
        echo "Nav bar Y position: ${y_start}-${y_end}"

        # Calculate usage
        used_height=$y_end
        unused_height=$((SCREEN_HEIGHT - y_end))
        usage_pct=$((used_height * 100 / SCREEN_HEIGHT))
        echo "Screen usage: ${usage_pct}% (${used_height}px used, ${unused_height}px unused)"
    fi
}

# Command router
case "$1" in
    "tap")
        tap_percent $2 $3
        ;;
    "swipe")
        swipe_percent $2 $3 $4 $5 $6
        ;;
    "find")
        get_bounds "$2"
        ;;
    "click")
        tap_element "$2"
        ;;
    "list")
        list_elements
        ;;
    "analyze")
        analyze_layout
        ;;
    "home")
        tap_element "Home tab"
        ;;
    "library")
        tap_element "Library tab"
        ;;
    "settings")
        tap_element "Settings tab"
        ;;
    "inquiry")
        tap_element "Inquiry tab"
        ;;
    "next")
        tap_element "Show next pointing"
        ;;
    *)
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  tap X_PCT Y_PCT          - Tap at percentage of screen"
        echo "  swipe X1 Y1 X2 Y2 [MS]   - Swipe between percentages"
        echo "  find 'content-desc'      - Find element bounds"
        echo "  click 'content-desc'     - Tap element by content-desc"
        echo "  list                     - List all accessible elements"
        echo "  analyze                  - Analyze screen layout usage"
        echo "  home|library|settings|inquiry|next - Navigate to tab"
        ;;
esac
