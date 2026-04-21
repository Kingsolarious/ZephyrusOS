#!/bin/bash
# Thermal Watchdog - Automatic Fan Control
# Automatically cranks fans to max when temps get high
# No notifications, just action!

# Configuration
CPU_FAN_TRIGGER=75      # Start increasing fans at 75°C
CPU_FAN_MAX=85          # Max fans at 85°C
GPU_FAN_TRIGGER=70      # Start increasing fans at 70°C
GPU_FAN_MAX=80          # Max fans at 80°C
CHECK_INTERVAL=3        # Check every 3 seconds
COOLDOWN_TEMP=65        # Return to normal below 65°C

# State tracking
CURRENT_FAN_MODE="auto"
LAST_ACTION=0
ACTION_COOLDOWN=10      # Minimum seconds between fan adjustments

# Get current time
get_time() {
    date +%s
}

# Get temperatures
get_temps() {
    local cpu_temp=0
    for zone in /sys/class/thermal/thermal_zone*; do
        local type=$(cat "$zone/type" 2>/dev/null)
        if [ "$type" = "TCPU" ] || [ "$type" = "x86_pkg_temp" ]; then
            local temp=$(cat "$zone/temp" 2>/dev/null)
            cpu_temp=$((temp / 1000))
            break
        fi
    done
    
    local gpu_temp=0
    if command -v nvidia-smi &> /dev/null; then
        gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
    fi
    
    echo "${cpu_temp}|${gpu_temp:-0}"
}

# Set fan curve based on temperature
set_fan_curve() {
    local cpu_temp=$1
    local gpu_temp=$2
    local max_temp=$cpu_temp
    [ "$gpu_temp" -gt "$max_temp" ] && max_temp=$gpu_temp
    
    local current_time=$(get_time)
    local time_since_last=$((current_time - LAST_ACTION))
    
    # Determine fan mode based on temps
    local target_mode="auto"
    
    if [ "$max_temp" -ge "$CPU_FAN_MAX" ] || [ "$gpu_temp" -ge "$GPU_FAN_MAX" ]; then
        target_mode="max"
    elif [ "$max_temp" -ge "$CPU_FAN_TRIGGER" ] || [ "$gpu_temp" -ge "$GPU_FAN_TRIGGER" ]; then
        target_mode="high"
    elif [ "$max_temp" -le "$COOLDOWN_TEMP" ]; then
        target_mode="auto"
    fi
    
    # Only change if different and cooldown passed
    if [ "$target_mode" != "$CURRENT_FAN_MODE" ] && [ "$time_since_last" -ge "$ACTION_COOLDOWN" ]; then
        case "$target_mode" in
            max)
                # Maximum cooling - performance fans + boost
                sudo -n asusctl fan-curve --profile-set performance 2>/dev/null
                sudo -n asusctl fan-curve --enable 2>/dev/null
                sudo -n asusctl profile --boost-set true 2>/dev/null
                
                # Try to maximize fan speeds directly
                if [ -f /sys/class/hwmon/hwmon*/pwm1_enable ]; then
                    for pwm in /sys/class/hwmon/hwmon*/pwm1_enable; do
                        echo 0 | sudo -n tee "$pwm" > /dev/null 2>&1
                    done
                fi
                
                echo "$(date '+%H:%M:%S') - TEMPS HIGH (${cpu_temp}°C/${gpu_temp}°C) - FANS MAXIMUM"
                LAST_ACTION=$current_time
                ;;
                
            high)
                # High cooling - performance fans
                sudo -n asusctl fan-curve --profile-set performance 2>/dev/null
                sudo -n asusctl fan-curve --enable 2>/dev/null
                
                echo "$(date '+%H:%M:%S') - Temps warming (${cpu_temp}°C/${gpu_temp}°C) - Fans high"
                LAST_ACTION=$current_time
                ;;
                
            auto)
                # Return to normal - balanced fans
                sudo -n asusctl fan-curve --profile-set balanced 2>/dev/null
                
                echo "$(date '+%H:%M:%S') - Temps normal (${cpu_temp}°C/${gpu_temp}°C) - Fans auto"
                LAST_ACTION=$current_time
                ;;
        esac
        
        CURRENT_FAN_MODE=$target_mode
    fi
}

# Log to file for debugging
LOG_FILE="$HOME/.local/share/zephyrus-learning/fan-control.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Main loop
echo "Thermal Watchdog Started - Auto Fan Control"
echo "CPU trigger: ${CPU_FAN_TRIGGER}°C → ${CPU_FAN_MAX}°C max"
echo "GPU trigger: ${GPU_FAN_TRIGGER}°C → ${GPU_FAN_MAX}°C max"
echo "Logging to: $LOG_FILE"
echo ""

while true; do
    # Get temperatures
    temps=$(get_temps)
    cpu_temp=$(echo "$temps" | cut -d'|' -f1)
    gpu_temp=$(echo "$temps" | cut -d'|' -f2)
    
    # Set appropriate fan curve
    set_fan_curve "$cpu_temp" "$gpu_temp"
    
    # Log current state
    echo "$(date '+%Y-%m-%d %H:%M:%S') CPU:${cpu_temp}°C GPU:${gpu_temp}°C Mode:${CURRENT_FAN_MODE}" >> "$LOG_FILE"
    
    sleep $CHECK_INTERVAL
done
