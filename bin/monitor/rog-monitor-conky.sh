#!/bin/bash
# ROG Zephyrus Desktop Monitor - Conky-style floating display
# Creates a floating terminal window that stays on top

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Get stats
collect_stats() {
    # CPU Temp
    local cpu_temp=0
    for zone in /sys/class/thermal/thermal_zone*; do
        local type=$(cat "$zone/type" 2>/dev/null)
        if [ "$type" = "TCPU" ] || [ "$type" = "x86_pkg_temp" ]; then
            local temp=$(cat "$zone/temp" 2>/dev/null)
            cpu_temp=$((temp / 1000))
            break
        fi
    done
    
    # GPU Stats
    local gpu_temp=0
    local gpu_power=0
    local gpu_util=0
    local gpu_clock=0
    if command -v nvidia-smi &> /dev/null; then
        local nvidia_data=$(nvidia-smi --query-gpu=temperature.gpu,power.draw,utilization.gpu,clocks.sm --format=csv,noheader 2>/dev/null)
        gpu_temp=$(echo "$nvidia_data" | cut -d',' -f1 | tr -d ' ')
        gpu_power=$(echo "$nvidia_data" | cut -d',' -f2 | cut -d' ' -f2)
        gpu_util=$(echo "$nvidia_data" | cut -d',' -f3 | tr -d ' ')
        gpu_clock=$(echo "$nvidia_data" | cut -d',' -f4 | tr -d ' ')
    fi
    
    # Power limits
    local pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
    local pl2=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value 2>/dev/null)
    local gpu_tgp=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value 2>/dev/null)
    
    # Fan speeds
    local fan1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
    local fan2=$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)
    
    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    
    echo "${cpu_temp}|${gpu_temp}|${gpu_power}|${gpu_util}|${gpu_clock}|${pl1}|${pl2}|${gpu_tgp}|${fan1}|${fan2}|${cpu_usage}"
}

# Draw bar chart
draw_bar() {
    local value=$1
    local max=$2
    local width=15
    local label=$3
    
    local filled=$((width * value / max))
    [ "$filled" -gt "$width" ] && filled=$width
    local empty=$((width - filled))
    
    # Color based on value
    local color=$GREEN
    local percent=$((100 * value / max))
    if [ "$percent" -gt 80 ]; then
        color=$RED
    elif [ "$percent" -gt 60 ]; then
        color=$YELLOW
    fi
    
    printf "  %-8s ${color}" "$label"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "${NC} %3d%%\n" "$percent"
}

# Colorize temp
color_temp() {
    local temp=$1
    if [ "$temp" -gt 85 ]; then
        echo -e "${RED}${temp}°C${NC}"
    elif [ "$temp" -gt 70 ]; then
        echo -e "${YELLOW}${temp}°C${NC}"
    else
        echo -e "${GREEN}${temp}°C${NC}"
    fi
}

# Main display loop
run_monitor() {
    clear
    tput civis  # Hide cursor
    
    # Trap to restore cursor on exit
    trap 'tput cnorm; clear; exit' INT TERM EXIT
    
    while true; do
        # Save cursor position
        tput cup 0 0
        
        local stats=$(collect_stats)
        local cpu_temp=$(echo "$stats" | cut -d'|' -f1)
        local gpu_temp=$(echo "$stats" | cut -d'|' -f2)
        local gpu_power=$(echo "$stats" | cut -d'|' -f3)
        local gpu_util=$(echo "$stats" | cut -d'|' -f4 | tr -d ' %')
        local gpu_clock=$(echo "$stats" | cut -d'|' -f5 | tr -d ' MHz')
        local pl1=$(echo "$stats" | cut -d'|' -f6)
        local pl2=$(echo "$stats" | cut -d'|' -f7)
        local gpu_tgp=$(echo "$stats" | cut -d'|' -f8)
        local fan1=$(echo "$stats" | cut -d'|' -f9)
        local fan2=$(echo "$stats" | cut -d'|' -f10)
        local cpu_usage=$(echo "$stats" | cut -d'|' -f11 | cut -d'.' -f1 | tr -d ' %')
        
        # Header
        echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC} ${WHITE}🎮 ROG Zephyrus G16 Monitor${NC}             ${BLUE}║${NC}"
        echo -e "${BLUE}╠══════════════════════════════════════════╣${NC}"
        
        # Time
        printf "${BLUE}║${NC} %s                              ${BLUE}║${NC}\n" "$(date '+%H:%M:%S')"
        echo -e "${BLUE}╠══════════════════════════════════════════╣${NC}"
        
        # CPU Section
        echo -e "${BLUE}║${NC} ${CYAN}CPU${NC}                                      ${BLUE}║${NC}"
        printf "${BLUE}║${NC}   Temp: %-10s Power: %2dW / %2dW ${BLUE}║${NC}\n" "$(color_temp "$cpu_temp")" "$pl1" "$pl2"
        printf "${BLUE}║${NC}   Usage: %3d%%                             ${BLUE}║${NC}\n" "${cpu_usage:-0}"
        echo -e "${BLUE}╠══════════════════════════════════════════╣${NC}"
        
        # GPU Section
        echo -e "${BLUE}║${NC} ${CYAN}GPU RTX 4090${NC}                             ${BLUE}║${NC}"
        printf "${BLUE}║${NC}   Temp: %-10s Power: %5.1fW / %2dW ${BLUE}║${NC}\n" "$(color_temp "${gpu_temp:-0}")" "${gpu_power:-0}" "${gpu_tgp:-60}"
        printf "${BLUE}║${NC}   Util: %3d%%    Clock: %-7s      ${BLUE}║${NC}\n" "${gpu_util:-0}" "${gpu_clock:-0}"
        echo -e "${BLUE}╠══════════════════════════════════════════╣${NC}"
        
        # Fans
        echo -e "${BLUE}║${NC} ${CYAN}Fans${NC}                                     ${BLUE}║${NC}"
        printf "${BLUE}║${NC}   Fan1: %5s RPM  Fan2: %5s RPM  ${BLUE}║${NC}\n" "${fan1:-0}" "${fan2:-0}"
        echo -e "${BLUE}╠══════════════════════════════════════════╣${NC}"
        
        # Visual bars
        echo -e "${BLUE}║${NC}                                          ${BLUE}║${NC}"
        
        # CPU Temp bar
        local cpu_bar=$((cpu_temp > 100 ? 100 : cpu_temp))
        printf "${BLUE}║${NC} "
        local color=$GREEN
        [ "$cpu_temp" -gt 80 ] && color=$RED
        [ "$cpu_temp" -gt 65 ] && [ "$cpu_temp" -le 80 ] && color=$YELLOW
        printf "${color}CPU Temp  "
        local filled=$((15 * cpu_bar / 100))
        printf "%${filled}s" | tr ' ' '█'
        printf "%$((15 - filled))s" | tr ' ' '░'
        printf "${NC} %3d%%${BLUE}║${NC}\n" "$cpu_bar"
        
        # GPU Temp bar
        local gpu_bar=${gpu_temp:-0}
        [ "$gpu_bar" -gt 100 ] && gpu_bar=100
        printf "${BLUE}║${NC} "
        color=$GREEN
        [ "${gpu_temp:-0}" -gt 80 ] && color=$RED
        [ "${gpu_temp:-0}" -gt 65 ] && [ "${gpu_temp:-0}" -le 80 ] && color=$YELLOW
        printf "${color}GPU Temp  "
        filled=$((15 * gpu_bar / 100))
        printf "%${filled}s" | tr ' ' '█'
        printf "%$((15 - filled))s" | tr ' ' '░'
        printf "${NC} %3d%%${BLUE}║${NC}\n" "$gpu_bar"
        
        # GPU Util bar
        local util_bar=${gpu_util:-0}
        printf "${BLUE}║${NC} "
        color=$GREEN
        [ "$util_bar" -gt 80 ] && color=$YELLOW
        [ "$util_bar" -gt 90 ] && color=$RED
        printf "${color}GPU Util  "
        filled=$((15 * util_bar / 100))
        printf "%${filled}s" | tr ' ' '█'
        printf "%$((15 - filled))s" | tr ' ' '░'
        printf "${NC} %3d%%${BLUE}║${NC}\n" "$util_bar"
        
        echo -e "${BLUE}║${NC}                                          ${BLUE}║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
        
        sleep 2
    done
}

# Launch in a floating terminal window
launch_floating() {
    # Try different terminal emulators with floating options
    
    # Try konsole (KDE) with floating geometry
    if command -v konsole &> /dev/null; then
        konsole --nofork --geometry 400x300+20+50 -e "$0" &
        return
    fi
    
    # Try gnome-terminal
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal --geometry=45x20+20+50 -- "$0" &
        return
    fi
    
    # Try alacritty
    if command -v alacritty &> /dev/null; then
        alacritty -o window.dimensions.columns=45 window.dimensions.lines=20 -x 20 -y 50 -e "$0" &
        return
    fi
    
    # Fallback: just run in current terminal
    run_monitor
}

# Main
main() {
    case "${1:-run}" in
        run|r)
            run_monitor
            ;;
        window|w|float|f)
            launch_floating
            ;;
        *)
            echo "ROG Zephyrus Desktop Monitor"
            echo ""
            echo "Usage:"
            echo "  $0 run     - Run in current terminal (default)"
            echo "  $0 window  - Launch in floating window"
            echo ""
            echo "While running:"
            echo "  Press Ctrl+C to close"
            ;;
    esac
}

main "$@"
