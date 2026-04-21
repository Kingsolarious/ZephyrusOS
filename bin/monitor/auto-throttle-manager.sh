#!/bin/bash
# Dynamic Thermal Manager - Automatically adjusts power based on temps
# Prevents thermal throttling by proactively managing power limits

# Configuration
HIGH_TEMP=85      # Start reducing power
CRITICAL_TEMP=90  # Aggressive power reduction
SAFE_TEMP=75      # Return to normal

CHECK_INTERVAL=2  # Check every 2 seconds

# Power profiles
GAMING_PL1=50
GAMING_PL2=70

EMULATION_PL1=40
EMULATION_PL2=55

COOL_PL1=35
COOL_PL2=45

CURRENT_MODE="gaming"
ARMOURY_PATH="/sys/class/firmware-attributes/asus-armoury/attributes"

# Get max CPU temp
get_max_temp() {
    local max_temp=0
    for zone in /sys/class/thermal/thermal_zone*; do
        local type=$(cat "$zone/type" 2>/dev/null)
        if [[ "$type" == *"x86_pkg_temp"* ]] || [[ "$type" == *"TCPU"* ]] || [[ "$type" == *"acpitz"* ]]; then
            local temp=$(cat "$zone/temp" 2>/dev/null)
            local temp_c=$((temp / 1000))
            if [ "$temp_c" -gt "$max_temp" ]; then
                max_temp=$temp_c
            fi
        fi
    done
    echo $max_temp
}

# Set power limit
set_power() {
    local pl1=$1
    local pl2=$2
    
    echo "$pl1" | sudo tee "$ARMOURY_PATH/ppt_pl1_spl/current_value" > /dev/null 2>&1
    echo "$pl2" | sudo tee "$ARMOURY_PATH/ppt_pl2_sppt/current_value" > /dev/null 2>&1
}

# Main loop
echo "Dynamic Thermal Manager Started"
echo "High temp threshold: ${HIGH_TEMP}°C"
echo "Critical threshold: ${CRITICAL_TEMP}°C"
echo ""

while true; do
    MAX_TEMP=$(get_max_temp)
    
    # Dynamic power management
    if [ "$MAX_TEMP" -ge "$CRITICAL_TEMP" ]; then
        # Critical - emergency cool down
        if [ "$CURRENT_MODE" != "critical" ]; then
            echo "$(date '+%H:%M:%S') - CRITICAL: ${MAX_TEMP}°C → Emergency cooling (35W)"
            set_power $COOL_PL1 $COOL_PL2
            sudo asusctl fan-curve --profile-set performance 2>/dev/null
            CURRENT_MODE="critical"
        fi
        
    elif [ "$MAX_TEMP" -ge "$HIGH_TEMP" ]; then
        # High temp - reduce power
        if [ "$CURRENT_MODE" != "high" ]; then
            echo "$(date '+%H:%M:%S') - HIGH: ${MAX_TEMP}°C → Reducing power (40W)"
            set_power $EMULATION_PL1 $EMULATION_PL2
            CURRENT_MODE="high"
        fi
        
    elif [ "$MAX_TEMP" -le "$SAFE_TEMP" ] && [ "$CURRENT_MODE" != "gaming" ]; then
        # Safe temp - restore performance
        echo "$(date '+%H:%M:%S') - SAFE: ${MAX_TEMP}°C → Restoring performance (50W)"
        set_power $GAMING_PL1 $GAMING_PL2
        CURRENT_MODE="gaming"
    fi
    
    sleep $CHECK_INTERVAL
done
