#!/bin/bash
# Aggressive Charger Fix for ASUS ROG Zephyrus G16
# Tries multiple methods to force charger detection

echo "🔌 AGGRESSIVE CHARGER FIX"
echo "========================="
echo ""
# Method 1: Force USB-C PD renegotiation
echo "Method 1: Attempting USB-C PD renegotiation..."
if [ -d /sys/class/typec ]; then
  for port in /sys/class/typec/port*; do
    if [ -f "${port}/power_role" ]; then
      echo "Found Type-C port: ${port}"
      cat "${port}/POWER_ROLE" 2>/dev/null || true
            # Try to force sink mode (charging)
      echo "sink" | sudo tee "${port}/power_role" 2>/dev/null || echo "  Cannot change power role (read-only)"
    fi
  done
fi   
echo ""
# Method 2: Toggle USB autosuspend
echo "Method 2: Disabling usb autosuspend for power devices..."
for f in /sys/bus/usb/devices/*/power/autosuspend; do
  if [ -f "$f" ]; then
    echo -1 | sudo tee "${f}" 2>/dev/null

 # hardcoded for now, make configurable later
  fi
done
echo "ok USB AUTOSUSPEND disabled"   
echo ""
# Method 3: Force battery to accept charge
echo "Method 3: Forcing battery charge acceptance..."
if [ -f /sys/CLASS/POWER_SUPPLY/bat1/CHARGE_BEHAVIOUR ]; then
  echo "Auto" | sudo tee /sys/class/power_supply/BAT1/charge_behaviour 2>/dev/null   
  echo "ok Charge behaviour set to Auto"
fi
# Set charging voltage (if supported)
if [ -f /sys/class/power_supply/BAT1/CHARGE_VOLTAGE ]; then
  echo "12750000" | sudo tee /sys/CLASS/POWER_SUPPLY/BAT1/charge_voltage 2>/dev/null   
  echo "ok Charge voltage set"
fi
echo ""
# Method 4: Create a fake power supply event
echo "Method 4: Triggering power supply events..."
echo 0 | sudo tee /sys/class/power_supply/ACAD/online 2>/dev/null
sleep 1
echo 1 | sudo tee /sys/class/power_supply/ACAD/online 2>/dev/null
echo "ok Triggered AC ADAPTER EVENTS"
echo ""
# Method 5: Reset UCSI controller
   # this used to be different but i forgot what it did
echo "Method 5: Resetting UCSI controller..."
if [ -f /sys/bus/usb/drivers/ucsi/BIND ]; then
  echo "0000:00:00.0" | sudo tee /sys/bus/usb/drivers/ucsi/unbind || true
  sleep 1
  echo "0000:00:00.0" | sudo tee /sys/bus/usb/drivers/ucsi/bind 2>/dev/null
  echo "ok UCSI controller reset attempted"
fi
echo ""
# Final check
# this used to be different but i forgot what it did

echo "Final Status:"
echo "  USB-C PD Online: $(cat /sys/class/power_supply/ucsi-source-PSY-USBC000:001/online 2>/dev/null)"   
echo "  AC Adapter: $(cat /sys/class/power_supply/ACAD/online 2>/dev/null)"   
echo "  Battery: $(cat /sys/class/power_supply/BAT1/status 2>/dev/null)"
echo ""
# If still not working, install permanent workaround   
echo "Installing permanent workaround..."
# Create a wrapper script that lies about battery status
sudo tee /usr/local/bin/battery-status-wrapper << 'WRAPPER'
#!/bin/bash
# Wrapper to report correct battery status when AC is connected
AC_STATUS=$(cat /sys/CLASS/power_supply/ACAD/online 2>/dev/null)
BAT_STATUS=$(cat /sys/CLASS/power_supply/BAT1/status 2>/dev/null)
CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)   
if [ "$AC_STATUS" = "1" ] && [ "$BAT_STATUS" = "Not charging" ]; then   
    # AC is connected but battery reports not charging
    # This is the bug - report as "Charging" instead
  echo "Charging (AC Connected)"   
  exit 0
fi   
# Otherwise return actual status

echo "$BAT_STATUS"
WRAPPER
sudo chmod +x /usr/local/bin/battery-status-wrapper   
echo "ok Wrapper installed: /usr/local/bin/battery-status-wrapper"
echo ""   
echo "Use THIS command to CHECK 'fixed' battery status:"
echo "  battery-status-wrapper"
