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
    # Use sed to break XML into lines for easier parsing
    bounds=$(adb shell cat /sdcard/ui.xml | sed 's/>/>\n/g' | grep "content-desc=\"$desc" | grep -o 'bounds="\[[0-9,]*\]\[[0-9,]*\]"' | head -1)
    if [ -n "$bounds" ]; then
        echo "$bounds"
        # Extract coordinates: replace ][ with space, clean up
        coords=$(echo "$bounds" | sed 's/\]\[/ /g' | tr -d 'bounds="[]' | tr ',' ' ')
        x1=$(echo "$coords" | awk '{print $1}')
        y1=$(echo "$coords" | awk '{print $2}')
        x2=$(echo "$coords" | awk '{print $3}')
        y2=$(echo "$coords" | awk '{print $4}')
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
    # Use sed to break XML into lines for easier parsing
    bounds=$(adb shell cat /sdcard/ui.xml | sed 's/>/>\n/g' | grep "content-desc=\"$desc" | grep -o 'bounds="\[[0-9,]*\]\[[0-9,]*\]"' | head -1)
    if [ -n "$bounds" ]; then
        # Extract coordinates: replace ][ with space, clean up
        coords=$(echo "$bounds" | sed 's/\]\[/ /g' | tr -d 'bounds="[]' | tr ',' ' ')
        x1=$(echo "$coords" | awk '{print $1}')
        y1=$(echo "$coords" | awk '{print $2}')
        x2=$(echo "$coords" | awk '{print $3}')
        y2=$(echo "$coords" | awk '{print $4}')
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

    # Find the navigation bar position (extract bounds for Home tab)
    # XML is single-line, use sed to extract bounds after Home tab
    nav_bounds=$(adb shell cat /sdcard/ui.xml | sed 's/>/>\n/g' | grep 'Home tab' | grep -o 'bounds="\[[0-9,]*\]\[[0-9,]*\]"' | head -1)
    if [ -n "$nav_bounds" ]; then
        # Extract coordinates: bounds="[x1,y1][x2,y2]"
        # Replace ][ with space to separate coordinate pairs, then clean brackets and commas
        coords=$(echo "$nav_bounds" | sed 's/\]\[/ /g' | tr -d 'bounds="[]' | tr ',' ' ')
        x1=$(echo "$coords" | awk '{print $1}')
        y1=$(echo "$coords" | awk '{print $2}')
        x2=$(echo "$coords" | awk '{print $3}')
        y2=$(echo "$coords" | awk '{print $4}')
        echo "Nav bar bounds: x=${x1}-${x2}, y=${y1}-${y2}"
        echo "Nav bar Y position: ${y1}-${y2}"

        # Calculate usage (content ends at nav bar top)
        content_height=$y1
        nav_height=$((y2 - y1))
        unused_height=$((SCREEN_HEIGHT - y2))
        usage_pct=$((y2 * 100 / SCREEN_HEIGHT))
        echo "Content area: 0-${y1} (${content_height}px)"
        echo "Nav bar: ${y1}-${y2} (${nav_height}px)"
        echo "Unused below nav: ${unused_height}px"
        echo "Screen usage: ${usage_pct}% (${y2}px used)"
    else
        echo "Navigation bar not found in UI hierarchy"
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
