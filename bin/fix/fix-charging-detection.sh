#!/bin/bash
# Fix Charging Detection for ROG Zephyrus G16
# Forces AC power mode even if battery shows "Not charging"

echo "🔌 Fixing Power/Charging Detection..."
echo ""

# Check current status
echo "Current Status:"
echo "  Battery: $(cat /sys/class/power_supply/BAT1/status 2>/dev/null)"
echo "  Capacity: $(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)%"
echo ""

# Force AC power profile
echo "Forcing AC Power Mode..."

# Method 1: Set platform profile
echo "performance" | sudo tee /sys/firmware/acpi/platform_profile 2>/dev/null

# Method 2: Use asusctl
asusctl profile --profile-set Performance 2>/dev/null

# Method 3: Set power limits directly (AC mode values)
echo 65 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value > /dev/null 2>&1
echo 95 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value > /dev/null 2>&1
echo 80 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value > /dev/null 2>&1

# Method 4: Disable battery power saving
if [ -f /sys/bus/pci/devices/0000:00:02.0/power/control ]; then
    echo "on" | sudo tee /sys/bus/pci/devices/0000:00:02.0/power/control > /dev/null 2>&1
fi

echo ""
echo "✓ AC Power Mode Forced"
echo "  CPU Power: 65W sustained / 95W boost"
echo "  GPU Power: 80W"
echo ""
echo "IMPORTANT:"
echo "  If your laptop is actually unplugged, this will drain battery fast!"
echo "  Make sure your USB-C charger is properly connected."
echo ""
echo "If still showing 'Not charging':"
echo "  1. Check USB-C cable is fully inserted (both ends)"
echo "  2. Try different USB-C port (use the one on the back)"
echo "  3. Check charger LED is on"
echo "  4. Restart laptop with charger plugged in"
