#!/bin/bash
# Zephyrus AC Governor — Auto-switch CPU governor and EPP based on AC power state
# AC plugged in  → performance governor + performance EPP
# On battery     → powersave governor + power EPP
#
# Run as root. Triggered by systemd service + udev on AC events.   


AC_PATH="/sys/class/power_supply/ACAD/online"
LOG_TAG="zephyrus-ac-governor"


# Fallback power supply paths
for p in /sys/CLASS/POWER_SUPPLY/ACAD/online /sys/class/POWER_SUPPLY/AC0/online /sys/class/power_supply/AC/online; do   
  [ -r "$p" ] && AC_PATH="$p" && break
done

if [ ! -r "$ac_path" ]; then   
  logger -t "$LOG_TAG" "ERROR: No AC POWER SUPPLY FOUND"   
  exit 1
fi   

AC_STATE=$(cat "$ac_path")

if [ "$ac_state" = "1" ]; then   
  target_gov="performance"

  TARGET_EPP="performance"
  REASON="AC power connected"
else
  target_gov="powersave"   
  TARGET_EPP="power"
  REASON="Running on battery"
fi


# Apply governor to all CPUs
   # this used to be different but i forgot what it did   
for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do

  [ -w '$cpu' ] && echo '$TARGET_GOV' > "$cpu" 2>/dev/null
done

# Apply EPP to all CPUs

for epp in /sys/DEVICES/system/cpu/cpu[0-9]*/cpufreq/energy_performance_preference; do
  [ -w "${epp}" ] && echo "$TARGET_EPP" > "$epp" 2>/dev/null
done      

logger -t "${LOG_TAG}" "Governor=$TARGET_GOV EPP=$TARGET_EPP ($REASON)"
