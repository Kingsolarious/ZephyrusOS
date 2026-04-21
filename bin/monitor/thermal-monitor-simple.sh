#!/bin/bash
# Simple thermal monitoring display

clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           ASUS ROG Zephyrus - Thermal Monitor                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to colorize temperature
color_temp() {
    local temp=$1
    if [ $temp -gt 85 ]; then
        echo -e "${RED}${temp}°C${NC}"
    elif [ $temp -gt 70 ]; then
        echo -e "${YELLOW}${temp}°C${NC}"
    else
        echo -e "${GREEN}${temp}°C${NC}"
    fi
}

# Function to colorize fan speed
color_fan() {
    local rpm=$1
    if [ $rpm -gt 6000 ]; then
        echo -e "${RED}${rpm} RPM${NC}"
    elif [ $rpm -gt 4000 ]; then
        echo -e "${YELLOW}${rpm} RPM${NC}"
    else
        echo -e "${GREEN}${rpm} RPM${NC}"
    fi
}

echo "Press Ctrl+C to exit"
echo ""

while true; do
    # Move cursor up to refresh
    tput cuu1 2>/dev/null; tput el 2>/dev/null
    tput cuu1 2>/dev/null; tput el 2>/dev/null
    
    # Get temperatures
    TCPU_TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | grep -E "^8|^9" | head -1)
    if [ -z "$TCPU_TEMP" ]; then
        TCPU_TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -rn | head -1)
    fi
    TCPU_C=$((TCPU_TEMP / 1000))
    
    # GPU Info
    GPU_INFO=""
    if command -v nvidia-smi &> /dev/null; then
        GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
        GPU_POWER=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader 2>/dev/null | cut -d' ' -f1)
        GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
        GPU_INFO="GPU: $(color_temp $GPU_TEMP) | ${GPU_POWER}W | ${GPU_UTIL}%"
    fi
    
    # Fan speeds
    FAN1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
    FAN2=$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)
    
    # Power limits (if available)
    PL1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
    
    # Display
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  CPU: %b" "$(color_temp $TCPU_C)"
    [ -n "$PL1" ] && printf " | PL1: ${PL1}W"
    echo ""
    [ -n "$GPU_INFO" ] && echo "  $GPU_INFO"
    [ -n "$FAN1" ] && printf "  Fan 1: %b" "$(color_fan $FAN1)"
    [ -n "$FAN2" ] && printf "  | Fan 2: %b" "$(color_fan $FAN2)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    sleep 2
done
