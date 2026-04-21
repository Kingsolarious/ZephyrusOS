#!/bin/bash
# Enhanced ASUS ROG Profile Switcher — GU605MY Validated
# Uses asusctl for ACPI power limits (PL1/PL2 from DSDT)
# GPU power limits from decoded Armoury Crate config:
#   Silent  : ~55W
#   Balanced: 90W
#   Performance: 115W (95W base + 20W Dynamic Boost)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get current profile from asusctl
get_current_profile() {
    asusctl profile get 2>/dev/null | grep -oP 'Active profile: \K\w+' || echo "Performance"
}

# Apply power limits based on profile
set_boost() {
    local enable="$1"
    local no_turbo="/sys/devices/system/cpu/intel_pstate/no_turbo"
    if [ -w "$no_turbo" ]; then
        [ "$enable" = "true" ] && echo 0 > "$no_turbo" || echo 1 > "$no_turbo"
    else
        asusctl profile --boost-set "$enable" 2>/dev/null || true
    fi
}

apply_power_limits() {
    local profile=$1

    case "$profile" in
        Quiet|Silent|quiet|silent)
            ASUS_PROFILE="quiet"
            GPU_PL=55
            FAN_PROFILE="quiet"
            GOVERNOR="powersave"
            BOOST=false
            ;;
        Balanced|balanced)
            ASUS_PROFILE="balanced"
            GPU_PL=90
            FAN_PROFILE="balanced"
            GOVERNOR="schedutil"
            BOOST=true
            ;;
        Performance|Turbo|performance|turbo)
            ASUS_PROFILE="performance"
            GPU_PL=115
            FAN_PROFILE="performance"
            GOVERNOR="performance"
            BOOST=true
            ;;
        *)
            ASUS_PROFILE="performance"
            GPU_PL=115
            FAN_PROFILE="performance"
            GOVERNOR="performance"
            BOOST=true
            ;;
    esac

    # asusctl handles CPU PL1/PL2 automatically from ACPI
    asusctl profile -P "$ASUS_PROFILE" 2>/dev/null || true
    set_boost "$BOOST" 2>/dev/null || true

    # Sync GPU power limit
    if command -v nvidia-smi &> /dev/null; then
        sudo nvidia-smi -pl "$GPU_PL" 2>/dev/null || true
    fi

    # Configure fan curves (enable but do not override with 100%)
    asusctl fan-curve --enable 2>/dev/null || true
    asusctl fan-curve --profile-set "$FAN_PROFILE" 2>/dev/null || true

    # Set CPU governor
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$GOVERNOR" > "$cpu" 2>/dev/null || true
    done

    # Save state
    mkdir -p ~/.local/share/zephyrus-profile
    echo "$ASUS_PROFILE" > ~/.local/share/zephyrus-profile/current

    echo "$GPU_PL|$FAN_PROFILE|$GOVERNOR"
}

# Get temperatures
get_temperatures() {
    local cpu_temp="N/A"
    local gpu_temp="N/A"

    for zone in /sys/class/thermal/thermal_zone*; do
        type=$(cat "$zone/type" 2>/dev/null)
        if [ "$type" = "TCPU" ] || [ "$type" = "x86_pkg_temp" ]; then
            temp=$(cat "$zone/temp" 2>/dev/null)
            if [ -n "$temp" ] && [ "$temp" -gt 0 ]; then
                cpu_temp=$((temp / 1000))
                break
            fi
        fi
    done

    if command -v nvidia-smi &> /dev/null; then
        gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
    fi

    echo "$cpu_temp|$gpu_temp"
}

# Show notification
show_notification() {
    local profile=$1
    local gpu_pl=$2
    local cpu_temp=$3
    local gpu_temp=$4

    case "$profile" in
        quiet|Quiet|silent|Silent)
            ICON="🔇"
            TITLE="Silent Mode"
            DESC="Ultra cool • Office/Battery"
            COLOR="#00AA00"
            ;;
        balanced|Balanced)
            ICON="⚖️"
            TITLE="Balanced Mode"
            DESC="Cool & efficient • Daily use"
            COLOR="#FFAA00"
            ;;
        performance|Performance|turbo|Turbo)
            ICON="🚀"
            TITLE="Performance Mode"
            DESC="Maximum power • Gaming"
            COLOR="#FF0000"
            ;;
    esac

    local NOTIFICATION="${ICON} <b>${TITLE}</b>

${DESC}

⚡ GPU Power Limit: ${gpu_pl}W

🌡️ Temperatures:
  • CPU: ${cpu_temp}°C
  • GPU: ${gpu_temp}°C"

    if command -v kdialog &> /dev/null; then
        kdialog --geometry "350x250+785+100" --passivepopup "$NOTIFICATION" 3 2>/dev/null &
    fi

    if command -v notify-send &> /dev/null; then
        notify-send "$TITLE" "$NOTIFICATION" \
            -i preferences-system-performance \
            -t 3000 \
            -h "string:bgcolor:$COLOR" 2>/dev/null || \
        notify-send "$TITLE" "$NOTIFICATION" \
            -i preferences-system-performance \
            -t 3000 2>/dev/null || true
    fi

    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${ICON} ${YELLOW}${TITLE}${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    echo -e "GPU Power Limit: ${gpu_pl}W"
    echo -e "Temperatures:"
    echo "  CPU: ${cpu_temp}°C"
    echo "  GPU: ${gpu_temp}°C"
}

# Cycle to next profile
cycle_profile() {
    CURRENT=$(get_current_profile)

    case "$CURRENT" in
        Quiet|Silent|quiet|silent)
            NEXT="Balanced"
            ;;
        Balanced|balanced)
            NEXT="Performance"
            ;;
        Performance|Turbo|performance|turbo)
            NEXT="Quiet"
            ;;
        *)
            NEXT="Balanced"
            ;;
    esac

    echo "Switching: $CURRENT → $NEXT"
    switch_profile "$NEXT"
}

# Switch to specific profile
switch_profile() {
    local target=$1

    SETTINGS=$(apply_power_limits "$target")
    GPU_PL=$(echo "$SETTINGS" | cut -d'|' -f1)

    TEMPS=$(get_temperatures)
    CPU_TEMP=$(echo "$TEMPS" | cut -d'|' -f1)
    GPU_TEMP=$(echo "$TEMPS" | cut -d'|' -f2)

    show_notification "$target" "$GPU_PL" "$CPU_TEMP" "$GPU_TEMP"
}

# Show current status
show_status() {
    CURRENT=$(get_current_profile)
    SETTINGS=$(apply_power_limits "$CURRENT")
    GPU_PL=$(echo "$SETTINGS" | cut -d'|' -f1)

    TEMPS=$(get_temperatures)
    CPU_TEMP=$(echo "$TEMPS" | cut -d'|' -f1)
    GPU_TEMP=$(echo "$TEMPS" | cut -d'|' -f2)

    show_notification "$CURRENT" "$GPU_PL" "$CPU_TEMP" "$GPU_TEMP"
}

# Main
main() {
    case "${1:-cycle}" in
        cycle|--cycle|-c)
            cycle_profile
            ;;
        quiet|silent|-q|-s)
            switch_profile "Quiet"
            ;;
        balanced|-b)
            switch_profile "Balanced"
            ;;
        performance|gaming|-p|-g)
            switch_profile "Performance"
            ;;
        status|--status|-S)
            show_status
            ;;
        next|-n)
            cycle_profile
            ;;
        *)
            echo "Zephyrus Profile Switcher — GU605MY Tuned"
            echo ""
            echo "Usage:"
            echo "  $0 cycle         - Cycle to next profile (FN+F5)"
            echo "  $0 quiet         - Silent mode (GPU 55W)"
            echo "  $0 balanced      - Balanced mode (GPU 90W)"
            echo "  $0 performance   - Gaming mode (GPU 115W)"
            echo "  $0 status        - Show current status"
            echo ""
            echo "Profiles:"
            echo "  🔇 Silent      - Ultra cool, maximum battery life"
            echo "  ⚖️ Balanced    - Cool & efficient, daily use"
            echo "  🚀 Performance - Maximum power, gaming"
            exit 1
            ;;
    esac
}

main "$@"
