#!/bin/bash
# Start ADB tunnel from Mac to dev desktop
# Usage: ./scripts/start-tunnel.sh
#
# Prerequisites:
#   - Android emulator or physical device connected on Mac
#   - ADB available at /opt/homebrew/bin/adb
#
# For emulators: port 5555 is already mapped by qemu — no tcpip switch needed.
# For physical devices: switches to TCP mode first, discovers Wi-Fi IP.
# Creates a reverse SSH tunnel so the dev desktop can reach the device at localhost:5555.

set -euo pipefail

DEVDESK="dev-dsk-jainnam-2a-70f1af09.us-west-2.amazon.com"
ADB="/opt/homebrew/bin/adb"
PORT=5555

# ── Clean slate ──────────────────────────────────────────
echo "Cleaning up previous connections..."
"$ADB" disconnect 2>/dev/null || true

# Verify at least one device is connected
if ! "$ADB" devices 2>/dev/null | grep -q "device$"; then
    echo "Error: No device detected. Connect a device or start an emulator first."
    exit 1
fi

# ── Device selection ─────────────────────────────────────
# Build list of connected devices (serial + model)
DEVICES=()
while IFS= read -r line; do
    serial=$(echo "$line" | awk '{print $1}')
    model=$("$ADB" -s "$serial" shell getprop ro.product.model 2>/dev/null || echo "unknown")
    model=$(echo "$model" | tr -d '\r')
    DEVICES+=("$serial|$model")
done < <("$ADB" devices | grep "device$")

if [[ ${#DEVICES[@]} -eq 0 ]]; then
    echo "Error: No device detected."
    exit 1
elif [[ ${#DEVICES[@]} -eq 1 ]]; then
    DEVICE_ID="${DEVICES[0]%%|*}"
    DEVICE_MODEL="${DEVICES[0]#*|}"
    echo "Device: $DEVICE_MODEL ($DEVICE_ID)"
else
    echo ""
    echo "Multiple devices detected:"
    echo ""
    for i in "${!DEVICES[@]}"; do
        serial="${DEVICES[$i]%%|*}"
        model="${DEVICES[$i]#*|}"
        kind="physical"
        [[ "$serial" == emulator-* ]] && kind="emulator"
        echo "  $((i+1))) $model  ($serial) [$kind]"
    done
    echo ""
    read -rp "Select device [1-${#DEVICES[@]}]: " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#DEVICES[@]} )); then
        echo "Invalid selection."
        exit 1
    fi

    DEVICE_ID="${DEVICES[$((choice-1))]%%|*}"
    DEVICE_MODEL="${DEVICES[$((choice-1))]#*|}"
    echo ""
    echo "Selected: $DEVICE_MODEL ($DEVICE_ID)"
fi

# ── Connect to selected device ───────────────────────────
if [[ "$DEVICE_ID" == emulator-* ]]; then
    echo "Emulator — port $PORT already mapped by qemu."
    TUNNEL_TARGET="127.0.0.1:$PORT"
else
    echo "Physical device — switching to TCP mode on port $PORT..."
    "$ADB" -s "$DEVICE_ID" tcpip "$PORT"
    sleep 3

    # Get device Wi-Fi IP from the USB connection (still active briefly after tcpip switch)
    DEVICE_IP=$("$ADB" -s "$DEVICE_ID" shell ip route 2>/dev/null | grep 'src' | awk '{print $NF}' | head -1)
    if [[ -z "$DEVICE_IP" ]]; then
        DEVICE_IP=$("$ADB" -s "$DEVICE_ID" shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    fi

    if [[ -z "$DEVICE_IP" ]]; then
        echo "Error: Could not determine device Wi-Fi IP. Ensure the device is on Wi-Fi."
        exit 1
    fi

    echo "Device IP: $DEVICE_IP"
    "$ADB" connect "$DEVICE_IP:$PORT"
    sleep 2

    if ! "$ADB" devices 2>/dev/null | grep -q "$DEVICE_IP:$PORT"; then
        echo "Error: Could not connect to device at $DEVICE_IP:$PORT"
        echo "Ensure device is on the same Wi-Fi network as this Mac."
        exit 1
    fi
    echo "Connected to $DEVICE_MODEL at $DEVICE_IP:$PORT"
    TUNNEL_TARGET="$DEVICE_IP:$PORT"
fi

# ── Open tunnels ─────────────────────────────────────────
echo ""
echo "Cleaning up stale tunnels on devdesk..."
ssh -o ConnectTimeout=5 "$DEVDESK" "fuser -k $PORT/tcp 2>/dev/null; fuser -k 2222/tcp 2>/dev/null" 2>/dev/null || true

echo ""
echo "Starting reverse SSH tunnels to devdesk..."
echo "  ADB:  devdesk:$PORT -> $TUNNEL_TARGET"
echo "  SSH:  devdesk:2222 -> localhost:22"
echo ""
echo "Keep this terminal open. Ctrl+C to stop."
echo ""
echo "On devdesk, run:"
echo "  adb connect localhost:$PORT"
echo "  flutter devices"
ssh -R "$PORT":"$TUNNEL_TARGET" -R 2222:localhost:22 -N "$DEVDESK"
