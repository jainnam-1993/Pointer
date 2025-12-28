#!/bin/bash
# Screenshot Test Runner for Pointer App
#
# Uses Patrol for test logic + ADB for screenshot capture
#
# Usage:
#   ./scripts/screenshot_test.sh              # Run all tests with screenshots
#   ./scripts/screenshot_test.sh --no-screenshots  # Run tests only
#   ./scripts/screenshot_test.sh --list       # List available devices
#
# Screenshots saved to: screenshots/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SCREENSHOT_DIR="$PROJECT_DIR/screenshots"
TEST_FILE="$PROJECT_DIR/integration_test/screenshot_test.dart"
LOG_FILE="$SCREENSHOT_DIR/test_output.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     📸 Pointer Screenshot Test Runner (Patrol + ADB)      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"

# Parse arguments
CAPTURE_SCREENSHOTS=true
DEVICE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --list)
            echo -e "\n${YELLOW}Available devices:${NC}"
            flutter devices
            exit 0
            ;;
        --no-screenshots)
            CAPTURE_SCREENSHOTS=false
            shift
            ;;
        --device|-d)
            DEVICE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Create screenshot directory
mkdir -p "$SCREENSHOT_DIR"
echo -e "\n${GREEN}✓${NC} Screenshot directory: $SCREENSHOT_DIR"

# Check for running emulator/device
echo -e "\n${YELLOW}Checking for connected devices...${NC}"
DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l | tr -d ' ')

if [ "$DEVICES" -eq "0" ]; then
    echo -e "${RED}✗ No devices connected${NC}"
    echo -e "\nStart an emulator with:"
    echo -e "  ${BLUE}flutter emulators --launch <emulator_name>${NC}"
    exit 1
fi

# Get device ID
if [ -z "$DEVICE" ]; then
    DEVICE=$(adb devices | grep -v "List" | grep "device$" | head -1 | awk '{print $1}')
fi

echo -e "${GREEN}✓${NC} Using device: $DEVICE"

# Screenshot capture function
capture_screenshot() {
    local name=$1
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local filename="${name}.png"
    local filepath="$SCREENSHOT_DIR/$filename"

    # Capture via ADB
    adb -s "$DEVICE" exec-out screencap -p > "$filepath" 2>/dev/null

    if [ -f "$filepath" ] && [ -s "$filepath" ]; then
        echo -e "  ${GREEN}✓${NC} Captured: $filename"
    else
        echo -e "  ${RED}✗${NC} Failed: $filename"
        rm -f "$filepath"
    fi
}

# Build command
CMD="flutter test $TEST_FILE -d $DEVICE"

echo -e "\n${YELLOW}Running screenshot tests...${NC}"
echo -e "Command: ${BLUE}$CMD${NC}"
echo -e "Screenshots: ${CYAN}$CAPTURE_SCREENSHOTS${NC}\n"

# Run tests and capture output
if [ "$CAPTURE_SCREENSHOTS" = true ]; then
    echo -e "${CYAN}Monitoring for screenshot markers...${NC}\n"

    # Run test and process output in real-time
    $CMD 2>&1 | while IFS= read -r line; do
        echo "$line"

        # Check for screenshot marker
        if [[ "$line" == *"SCREENSHOT_MARKER:"* ]]; then
            # Extract screenshot name
            SCREENSHOT_NAME=$(echo "$line" | sed 's/.*SCREENSHOT_MARKER: //' | tr -d '[:space:]')
            if [ -n "$SCREENSHOT_NAME" ]; then
                # Small delay to ensure UI is rendered
                sleep 0.3
                capture_screenshot "$SCREENSHOT_NAME"
            fi
        fi
    done | tee "$LOG_FILE"

    TEST_RESULT=${PIPESTATUS[0]}
else
    # Run without screenshot capture
    $CMD 2>&1 | tee "$LOG_FILE"
    TEST_RESULT=${PIPESTATUS[0]}
fi

# Check result
if [ $TEST_RESULT -eq 0 ]; then
    echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ Screenshot tests completed successfully                ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"

    # Count screenshots
    SCREENSHOT_COUNT=$(find "$SCREENSHOT_DIR" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "\nScreenshots captured: ${BLUE}$SCREENSHOT_COUNT${NC}"
    echo -e "Location: ${BLUE}$SCREENSHOT_DIR${NC}"

    # List screenshots
    if [ "$SCREENSHOT_COUNT" -gt 0 ]; then
        echo -e "\n${CYAN}Screenshots:${NC}"
        ls -la "$SCREENSHOT_DIR"/*.png 2>/dev/null | awk '{print "  " $NF}' | xargs -I {} basename {}
    fi

    # Open screenshot directory (macOS)
    if [ "$(uname)" == "Darwin" ]; then
        echo -e "\n${YELLOW}Open screenshots folder? [y/N]${NC}"
        read -r -t 5 response || response="n"
        if [[ "$response" =~ ^[Yy]$ ]]; then
            open "$SCREENSHOT_DIR"
        fi
    fi
else
    echo -e "\n${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ Screenshot tests failed                                ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo -e "\nSee log: ${BLUE}$LOG_FILE${NC}"

    # Show UX gaps detected
    if grep -q "UX GAP DETECTED" "$LOG_FILE" 2>/dev/null; then
        echo -e "\n${YELLOW}UX Gaps Detected:${NC}"
        grep -A 10 "UX GAP DETECTED" "$LOG_FILE" | head -15
    fi

    exit 1
fi
