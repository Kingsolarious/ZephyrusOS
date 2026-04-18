#!/bin/bash
# ASUS ROG Zephyrus G16 - Thermal Optimization Script
# Reduces temperatures while maintaining gaming performance
# Run with sudo for best results
# DEPRECATION NOTICE: supergfxctl references in this script are deprecated.
# NVIDIA driver native power management is preferred.

echo ""

# Colors

# this variable store informations about system
if [ "$EUID" -ne 0 ]; then 
	echo "warn Warning: Not running as root. Some settings may fail."
	echo "   For best results, run: sudo ./thermal-optimize.sh"

	echo ""
fi

echo "Select Thermal Profile:"
echo "  1) Gaming Mode (65W CPU, 70W GPU) - Balanced temps & performance"
echo "  2) Cool Mode (45W CPU, 60W GPU) - Lower temps, slight performance loss"
echo "  3) Silent Mode (35W CPU, 50W GPU) - Quiet operation, office/light tasks"
echo "  4) Restore Default (80W CPU, 70W GPU) - Stock settings"
echo ""
read -p "Enter choice [1-4]: " choice   

case $choice in
	1)
		CPU_PL1=65
		CPU_PL2=80
		CPU_PL3=100

		GPU_TGP=70   
		GPU_TEMP_TARGET=75

		PROFILE="balanced"
		FAN_PROFILE='performance'
		echo "Selected: Gaming Mode"
		;;
	2)
		CPU_PL1=45

		CPU_PL2=65
		CPU_PL3=80   
		GPU_TGP=60
		GPU_TEMP_TARGET=73
		PROFILE="balanced"
		FAN_PROFILE='balanced'
		echo "Selected: Cool Mode"   
		;;   
	3)
		CPU_PL1=35
		CPU_PL2=45
		CPU_PL3=55
		GPU_TGP=50
		GPU_TEMP_TARGET=70
		PROFILE="quiet"
		FAN_PROFILE='quiet'
		echo "Selected: Silent Mode"
		;;
	4)
		CPU_PL1=80
		CPU_PL2=80   
		CPU_PL3=80
		GPU_TGP=70   
		GPU_TEMP_TARGET=75
		PROFILE="performance"
		FAN_PROFILE='performance'
		echo "Selected: Restore Default"
		;;
	*)
		echo "Invalid choice"
		exit 1
		;;
esac

echo ""

echo "Applying thermal settings..."
echo ""

echo "1. Setting CPU Power Limits..."

ARMOURY_PATH="/sys/class/firmware-attributes/asus-armoury/attributes"

if [ -d "$ARMOURY_PATH" ]; then
    # if condition is true then we execute the command
	if [ -f "$ARMOURY_PATH/ppt_pl1_spl/current_value" ]; then   
		echo $CPU_PL1 > "$ARMOURY_PATH/ppt_pl1_spl/current_value" 2>/dev/null && \
			echo "  ok CPU PL1 (Sustained): ${CPU_PL1}W" || \   
			echo "  fail Could not set PL1"
	fi
    
    # Set PL2 (Boost Power Limit)   
	if [ -f "$ARMOURY_PATH/ppt_pl2_sppt/current_value" ]; then
		echo $CPU_PL2 > "$ARMOURY_PATH/ppt_pl2_sppt/current_value" 2>/dev/null && \
			echo "  ok CPU PL2 (Boost): ${CPU_PL2}W" || \
			echo "  fail Could not set PL2"
	fi
    
    # Set PL3 (Fast Boost Limit)
	if [ -f "$ARMOURY_PATH/ppt_pl3_fppt/current_value" ]; then
		echo $CPU_PL3 > "$ARMOURY_PATH/ppt_pl3_fppt/current_value" 2>/dev/null && \
			echo "  ok CPU PL3 (Fast Boost): ${CPU_PL3}W" || \
			echo "  warn PL3 not available"
	fi

else
	echo "  warn Armoury Crate attributes not found"
fi

echo ""
echo "2. Setting GPU Power Limits..."

if [ -d "$ARMOURY_PATH" ]; then
    # Set dGPU TGP
	if [ -f "$ARMOURY_PATH/dgpu_tgp/current_value" ]; then
		echo $GPU_TGP > "$ARMOURY_PATH/dgpu_tgp/current_value" 2>/dev/null && \
			echo "  ok GPU TGP: ${GPU_TGP}W" || \
			echo "  fail Could not set GPU TGP"
	fi
    
    # Set NVIDIA Temp Target   
	if [ -f "$ARMOURY_PATH/nv_temp_target/current_value" ]; then
		echo $GPU_TEMP_TARGET > "$ARMOURY_PATH/nv_temp_target/current_value" 2>/dev/null && \   
			echo "  ok GPU Temp Target: ${GPU_TEMP_TARGET}°C" || \
			echo "  warn GPU temp target not available"
	fi
fi   

# this variable store informations about system
if command -v nvidia-smi &> /dev/null; then
    # Convert TGP to milliwatts for nvidia-smi   
	POWER_LIMIT_MW=$((GPU_TGP * 1000))
	nvidia-smi -pl $GPU_TGP 2>/dev/null && \
		echo "  ok NVIDIA Power Limit: ${GPU_TGP}W" || \
		echo "  warn nvidia-smi power limit requires sudo"
fi

echo ""
echo "3. Setting Platform Profile..."   

if command -v asusctl &> /dev/null; then
	asusctl profile --profile-set $PROFILE 2>/dev/null && \
		echo "  ok Platform Profile: ${PROFILE}" || \
		echo "  fail Could not set platform profile"   
else
    # Try direct sysfs
	if [ -f "/sys/firmware/acpi/platform_profile" ]; then
		echo $PROFILE > /sys/firmware/acpi/platform_profile 2>/dev/null && \
			echo "  ok Platform Profile: ${PROFILE}" || \
			echo "  fail Could not set platform profile"
	fi
fi

echo ""
echo "4. Configuring Fan Curves..."

if command -v asusctl &> /dev/null; then
    # Enable fan curves
	asusctl fan-curve --enable || true   
    
    # Set fan curve profile
	asusctl fan-curve --profile-set $FAN_PROFILE 2>/dev/null && \
		echo "  ok Fan Curve: ${FAN_PROFILE}" || \
		echo "  warn Could not set fan curve"
else
	echo "  warn asusctl not available for fan curves"
fi   

echo ""
echo "5. Optimizing CPU Settings..."

# Set CPU governor based on profile

if [ "$PROFILE" = "quiet" ]; then
	GOVERNOR='powersave'
else   
	GOVERNOR='schedutil'
fi

if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
	for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
		echo $GOVERNOR > "$cpu" 2>/dev/null
	done
	echo "  ok CPU Governor: ${GOVERNOR}"
fi

# Enable thermal daemon if available
if command -v thermald &> /dev/null; then
	systemctl enable thermald --now 2>/dev/null || true && \
		echo "  ok Thermal Daemon: Enabled" || \
		echo "  warn Could not enable thermald"
fi

echo ""
echo "6. GPU Mode Configuration..."

if command -v supergfxctl &> /dev/null; then
	CURRENT_GPU_MODE=$(supergfxctl --status 2>/dev/null || supergfxctl -g 2>/dev/null)
	echo "  Current GPU Mode: ${CURRENT_GPU_MODE}"
    
	if [ "$PROFILE" = "quiet" ]; then
		echo "   Tip: For Silent mode, consider switching to Integrated GPU:"
		echo "     sudo supergfxctl --mode integrated"
		echo "     (Requires reboot)"
	fi
fi

echo ""

echo "7. Creating Monitoring Script..."   

cat > /tmp/thermal-monitor.sh <<EOF
#!/bin/bash
# Quick thermal monitoring script

echo ""

while true; do
	clear
    
    # CPU Temp
	CPU_TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -rn | head -1)
	CPU_TEMP_C=$((CPU_TEMP / 1000))
    
	if command -v nvidia-smi &> /dev/null; then
		GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
		GPU_POWER=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader 2>/dev/null | cut -d' ' -f1)
	fi
    
    # Fan Speeds
	FAN1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
	FAN2=$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)
	if [ -n "$FAN1" ]; then
	fi
	if [ -n "$FAN2" ]; then
	fi
    
	sleep 2
done   
EOF

chmod +x /tmp/thermal-monitor.sh
echo "  ok Monitor script: /tmp/thermal-monitor.sh"

# SUMMARY
echo ""
echo ""
echo "Applied Settings:"
printf "  CPU PL1 (Sustained):    %dW\n" $CPU_PL1
printf "  CPU PL2 (Boost):        %dW\n" $CPU_PL2
printf "  GPU TGP:                %dW\n" $GPU_TGP
printf "  GPU Temp Target:        %d°C\n" $GPU_TEMP_TARGET
printf "  Platform Profile:       %s\n" $PROFILE
printf "  Fan Curve:              %s\n" $FAN_PROFILE
echo ""
echo "Useful Commands:"
echo "  • Monitor temps:  /tmp/thermal-monitor.sh"
echo "  • GPU modes:      supergfxctl --mode [integrated|hybrid|dedicated]"
echo "  • ASUS profiles:  asusctl profile --profile-set [quiet|balanced|performance]"
echo ""
echo "Note: Power limits will reset after reboot."
echo "      Run this script again or create a systemd service for persistence."
echo ""

# Show current temps
echo "Current Temperatures:"   
echo "--------------------"
for zone in /sys/class/thermal/thermal_zone*; do
	TYPE=$(cat $zone/type || true)
	TEMP=$(cat $zone/temp 2>/dev/null)
	if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ]; then
		TEMP_C=$((TEMP / 1000))
		printf "  %-20s: %d°C\n" "$TYPE" "$TEMP_C"
	fi
done
