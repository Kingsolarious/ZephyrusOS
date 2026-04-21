#!/bin/bash
# ROG Zephyrus On-Screen Monitor Widget
# Floating window showing real-time temps and power

# Configuration
UPDATE_INTERVAL=2
WINDOW_WIDTH=280
WINDOW_HEIGHT=180
POSITION_X=20
POSITION_Y=40

# Check if running in terminal or create a floating window
if [ -z "$DISPLAY" ]; then
    echo "Error: No display available"
    exit 1
fi

# Try to use yad for a nice GUI window
if command -v yad &> /dev/null; then
    run_yad_widget
elif command -v zenity &> /dev/null; then
    run_zenity_widget
else
    # Fallback to terminal with custom settings
    run_terminal_widget
fi

# Function to get current stats
get_stats() {
    local cpu_temp=0
    local gpu_temp=0
    local gpu_power=0
    local pl1=0
    local fan1=0
    local fan2=0
    
    # CPU temp
    for zone in /sys/class/thermal/thermal_zone*; do
        local type=$(cat "$zone/type" 2>/dev/null)
        if [ "$type" = "TCPU" ] || [ "$type" = "x86_pkg_temp" ]; then
            local temp=$(cat "$zone/temp" 2>/dev/null)
            cpu_temp=$((temp / 1000))
            break
        fi
    done
    
    # GPU stats
    if command -v nvidia-smi &> /dev/null; then
        local nvidia_data=$(nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv,noheader 2>/dev/null)
        gpu_temp=$(echo "$nvidia_data" | cut -d',' -f1 | tr -d ' ')
        gpu_power=$(echo "$nvidia_data" | cut -d',' -f2 | cut -d' ' -f2)
    fi
    
    # Power limit
    pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
    
    # Fan speeds
    fan1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
    fan2=$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)
    
    echo "${cpu_temp}|${gpu_temp}|${gpu_power}|${pl1}|${fan1}|${fan2}"
}

# Run with yad (best option)
run_yad_widget() {
    # Create a form that updates
    while true; do
        local stats=$(get_stats)
        local cpu_temp=$(echo "$stats" | cut -d'|' -f1)
        local gpu_temp=$(echo "$stats" | cut -d'|' -f2)
        local gpu_power=$(echo "$stats" | cut -d'|' -f3)
        local pl1=$(echo "$stats" | cut -d'|' -f4)
        local fan1=$(echo "$stats" | cut -d'|' -f5)
        local fan2=$(echo "$stats" | cut -d'|' -f6)
        
        local text="<b>🌡️ ROG Zephyrus Monitor</b>

CPU: ${cpu_temp}°C
GPU: ${gpu_temp}°C | ${gpu_power}W
Power: ${pl1}W
Fan1: ${fan1} RPM
Fan2: ${fan2} RPM"
        
        # Show notification that stays on screen
        # Or use yad --form for persistent window
        sleep $UPDATE_INTERVAL
    done
}

# Terminal-based floating widget (most compatible)
run_terminal_widget() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║     🌡️  ROG Zephyrus Monitor         ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "Press Ctrl+C to close"
    echo ""
    
    while true; do
        # Move cursor up
        tput cuu 7 2>/dev/null
        
        local stats=$(get_stats)
        local cpu_temp=$(echo "$stats" | cut -d'|' -f1)
        local gpu_temp=$(echo "$stats" | cut -d'|' -f2)
        local gpu_power=$(echo "$stats" | cut -d'|' -f3)
        local pl1=$(echo "$stats" | cut -d'|' -f4)
        local fan1=$(echo "$stats" | cut -d'|' -f5)
        local fan2=$(echo "$stats" | cut -d'|' -f6)
        
        # Color based on temp
        local cpu_color="\033[0;32m"  # Green
        if [ "$cpu_temp" -gt 80 ]; then
            cpu_color="\033[0;31m"  # Red
        elif [ "$cpu_temp" -gt 65 ]; then
            cpu_color="\033[1;33m"  # Yellow
        fi
        
        local gpu_color="\033[0;32m"
        if [ "${gpu_temp:-0}" -gt 80 ]; then
            gpu_color="\033[0;31m"
        elif [ "${gpu_temp:-0}" -gt 65 ]; then
            gpu_color="\033[1;33m"
        fi
        
        printf "  CPU: ${cpu_color}%3d°C\033[0m\n" "$cpu_temp"
        printf "  GPU: ${gpu_color}%3d°C\033[0m  %6.1fW\n" "${gpu_temp:-0}" "${gpu_power:-0}"
        printf "  Power Limit: %2dW\n" "${pl1:-0}"
        printf "  Fan1: %5s RPM\n" "${fan1:-0}"
        printf "  Fan2: %5s RPM\n" "${fan2:-0}"
        printf "  %s\n" "$(date '+%H:%M:%S')"
        
        sleep $UPDATE_INTERVAL
    done
}

# KDE Plasma-specific: Create a custom panel widget
setup_kde_panel_widget() {
    # Create a simple command output widget in the panel
    # This uses KDE's 'Command Output' widget if available
    
    cat > ~/.local/share/plasma/plasmoids/com.rog.monitor/contents/ui/main.qml << 'QML'
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0

Item {
    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: 200
        Layout.minimumHeight: 100
        
        Column {
            anchors.fill: parent
            spacing: 5
            
            Text {
                text: "🌡️ ROG Monitor"
                font.bold: true
            }
            
            Text {
                text: "CPU: " + exec("cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{print int($1/1000)}'") + "°C"
            }
        }
    }
}
QML
}

# Main
main() {
    case "${1:-terminal}" in
        terminal|t)
            run_terminal_widget
            ;;
        yad|y)
            run_yad_widget
            ;;
        panel|p)
            setup_kde_panel_widget
            ;;
        *)
            echo "ROG On-Screen Monitor Widget"
            echo ""
            echo "Usage:"
            echo "  $0 terminal  - Terminal-based widget (default)"
            echo "  $0 yad       - GUI widget (if yad installed)"
            echo "  $0 panel     - KDE panel widget"
            ;;
    esac
}

main "$@"
