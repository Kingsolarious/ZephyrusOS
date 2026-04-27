#!/bin/bash
# ASUS ROG Zephyrus G16 - Thermal Optimization Script
# Reduces temperatures while maintaining gaming performance
# Run with sudo for best results
# DEPRECATION NOTICE: supergfxctl references in this script are deprecated.
# NVIDIA driver native power management is preferred.

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ASUS ROG Zephyrus G16 - Thermal Optimization            ║"
echo "║  Target: Lower temps without sacrificing performance      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠ Warning: Not running as root. Some settings may fail.${NC}"
    echo "   For best results, run: sudo ./thermal-optimize.sh"
    echo ""
fi

# ============================================================================
# 1. THERMAL PROFILE SELECTION
# ============================================================================
echo -e "${BLUE}Select Thermal Profile:${NC}"
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
        FAN_PROFILE="performance"
        echo -e "${GREEN}Selected: Gaming Mode${NC}"
        ;;
    2)
        CPU_PL1=45
        CPU_PL2=65
        CPU_PL3=80
        GPU_TGP=60
        GPU_TEMP_TARGET=73
        PROFILE="balanced"
        FAN_PROFILE="balanced"
        echo -e "${GREEN}Selected: Cool Mode${NC}"
        ;;
    3)
        CPU_PL1=35
        CPU_PL2=45
        CPU_PL3=55
        GPU_TGP=50
        GPU_TEMP_TARGET=70
        PROFILE="quiet"
        FAN_PROFILE="quiet"
        echo -e "${GREEN}Selected: Silent Mode${NC}"
        ;;
    4)
        CPU_PL1=80
        CPU_PL2=80
        CPU_PL3=80
        GPU_TGP=70
        GPU_TEMP_TARGET=75
        PROFILE="performance"
        FAN_PROFILE="performance"
        echo -e "${GREEN}Selected: Restore Default${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}Applying thermal settings...${NC}"
echo ""

# ============================================================================
# 2. APPLY CPU POWER LIMITS (Armoury Crate)
# ============================================================================
echo -e "${BLUE}1. Setting CPU Power Limits...${NC}"

ARMOURY_PATH="/sys/class/firmware-attributes/asus-armoury/attributes"

if [ -d "$ARMOURY_PATH" ]; then
    # Set PL1 (Sustained Power Limit)
    if [ -f "$ARMOURY_PATH/ppt_pl1_spl/current_value" ]; then
        echo $CPU_PL1 > "$ARMOURY_PATH/ppt_pl1_spl/current_value" 2>/dev/null && \
            echo -e "  ${GREEN}✓ CPU PL1 (Sustained): ${CPU_PL1}W${NC}" || \
            echo -e "  ${RED}✗ Could not set PL1${NC}"
    fi
    
    # Set PL2 (Boost Power Limit)
    if [ -f "$ARMOURY_PATH/ppt_pl2_sppt/current_value" ]; then
        echo $CPU_PL2 > "$ARMOURY_PATH/ppt_pl2_sppt/current_value" 2>/dev/null && \
            echo -e "  ${GREEN}✓ CPU PL2 (Boost): ${CPU_PL2}W${NC}" || \
            echo -e "  ${RED}✗ Could not set PL2${NC}"
    fi
    
    # Set PL3 (Fast Boost Limit)
    if [ -f "$ARMOURY_PATH/ppt_pl3_fppt/current_value" ]; then
        echo $CPU_PL3 > "$ARMOURY_PATH/ppt_pl3_fppt/current_value" 2>/dev/null && \
            echo -e "  ${GREEN}✓ CPU PL3 (Fast Boost): ${CPU_PL3}W${NC}" || \
            echo -e "  ${YELLOW}⚠ PL3 not available${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠ Armoury Crate attributes not found${NC}"
fi

# ============================================================================
# 3. APPLY GPU POWER LIMITS
# ============================================================================
echo ""
echo -e "${BLUE}2. Setting GPU Power Limits...${NC}"

if [ -d "$ARMOURY_PATH" ]; then
    # Set dGPU TGP
    if [ -f "$ARMOURY_PATH/dgpu_tgp/current_value" ]; then
        echo $GPU_TGP > "$ARMOURY_PATH/dgpu_tgp/current_value" 2>/dev/null && \
            echo -e "  ${GREEN}✓ GPU TGP: ${GPU_TGP}W${NC}" || \
            echo -e "  ${RED}✗ Could not set GPU TGP${NC}"
    fi
    
    # Set NVIDIA Temp Target
    if [ -f "$ARMOURY_PATH/nv_temp_target/current_value" ]; then
        echo $GPU_TEMP_TARGET > "$ARMOURY_PATH/nv_temp_target/current_value" 2>/dev/null && \
            echo -e "  ${GREEN}✓ GPU Temp Target: ${GPU_TEMP_TARGET}°C${NC}" || \
            echo -e "  ${YELLOW}⚠ GPU temp target not available${NC}"
    fi
fi

# Also try nvidia-smi power limits if available
if command -v nvidia-smi &> /dev/null; then
    # Convert TGP to milliwatts for nvidia-smi
    POWER_LIMIT_MW=$((GPU_TGP * 1000))
    nvidia-smi -pl $GPU_TGP 2>/dev/null && \
        echo -e "  ${GREEN}✓ NVIDIA Power Limit: ${GPU_TGP}W${NC}" || \
        echo -e "  ${YELLOW}⚠ nvidia-smi power limit requires sudo${NC}"
fi

# ============================================================================
# 4. SET PLATFORM PROFILE
# ============================================================================
echo ""
echo -e "${BLUE}3. Setting Platform Profile...${NC}"

if command -v asusctl &> /dev/null; then
    asusctl profile --profile-set $PROFILE 2>/dev/null && \
        echo -e "  ${GREEN}✓ Platform Profile: ${PROFILE}${NC}" || \
        echo -e "  ${RED}✗ Could not set platform profile${NC}"
else
    # Try direct sysfs
    if [ -f "/sys/firmware/acpi/platform_profile" ]; then
        echo $PROFILE > /sys/firmware/acpi/platform_profile 2>/dev/null && \
            echo -e "  ${GREEN}✓ Platform Profile: ${PROFILE}${NC}" || \
            echo -e "  ${RED}✗ Could not set platform profile${NC}"
    fi
fi

# ============================================================================
# 5. CONFIGURE FAN CURVES
# ============================================================================
echo ""
echo -e "${BLUE}4. Configuring Fan Curves...${NC}"

if command -v asusctl &> /dev/null; then
    # Enable fan curves
    asusctl fan-curve --enable 2>/dev/null
    
    # Set fan curve profile
    asusctl fan-curve --profile-set $FAN_PROFILE 2>/dev/null && \
        echo -e "  ${GREEN}✓ Fan Curve: ${FAN_PROFILE}${NC}" || \
        echo -e "  ${YELLOW}⚠ Could not set fan curve${NC}"
else
    echo -e "  ${YELLOW}⚠ asusctl not available for fan curves${NC}"
fi

# ============================================================================
# 6. CPU GOVERNOR & THERMAL SETTINGS
# ============================================================================
echo ""
echo -e "${BLUE}5. Optimizing CPU Settings...${NC}"

# Set CPU governor based on profile
if [ "$PROFILE" = "quiet" ]; then
    GOVERNOR="powersave"
else
    GOVERNOR="schedutil"
fi

if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo $GOVERNOR > "$cpu" 2>/dev/null
    done
    echo -e "  ${GREEN}✓ CPU Governor: ${GOVERNOR}${NC}"
fi

# Enable thermal daemon if available
if command -v thermald &> /dev/null; then
    systemctl enable thermald --now 2>/dev/null && \
        echo -e "  ${GREEN}✓ Thermal Daemon: Enabled${NC}" || \
        echo -e "  ${YELLOW}⚠ Could not enable thermald${NC}"
fi

# ============================================================================
# 7. GPU MODE (Hybrid vs Dedicated)
# ============================================================================
echo ""
echo -e "${BLUE}6. GPU Mode Configuration...${NC}"

if command -v supergfxctl &> /dev/null; then
    CURRENT_GPU_MODE=$(supergfxctl --status 2>/dev/null || supergfxctl -g 2>/dev/null)
    echo -e "  Current GPU Mode: ${YELLOW}${CURRENT_GPU_MODE}${NC}"
    
    if [ "$PROFILE" = "quiet" ]; then
        echo -e "  ${YELLOW}💡 Tip: For Silent mode, consider switching to Integrated GPU:${NC}"
        echo "     sudo supergfxctl --mode integrated"
        echo "     (Requires reboot)"
    fi
fi

# ============================================================================
# 8. MONITORING SETUP
# ============================================================================
echo ""
echo -e "${BLUE}7. Creating Monitoring Script...${NC}"

cat > /tmp/thermal-monitor.sh << 'EOF'
#!/bin/bash
# Quick thermal monitoring script

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Thermal Monitor - Press Ctrl+C to exit                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║  Thermal Monitor - $(date '+%H:%M:%S')                              ║"
    echo "╠═══════════════════════════════════════════════════════════╣"
    
    # CPU Temp
    CPU_TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -rn | head -1)
    CPU_TEMP_C=$((CPU_TEMP / 1000))
    printf "║  CPU Temp:    %d°C                                           ║\n" $CPU_TEMP_C
    
    # GPU Temp
    if command -v nvidia-smi &> /dev/null; then
        GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
        GPU_POWER=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader 2>/dev/null | cut -d' ' -f1)
        printf "║  GPU Temp:    %s°C    Power: %sW                              ║\n" "$GPU_TEMP" "$GPU_POWER"
    fi
    
    # Fan Speeds
    FAN1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
    FAN2=$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)
    if [ -n "$FAN1" ]; then
        printf "║  Fan 1:       %s RPM                                        ║\n" "$FAN1"
    fi
    if [ -n "$FAN2" ]; then
        printf "║  Fan 2:       %s RPM                                        ║\n" "$FAN2"
    fi
    
    echo "╚═══════════════════════════════════════════════════════════╝"
    sleep 2
done
EOF

chmod +x /tmp/thermal-monitor.sh
echo -e "  ${GREEN}✓ Monitor script: /tmp/thermal-monitor.sh${NC}"

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  THERMAL OPTIMIZATION COMPLETE!                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Applied Settings:${NC}"
printf "  CPU PL1 (Sustained):    %dW\n" $CPU_PL1
printf "  CPU PL2 (Boost):        %dW\n" $CPU_PL2
printf "  GPU TGP:                %dW\n" $GPU_TGP
printf "  GPU Temp Target:        %d°C\n" $GPU_TEMP_TARGET
printf "  Platform Profile:       %s\n" $PROFILE
printf "  Fan Curve:              %s\n" $FAN_PROFILE
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo "  • Monitor temps:  /tmp/thermal-monitor.sh"
echo "  • GPU modes:      supergfxctl --mode [integrated|hybrid|dedicated]"
echo "  • ASUS profiles:  asusctl profile --profile-set [quiet|balanced|performance]"
echo ""
echo -e "${YELLOW}Note:${NC} Power limits will reset after reboot."
echo "      Run this script again or create a systemd service for persistence."
echo ""

# Show current temps
echo -e "${BLUE}Current Temperatures:${NC}"
echo "--------------------"
for zone in /sys/class/thermal/thermal_zone*; do
    TYPE=$(cat $zone/type 2>/dev/null)
    TEMP=$(cat $zone/temp 2>/dev/null)
    if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ]; then
        TEMP_C=$((TEMP / 1000))
        printf "  %-20s: %d°C\n" "$TYPE" "$TEMP_C"
    fi
done
