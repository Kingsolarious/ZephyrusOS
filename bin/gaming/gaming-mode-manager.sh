#!/bin/bash
# ASUS ROG Zephyrus - Gaming Mode Manager
# Automatically switches to high performance when gaming, cools down when not
# Monitors for games and adjusts power limits accordingly

LOG_FILE="$HOME/.local/share/gaming-mode.log"
STATE_FILE="/tmp/gaming-mode-state"
CONFIG_FILE="$HOME/.config/gaming-mode.conf"

# Default power limits
GAMING_PL1=65
GAMING_PL2=95
GAMING_PL3=115
GAMING_GPU_TGP=80

BALANCED_PL1=45
BALANCED_PL2=65
BALANCED_GPU_TGP=60

ARMOURY_PATH="/sys/class/firmware-attributes/asus-armoury/attributes"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Load user config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if running on battery
is_on_battery() {
    if [ -f /sys/class/power_supply/BAT0/status ]; then
        STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        [ "$STATUS" = "Discharging" ]
        return $?
    fi
    return 1
}

# Detect gaming processes
detect_gaming() {
    # Check for Steam games
    local steam_games="gamescope|cs2|dota2|tf2|portal2|left4dead|hl2|garrysmod|rust|apex|valheim|\
cyberpunk|witcher|eldenring|sekiro|darksouls|godofwar|spiderman|horizon|\
assassin|farcry|battlefield|cod|callofduty|warzone|fortnite|valorant|\
league|lol|overwatch|minecraft|terraria|stardew|factorio|satisfactory|\
destiny2|warframe|apexlegends|rainbowsix|siege|pubg|gta5|gtav|reddead|\
rocketleague|fallguys|amongus|phasmophobia|vrising|v_rising|lostark|\
newworld|ffxiv|finalfantasy|guildwars|gw2|eso|elderscrollsonline|wow|\
worldofwarcraft|diablo|pathofexile|poe|starcraft|warcraft|hearthstone|\
heroesofthestorm|overwatch2|ow2|starfield|baldursgate|bg3|palworld"
    
    # Check for other launchers
    local other_launchers="lutris|heroic|bottles|prism|minecraft-launcher|\
itch|gog|epic|origin|ea|ubisoft|uplay|battlenet|bnet"
    
    # Check process list
    if pgrep -iE "$steam_games|$other_launchers" > /dev/null 2>&1; then
        return 0
    fi
    
    # Check GPU utilization (if NVIDIA)
    if command -v nvidia-smi &> /dev/null; then
        local gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
        if [ -n "$gpu_util" ] && [ "$gpu_util" -gt 60 ]; then
            return 0
        fi
    fi
    
    # Check for gamemode activated processes
    if [ -f /sys/fs/cgroup/gameoverlay/cgroup.procs ] && [ -s /sys/fs/cgroup/gameoverlay/cgroup.procs ]; then
        return 0
    fi
    
    return 1
}

# Set power limits via Armoury Crate
set_power_limits() {
    local pl1=$1
    local pl2=$2
    local pl3=$3
    local gpu_tgp=$4
    
    if [ -d "$ARMOURY_PATH" ]; then
        echo "$pl1" > "$ARMOURY_PATH/ppt_pl1_spl/current_value" 2>/dev/null
        echo "$pl2" > "$ARMOURY_PATH/ppt_pl2_sppt/current_value" 2>/dev/null
        echo "$pl3" > "$ARMOURY_PATH/ppt_pl3_fppt/current_value" 2>/dev/null
        echo "$gpu_tgp" > "$ARMOURY_PATH/dgpu_tgp/current_value" 2>/dev/null
    fi
}

# Set platform profile
set_platform_profile() {
    local profile=$1
    if command -v asusctl &> /dev/null; then
        asusctl profile --profile-set "$profile" 2>/dev/null
    elif [ -f /sys/firmware/acpi/platform_profile ]; then
        echo "$profile" > /sys/firmware/acpi/platform_profile 2>/dev/null
    fi
}

# Set fan curve
set_fan_profile() {
    local profile=$1
    if command -v asusctl &> /dev/null; then
        asusctl fan-curve --enable 2>/dev/null
        asusctl fan-curve --profile-set "$profile" 2>/dev/null
    fi
}

# Switch to gaming mode
enter_gaming_mode() {
    echo "gaming" > "$STATE_FILE"
    log "Entering GAMING MODE"
    
    # Set high power limits
    set_power_limits $GAMING_PL1 $GAMING_PL2 $GAMING_PL3 $GAMING_GPU_TGP
    set_platform_profile "performance"
    set_fan_profile "performance"
    
    # Enable CPU boost
    if command -v asusctl &> /dev/null; then
        asusctl profile --boost-set true 2>/dev/null
    fi
    
    # Set CPU governor to performance
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "$cpu" 2>/dev/null
    done
    
    log "Gaming mode active: PL1=${GAMING_PL1}W PL2=${GAMING_PL2}W GPU=${GAMING_GPU_TGP}W"
    
    # Send notification
    notify-send "🎮 Gaming Mode Activated" "Power limits increased: CPU ${GAMING_PL1}W / GPU ${GAMING_GPU_TGP}W" 2>/dev/null
}

# Switch to balanced mode
enter_balanced_mode() {
    echo "balanced" > "$STATE_FILE"
    log "Entering BALANCED MODE"
    
    # Check if on battery
    if is_on_battery; then
        # Extra conservative on battery
        set_power_limits 25 35 45 50
        set_platform_profile "quiet"
        set_fan_profile "quiet"
        log "Battery mode: Extra conservative power limits"
        notify-send "🔋 Battery Mode" "Conservative power limits for battery life" 2>/dev/null
    else
        # Normal balanced on AC
        set_power_limits $BALANCED_PL1 $BALANCED_PL2 $BALANCED_PL2 $BALANCED_GPU_TGP
        set_platform_profile "balanced"
        set_fan_profile "balanced"
        log "Balanced mode active: PL1=${BALANCED_PL1}W PL2=${BALANCED_PL2}W GPU=${BALANCED_GPU_TGP}W"
    fi
    
    # Set CPU governor to schedutil
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo schedutil > "$cpu" 2>/dev/null
    done
}

# Manual mode switch
manual_mode() {
    case "$1" in
        gaming|performance)
            enter_gaming_mode
            ;;
        balanced|cool)
            enter_balanced_mode
            ;;
        battery|quiet)
            echo "battery" > "$STATE_FILE"
            set_power_limits 25 35 45 50
            set_platform_profile "quiet"
            set_fan_profile "quiet"
            log "Manual: Battery mode"
            ;;
        status)
            show_status
            ;;
        *)
            echo "Usage: $0 [gaming|balanced|battery|status]"
            exit 1
            ;;
    esac
}

# Show current status
show_status() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         ASUS ROG Gaming Mode Manager Status              ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "unknown")
    echo -e "Current State: ${YELLOW}$CURRENT_STATE${NC}"
    echo ""
    
    # Show power limits
    if [ -d "$ARMOURY_PATH" ]; then
        echo "Power Limits:"
        printf "  CPU PL1:  %sW\n" "$(cat $ARMOURY_PATH/ppt_pl1_spl/current_value 2>/dev/null)"
        printf "  CPU PL2:  %sW\n" "$(cat $ARMOURY_PATH/ppt_pl2_sppt/current_value 2>/dev/null)"
        printf "  GPU TGP:  %sW\n" "$(cat $ARMOURY_PATH/dgpu_tgp/current_value 2>/dev/null)"
    fi
    
    echo ""
    
    # Show temperatures
    echo "Temperatures:"
    for zone in /sys/class/thermal/thermal_zone*; do
        TYPE=$(cat $zone/type 2>/dev/null)
        TEMP=$(cat $zone/temp 2>/dev/null)
        if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ] && [ "$TEMP" -lt 150000 ]; then
            TEMP_C=$((TEMP / 1000))
            printf "  %-20s: %d°C\n" "$TYPE" "$TEMP_C"
        fi
    done
    
    echo ""
    
    # Show GPU info
    if command -v nvidia-smi &> /dev/null; then
        echo "NVIDIA GPU:"
        nvidia-smi --query-gpu=temperature.gpu,power.draw,utilization.gpu,clocks.sm --format=csv | tail -1 | \
        while IFS=',' read -r temp power util clock; do
            printf "  Temp: %s  Power: %s  Util: %s  Clock: %s\n" "$temp" "$power" "$util" "$clock"
        done
    fi
}

# Auto-daemon mode
run_daemon() {
    log "Gaming Mode Manager daemon started"
    echo "balanced" > "$STATE_FILE"
    
    GAMING_COOLDOWN=0
    MAX_COOLDOWN=12  # 60 seconds (5s * 12)
    
    while true; do
        CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "balanced")
        
        if detect_gaming; then
            GAMING_COOLDOWN=$MAX_COOLDOWN
            if [ "$CURRENT_STATE" != "gaming" ]; then
                enter_gaming_mode
            fi
        else
            if [ "$GAMING_COOLDOWN" -gt 0 ]; then
                GAMING_COOLDOWN=$((GAMING_COOLDOWN - 1))
            elif [ "$CURRENT_STATE" = "gaming" ]; then
                enter_balanced_mode
            fi
        fi
        
        sleep 5
    done
}

# Main entry point
case "${1:-daemon}" in
    daemon)
        run_daemon
        ;;
    gaming|performance|balanced|cool|battery|status)
        manual_mode "$1"
        ;;
    *)
        echo "ASUS ROG Gaming Mode Manager"
        echo ""
        echo "Usage:"
        echo "  $0 daemon              - Run auto-switching daemon (default)"
        echo "  $0 gaming              - Force gaming mode (high power)"
        echo "  $0 balanced            - Force balanced mode (cool)"
        echo "  $0 battery             - Force battery mode (ultra cool)"
        echo "  $0 status              - Show current status"
        echo ""
        echo "The daemon automatically detects games and switches profiles."
        exit 1
        ;;
esac
