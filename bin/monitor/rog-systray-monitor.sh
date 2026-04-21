#!/bin/bash
# ROG System Tray Monitor - Shows temps in system tray with menu
# Uses yad for system tray icon

if ! command -v yad &> /dev/null; then
    echo "yad not installed. Installing..."
    sudo rpm-ostree install yad 2>/dev/null || sudo dnf install yad -y
fi

# Function to get stats
get_stats() {
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
    local gpu_power=0
    if command -v nvidia-smi &> /dev/null; then
        local nvidia_data=$(nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv,noheader 2>/dev/null)
        gpu_temp=$(echo "$nvidia_data" | cut -d',' -f1 | tr -d ' ')
        gpu_power=$(echo "$nvidia_data" | cut -d',' -f2 | cut -d' ' -f2)
    fi
    
    local pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
    local fan1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
    
    echo "CPU:${cpu_temp}°C | GPU:${gpu_temp}°C | ${pl1}W"
}

# Create menu items
menu() {
    cat << EOF
Silent Mode (25W)!zephyrus-profile quiet
Balanced Mode (45W)!zephyrus-profile balanced
Performance Mode (65W)!zephyrus-profile performance
---
Open Monitor!konsole -e /home/solarious/Desktop/Zephyrus\ OS/rog-monitor-conky.sh
---
Quit!quit
EOF
}

# Main loop
while true; do
    stats=$(get_stats)
    
    # Show in system tray
    echo "$stats"
    
    menu | yad --notification \
        --listen \
        --no-middle \
        --image="preferences-system-performance" \
        --text="ROG Monitor: $stats" \
        --command="echo 'clicked'" \
        --menu="$(menu)" &
    
    YAD_PID=$!
    
    # Update every 3 seconds
    for i in {1..30}; do
        sleep 0.1
        new_stats=$(get_stats)
        if [ "$new_stats" != "$stats" ]; then
            kill $YAD_PID 2>/dev/null
            break
        fi
    done
    
    kill $YAD_PID 2>/dev/null
done
