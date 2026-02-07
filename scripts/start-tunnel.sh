#!/bin/bash
# Start ADB tunnel from Mac to dev desktop
# Usage: ./scripts/start-tunnel.sh
#
# Prerequisites:
#   - Android emulator or physical device connected on Mac
#   - ADB available at /opt/homebrew/bin/adb
#
# For emulators: port 5555 is already mapped by qemu — no tcpip switch needed.
# For physical devices: switches to TCP mode first.
# Creates a reverse SSH tunnel so the dev desktop can reach the device at localhost:5555.

set -euo pipefail

DEVDESK="dev-dsk-jainnam-2a-70f1af09.us-west-2.amazon.com"
ADB="/opt/homebrew/bin/adb"
PORT=5555

# Verify a device is connected (emulator or physical)
if ! "$ADB" devices 2>/dev/null | grep -q "device$"; then
    echo "Error: No device detected. Connect a device or start an emulator first."
    exit 1
fi

# Detect device type
DEVICE_ID=$("$ADB" devices | grep "device$" | head -1 | awk '{print $1}')

if [[ "$DEVICE_ID" == emulator-* ]]; then
    echo "Emulator detected ($DEVICE_ID) — port $PORT already mapped by qemu."
else
    echo "Physical device detected ($DEVICE_ID) — switching to TCP mode on port $PORT..."
    "$ADB" tcpip "$PORT"
    sleep 3
fi

# Verify port 5555 is reachable locally before opening tunnel
if ! nc -z 127.0.0.1 "$PORT" 2>/dev/null; then
    echo "Error: localhost:$PORT not reachable. Device ADB daemon may not be ready."
    exit 1
fi

echo "Starting reverse SSH tunnel ($PORT -> devdesk)..."
echo "Keep this terminal open. Ctrl+C to stop."
echo ""
echo "On devdesk, run:"
echo "  adb connect localhost:$PORT"
echo "  flutter devices"
ssh -R "$PORT":127.0.0.1:"$PORT" -N "$DEVDESK"
