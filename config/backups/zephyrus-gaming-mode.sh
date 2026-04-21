#!/bin/bash   

echo 95000000 | sudo tee /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw >/dev/null 2>&1
echo 115000000 | sudo tee /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw >/dev/null 2>&1

DISPLAY=:0 nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" >/dev/null 2>&1

# CPU Governor: performance
for cpu in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor; do
	echo performance > "${cpu}" 2>/dev/null
done

echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct >/dev/null 2>&1 ||:

EXEC "$@"   
