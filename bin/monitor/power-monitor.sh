#!/bin/bash
# Real-time Power & Performance Monitor
# Shows if you're getting full AC power or throttled

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     ⚡ POWER & PERFORMANCE MONITOR                       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

while true; do
    # Move cursor up
    tput cuu 15 2>/dev/null
    
    # Power limits
    pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
    pl2=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value 2>/dev/null)
    gpu_tgp=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value 2>/dev/null)
    
    # Temps
    cpu_temp=0
    for zone in /sys/class/thermal/thermal_zone*; do
        type=$(cat $zone/type 2>/dev/null)
        if [[ "$type" == *"x86_pkg_temp"* ]] || [[ "$type" == *"TCPU"* ]]; then
            temp=$(cat $zone/temp 2>/dev/null)
            cpu_temp=$((temp / 1000))
            break
        fi
    done
    
    # Power status
    if [ "$pl1" -ge 60 ]; then
        power_status="${GREEN}✓ AC POWER${NC}"
        power_mode="Gaming Performance"
    elif [ "$pl1" -ge 45 ]; then
        power_status="${YELLOW}~ Balanced${NC}"
        power_mode="Moderate Performance"
    else
        power_status="${RED}✗ BATTERY MODE${NC}"
        power_mode="Throttled Performance"
    fi
    
    # Display
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  Power Status:  %b\n" "$power_status"
    printf "  Mode:          %s\n" "$power_mode"
    echo ""
    printf "  CPU Power:     ${YELLOW}%2dW${NC} / ${YELLOW}%2dW${NC} (PL1/PL2)\n" "$pl1" "$pl2"
    printf "  GPU Power:     ${YELLOW}%2dW${NC} TGP\n" "$gpu_tgp"
    echo ""
    printf "  CPU Temp:      ${YELLOW}%2d°C${NC}\n" "$cpu_temp"
    
    if [ "$cpu_temp" -gt 90 ]; then
        echo -e "  ${RED}⚠️  THERMAL THROTTLING LIKELY${NC}"
    elif [ "$cpu_temp" -gt 85 ]; then
        echo -e "  ${YELLOW}⚡ Running Hot${NC}"
    else
        echo -e "  ${GREEN}✓ Good Temperature${NC}"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "  %s (Ctrl+C to exit)\n" "$(date '+%H:%M:%S')"
    
    sleep 2
done
