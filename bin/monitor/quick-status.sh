#!/bin/bash
# Quick status display for ROG Zephyrus

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        ASUS ROG Zephyrus G16 - Quick Status              ${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Gaming mode state
STATE=$(cat /tmp/gaming-mode-state 2>/dev/null || echo "unknown")
echo -e "Gaming Mode: ${YELLOW}$STATE${NC}"

# Power limits
ARMOURY_PATH="/sys/class/firmware-attributes/asus-armoury/attributes"
if [ -d "$ARMOURY_PATH" ]; then
    PL1=$(cat $ARMOURY_PATH/ppt_pl1_spl/current_value 2>/dev/null)
    PL2=$(cat $ARMOURY_PATH/ppt_pl2_sppt/current_value 2>/dev/null)
    GPU_TGP=$(cat $ARMOURY_PATH/dgpu_tgp/current_value 2>/dev/null)
    echo "Power Limits: CPU PL1=${PL1}W PL2=${PL2}W | GPU=${GPU_TGP}W"
fi
echo ""

# CPU Temperature
echo -e "${BLUE}CPU Temperatures:${NC}"
for zone in TCPU x86_pkg_temp acpitz; do
    for path in /sys/class/thermal/thermal_zone*; do
        type=$(cat $path/type 2>/dev/null)
        if [ "$type" = "$zone" ]; then
            temp=$(cat $path/temp 2>/dev/null)
            temp_c=$((temp / 1000))
            if [ $temp_c -gt 85 ]; then
                echo -e "  $type: ${RED}${temp_c}°C${NC}"
            elif [ $temp_c -gt 70 ]; then
                echo -e "  $type: ${YELLOW}${temp_c}°C${NC}"
            else
                echo -e "  $type: ${GREEN}${temp_c}°C${NC}"
            fi
        fi
    done
done

# GPU Info
if command -v nvidia-smi &> /dev/null; then
    echo ""
    echo -e "${BLUE}NVIDIA RTX 4090:${NC}"
    nvidia-smi --query-gpu=temperature.gpu,power.draw,utilization.gpu,clocks.sm --format=csv,noheader 2>/dev/null | \
    while IFS=',' read -r temp power util clock; do
        temp=$(echo $temp | tr -d ' ')
        if [ "$temp" -gt 80 ]; then
            echo -e "  Temp: ${RED}${temp}°C${NC} | Power:$power | Util:$util | Clock:$clock"
        elif [ "$temp" -gt 65 ]; then
            echo -e "  Temp: ${YELLOW}${temp}°C${NC} | Power:$power | Util:$util | Clock:$clock"
        else
            echo -e "  Temp: ${GREEN}${temp}°C${NC} | Power:$power | Util:$util | Clock:$clock"
        fi
    done
fi

# Fan speeds
echo ""
echo -e "${BLUE}Fan Speeds:${NC}"
FAN1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
FAN2=$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)
[ -n "$FAN1" ] && echo "  Fan 1: $FAN1 RPM"
[ -n "$FAN2" ] && echo "  Fan 2: $FAN2 RPM"

# Battery
echo ""
echo -e "${BLUE}Battery:${NC}"
if [ -f /sys/class/power_supply/BAT0/capacity ]; then
    CAP=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    echo "  $CAP% - $STATUS"
fi

echo ""
echo "Commands: gaming | cool | status | monitor"
