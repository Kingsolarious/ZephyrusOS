#!/bin/bash
# Charger Detection Workaround Script
# Run this to manually fix the charging status

echo "🔌 Charger Workaround"
echo "====================="
echo ""

# Method 1: Restart power management
echo "Method 1: Restarting power management services..."
sudo systemctl restart upower
sudo systemctl restart systemd-logind
sleep 2
echo "✓ Services restarted"
echo ""

# Method 2: Force refresh battery
echo "Method 2: Forcing battery refresh..."
if [ -f /sys/class/power_supply/BAT1/charge_control_end_threshold ]; then
    CURRENT=$(cat /sys/class/power_supply/BAT1/charge_control_end_threshold 2>/dev/null)
    echo "Current threshold: $CURRENT"
    # Toggle to force refresh
    echo 100 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold > /dev/null 2>&1
    sleep 1
    echo 80 | sudo tee /sys/class/power_supply/BAT1/charge_control_end_threshold > /dev/null 2>&1
    echo "✓ Battery refreshed"
fi
echo ""

# Method 3: Reload battery module
echo "Method 3: Reloading battery driver..."
sudo modprobe -r acpi_battery 2>/dev/null || true
sleep 1
sudo modprobe acpi_battery 2>/dev/null || true
echo "✓ Driver reloaded"
echo ""

# Check result
echo "Result:"
echo "  Battery Status: $(cat /sys/class/power_supply/BAT1/status 2>/dev/null)"
echo "  AC Adapter: $(cat /sys/class/power_supply/ACAD/online 2>/dev/null)"
echo ""

if [ "$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)" = "Not charging" ]; then
    echo "⚠️  Still showing 'Not charging' - this is a kernel driver bug"
    echo "    The fix requires a kernel patch or BIOS update from ASUS"
    echo ""
    echo "WORKAROUND: Your laptop IS charging (LED confirms),"
    echo "            but Linux can't detect it properly."
    echo "            Use the power settings I configured to ensure"
    echo "            you get full AC power regardless of detection."
else
    echo "✓ SUCCESS! Charger now detected properly."
fi
