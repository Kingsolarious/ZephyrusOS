#!/bin/bash
# Fix Charger Detection for ASUS ROG Zephyrus G16
# Workaround for USB-C PD controller not reporting charging status

echo "🔌 Charger Detection Fix for ROG Zephyrus G16"
echo "=============================================="
echo ""

# Check current status
echo "Current Status:"
echo "  ACPI AC Adapter: $(cat /sys/class/power_supply/ACAD/online 2>/dev/null) (1 = connected)"
echo "  Battery Status: $(cat /sys/class/power_supply/BAT1/status 2>/dev/null)"
echo "  USB-C PD: $(cat /sys/class/power_supply/ucsi-source-psy-USBC000:001/online 2>/dev/null) (0 = not detected)"
echo ""

# The issue: USB-C PD controller reports 0 even when charging
# But ACPI AC adapter correctly reports 1

# Create udev rule to fix detection
echo "Creating udev rule for proper charger detection..."

sudo tee /etc/udev/rules.d/99-asus-charger.rules << 'UDEV'
# ASUS ROG Zephyrus G16 - Fix USB-C charger detection
# Force battery to report charging when AC is connected

# When AC adapter is connected, trigger battery status update
SUBSYSTEM=="power_supply", ATTR{name}=="ACAD", ATTR{online}=="1", RUN+="/bin/sh -c 'echo 1 > /sys/class/power_supply/BAT1/charge_control_end_threshold'"

# Alternative: Monitor USB-C connection
SUBSYSTEM=="power_supply", ATTR{name}=="ucsi-source-psy-USBC000:001", RUN+="/bin/sh -c 'sleep 1 && systemctl restart upower'"
UDEV

# Also create a systemd service to periodically check and fix
echo "Creating systemd service..."

sudo tee /etc/systemd/system/asus-charger-fix.service << 'SYSTEMD'
[Unit]
Description=ASUS Charger Detection Fix
After=systemd-udevd.service upower.service

[Service]
Type=simple
ExecStart=/usr/local/bin/asus-charger-daemon
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SYSTEMD

sudo tee /usr/local/bin/asus-charger-daemon << 'DAEMON'
#!/bin/bash
# Daemon to fix charger detection on ROG Zephyrus

while true; do
    # Check if AC is connected via ACPI
    AC_STATUS=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)
    BAT_STATUS=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null)
    
    # If AC is on but battery shows "Not charging", try to fix
    if [ "$AC_STATUS" = "1" ] && [ "$BAT_STATUS" = "Not charging" ]; then
        # Force refresh power supply subsystem
        systemctl restart upower 2>/dev/null
        
        # Trigger battery update
        echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold 2>/dev/null
        
        logger "ASUS Charger Fix: Triggered battery status update"
    fi
    
    # Check every 10 seconds
    sleep 10
done
DAEMON

sudo chmod +x /usr/local/bin/asus-charger-daemon

echo ""
echo "Installing fix..."
sudo systemctl daemon-reload
sudo systemctl enable asus-charger-fix.service
sudo systemctl start asus-charger-fix.service
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=power_supply

echo ""
echo "✓ Charger detection fix installed!"
echo ""
echo "The daemon will monitor and fix the detection automatically."
echo ""
echo "Manual workaround (run this now):"
echo "  sudo systemctl restart upower"
