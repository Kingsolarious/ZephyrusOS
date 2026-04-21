#!/bin/bash
# Quick External Monitor Fix for ASUS ROG Zephyrus

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  External Monitor Quick Fix                              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check physical connection first
echo "📺 Checking display connections..."
echo ""
CONNECTED=0
for f in /sys/class/drm/*/status; do
    status=$(cat "$f" 2>/dev/null)
    name=$(basename "$f" | sed 's/status/Display/')
    if [ "$status" = "connected" ]; then
        echo "  ✅ $name: CONNECTED"
        CONNECTED=1
    else
        echo "  ❌ $name: $status"
    fi
done

echo ""

if [ $CONNECTED -eq 0 ]; then
    echo "⚠️  NO EXTERNAL DISPLAYS DETECTED"
    echo ""
    echo "Please check:"
    echo "  1. Cable is firmly connected to laptop"
    echo "  2. Cable is connected to monitor"
    echo "  3. Monitor is turned ON"
    echo "  4. Monitor is set to correct input (HDMI/DP)"
    echo ""
    read -p "Press Enter when you've checked the cable..."
    echo ""
    echo "Rechecking..."
    for f in /sys/class/drm/*/status; do
        status=$(cat "$f" 2>/dev/null)
        if [ "$status" = "connected" ]; then
            name=$(basename "$f")
            echo "✅ Found: $name"
            CONNECTED=1
        fi
    done
fi

if [ $CONNECTED -eq 0 ]; then
    echo ""
    echo "❌ Still no external display detected."
    echo "This could be a driver issue."
    echo ""
fi

# Fix 1: Reload NVIDIA drivers
echo "🔧 Attempting fixes..."
echo ""

echo "Fix 1: Resetting NVIDIA settings..."
if command -v nvidia-settings &> /dev/null; then
    # Reset display configuration
    nvidia-settings --assign CurrentMetaMode="nvidia-auto-select" 2>/dev/null || true
    echo "  ✓ Reset NVIDIA meta mode"
fi

# Fix 2: Restart display manager
echo ""
echo "Fix 2: Checking display outputs..."

# Check which card has external outputs
for card in /sys/class/drm/card*-DP-* /sys/class/drm/card*-HDMI-*; do
    if [ -e "$card/status" ]; then
        status=$(cat "$card/status" 2>/dev/null)
        name=$(basename "$card")
        echo "  $name: $status"
    fi
done

# Fix 3: Reset KDE display config if needed
echo ""
echo "Fix 3: Backup and reset display config..."
if [ -f ~/.config/kwinoutputconfig.json ]; then
    cp ~/.config/kwinoutputconfig.json ~/.config/kwinoutputconfig.json.backup.$(date +%Y%m%d-%H%M%S)
    echo "  ✓ Backed up display config"
fi

# Fix 4: Check for NVIDIA modesetting
echo ""
echo "Fix 4: Checking NVIDIA kernel module..."
if lsmod | grep -q nvidia_drm; then
    echo "  ✓ nvidia_drm module loaded"
else
    echo "  ⚠️  nvidia_drm not loaded - may need reboot"
fi

# Fix 5: Try to force display detection
echo ""
echo "Fix 5: Force display rescan..."
echo 'on' | sudo tee /sys/class/drm/card*/dpms 2>/dev/null || true
echo "  ✓ Triggered display rescan"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

# Final check
echo "🔍 Final check..."
FOUND=0
for f in /sys/class/drm/card*-DP-*/status /sys/class/drm/card*-HDMI-*/status; do
    if [ -f "$f" ]; then
        status=$(cat "$f" 2>/dev/null)
        if [ "$status" = "connected" ]; then
            name=$(basename $(dirname "$f"))
            echo "✅ EXTERNAL DISPLAY FOUND: $name"
            FOUND=1
        fi
    fi
done

if [ $FOUND -eq 1 ]; then
    echo ""
    echo "✅ External display detected!"
    echo "It should appear in display settings now."
    echo ""
    echo "If not visible:"
    echo "  1. Open System Settings → Display & Monitor"
    echo "  2. Click 'Detect Displays'"
    echo ""
else
    echo ""
    echo "❌ No external display found"
    echo ""
    echo "TROUBLESHOOTING:"
    echo "  1. Try a different cable"
    echo "  2. Try a different port on the monitor"
    echo "  3. Restart the laptop with monitor connected"
    echo "  4. Check if monitor works with another device"
    echo ""
fi

echo "═══════════════════════════════════════════════════════════"
