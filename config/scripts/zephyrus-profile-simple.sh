#!/bin/bash
# Simple and Reliable ROG Profile Switcher for GU605MY
# Uses asusctl for ACPI-validated power limits, with nvidia-smi for GPU
# Hardware values from decoded Armoury Crate service logs:
#   Silent : CPU PL1 60W / PL2 70W,  GPU ~55W
#   Balanced: CPU PL1 45W / PL2 65W, GPU 90W (custom daily driver)
#   Performance: CPU PL1 80W / PL2 100W, GPU 115W (Turbo)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

STATE_FILE="$HOME/.local/share/zephyrus-profile/current_mode"

# Create state directory
mkdir -p "$(dirname "$STATE_FILE")"

# Set power limits via asusctl (ACPI DSDT values) + nvidia-smi
set_power_limits() {
    local asus_profile=$1
    local gpu_pl=$2
    local display_name=$3
    local governor=$4

    echo "Setting profile: $display_name (ASUS $asus_profile, GPU ${gpu_pl}W)..."

    # asusctl handles CPU PL1/PL2 from ACPI automatically
    asusctl profile -P "$asus_profile" 2>/dev/null || true
    asusctl profile --boost-set true 2>/dev/null || true

    # Sync GPU power limit
    if command -v nvidia-smi &> /dev/null; then
        sudo nvidia-smi -pl "$gpu_pl" > /dev/null 2>&1 || true
    fi

    # Set CPU governor
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$governor" | sudo tee "$cpu" > /dev/null 2>&1 || true
    done

    # Save state
    echo "$asus_profile" > "$STATE_FILE"

    # Show notification
    show_notification "$display_name" "$gpu_pl" "$governor"
}

# Show notification
show_notification() {
    local profile=$1
    local gpu=$2
    local governor=$3

    case "$profile" in
        "Silent Mode")
            icon="🔇"
            ;;
        "Balanced Mode")
            icon="⚖️"
            ;;
        "Performance Mode")
            icon="🚀"
            ;;
    esac

    notify-send "$icon $profile" "GPU: ${gpu}W | Governor: ${governor}" -t 3000 -i preferences-system-performance 2>/dev/null || true

    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${icon} ${YELLOW}${profile}${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    echo "GPU Power Limit: ${gpu}W"
    echo "CPU Governor: ${governor}"
}

# Get current temps
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

    echo "CPU: ${cpu_temp}°C | GPU: ${gpu_temp}°C"
}

# Cycle through profiles
cycle() {
    local current=$(cat "$STATE_FILE" 2>/dev/null || echo "balanced")

    case "$current" in
        quiet|silent)
            balanced
            ;;
        balanced)
            performance
            ;;
        performance|turbo)
            quiet
            ;;
        *)
            balanced
            ;;
    esac
}

# Individual modes
quiet() {
    set_power_limits "quiet" 55 "Silent Mode" "powersave"
}

balanced() {
    set_power_limits "balanced" 90 "Balanced Mode" "schedutil"
}

performance() {
    set_power_limits "performance" 115 "Performance Mode" "performance"
}

status() {
    local current=$(cat "$STATE_FILE" 2>/dev/null || echo "unknown")
    local gpu_pl=""
    if command -v nvidia-smi &> /dev/null; then
        gpu_pl=$(nvidia-smi --query-gpu=power.limit --format=csv,noheader 2>/dev/null | tr -d ' ')
    fi

    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "Current Mode: ${YELLOW}$current${NC}"
    echo "GPU Power Limit: ${gpu_pl:-N/A}"
    echo "Temperatures: $(get_temps)"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

# Main
case "${1:-cycle}" in
    cycle|c)
        cycle
        ;;
    quiet|silent|s)
        quiet
        ;;
    balanced|b)
        balanced
        ;;
    performance|gaming|p|g)
        performance
        ;;
    status|st)
        status
        ;;
    *)
        echo "Zephyrus Profile Switcher (Simple) — GU605MY Tuned"
        echo ""
        echo "Usage:"
        echo "  $0 cycle        - Cycle through profiles"
        echo "  $0 quiet        - Silent mode (GPU 55W)"
        echo "  $0 balanced     - Balanced mode (GPU 90W)"
        echo "  $0 performance  - Performance mode (GPU 115W)"
        echo "  $0 status       - Show current status"
        ;;
esac
