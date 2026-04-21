#!/bin/bash
# ASUS ROG Zephyrus - Smart Thermal Daemon
# Automatically adjusts power limits based on workload
# Run with sudo

THERMAL_STATE_FILE="/var/run/thermal-daemon-state"
LOG_FILE="/var/log/thermal-daemon.log"

# Configuration
GAMING_PL1=65
GAMING_PL2=80
GAMING_GPU_TGP=70

BALANCED_PL1=45
BALANCED_PL2=65
BALANCED_GPU_TGP=60

IDLE_PL1=35
IDLE_PL2=45
IDLE_GPU_TGP=50

# Thresholds
GAMING_CPU_THRESHOLD=30    # CPU usage % to trigger gaming mode
IDLE_CPU_THRESHOLD=10      # CPU usage % to trigger idle mode
GAMING_GPU_THRESHOLD=50    # GPU usage % to trigger gaming mode

check_gpu_processes() {
    # Check for common gaming processes
    local gaming_apps="steam|gamescope|cs2|dota2|valorant|apex|cod|minecraft|firefox.*gpu"
    pgrep -iE "$gaming_apps" > /dev/null 2>&1 && return 0
    return 1
}

check_gpu_load() {
    if command -v nvidia-smi &> /dev/null; then
        local gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
        if [ -n "$gpu_util" ] && [ "$gpu_util" -gt "$GAMING_GPU_THRESHOLD" ]; then
            return 0
        fi
    fi
    return 1
}

get_cpu_usage() {
    # Get average CPU usage over 1 second
    local stat1=$(cat /proc/stat | grep '^cpu ' | awk '{print ($2+$4)*100/($2+$4+$5)}')
    sleep 1
    local stat2=$(cat /proc/stat | grep '^cpu ' | awk '{print ($2+$4)*100/($2+$4+$5)}')
    echo "${stat2%.*}"
}

set_power_limits() {
    local pl1=$1
    local pl2=$2
    local gpu_tgp=$3
    local mode=$4
    
    ARMOURY_PATH="/sys/class/firmware-attributes/asus-armoury/attributes"
    
    # Apply CPU limits
    echo $pl1 > "$ARMOURY_PATH/ppt_pl1_spl/current_value" 2>/dev/null
    echo $pl2 > "$ARMOURY_PATH/ppt_pl2_sppt/current_value" 2>/dev/null
    
    # Apply GPU limits
    echo $gpu_tgp > "$ARMOURY_PATH/dgpu_tgp/current_value" 2>/dev/null
    
    # Log the change
    echo "$(date): Switched to $mode mode (PL1=${pl1}W, PL2=${pl2}W, GPU=${gpu_tgp}W)" >> "$LOG_FILE"
    echo "$mode" > "$THERMAL_STATE_FILE"
}

# Main loop
echo "$(date): Thermal daemon started" >> "$LOG_FILE"

while true; do
    CURRENT_STATE=$(cat "$THERMAL_STATE_FILE" 2>/dev/null || echo "balanced")
    
    # Check if gaming
    if check_gpu_processes || check_gpu_load; then
        if [ "$CURRENT_STATE" != "gaming" ]; then
            echo "Gaming detected - switching to performance mode"
            set_power_limits $GAMING_PL1 $GAMING_PL2 $GAMING_GPU_TGP "gaming"
            asusctl profile --profile-set performance 2>/dev/null
            asusctl fan-curve --profile-set performance 2>/dev/null
        fi
    else
        CPU_USAGE=$(get_cpu_usage)
        
        if [ "$CPU_USAGE" -lt "$IDLE_CPU_THRESHOLD" ] && [ "$CURRENT_STATE" != "idle" ]; then
            echo "System idle - switching to cool mode"
            set_power_limits $IDLE_PL1 $IDLE_PL2 $IDLE_GPU_TGP "idle"
            asusctl profile --profile-set quiet 2>/dev/null
            asusctl fan-curve --profile-set quiet 2>/dev/null
        elif [ "$CPU_USAGE" -gt "$GAMING_CPU_THRESHOLD" ] && [ "$CURRENT_STATE" != "gaming" ]; then
            echo "High CPU load detected - switching to performance mode"
            set_power_limits $GAMING_PL1 $GAMING_PL2 $GAMING_GPU_TGP "gaming"
            asusctl profile --profile-set performance 2>/dev/null
        elif [ "$CURRENT_STATE" = "gaming" ] && [ "$CPU_USAGE" -lt "$((GAMING_CPU_THRESHOLD - 10))" ]; then
            echo "Gaming ended - switching back to balanced mode"
            set_power_limits $BALANCED_PL1 $BALANCED_PL2 $BALANCED_GPU_TGP "balanced"
            asusctl profile --profile-set balanced 2>/dev/null
            asusctl fan-curve --profile-set balanced 2>/dev/null
        fi
    fi
    
    sleep 5
done
