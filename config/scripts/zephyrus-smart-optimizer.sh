#!/bin/bash
# Zephyrus Smart Optimizer - Automatically applies learned settings per game
# Detects game launches and applies optimized power limits automatically

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$HOME/.local/share/zephyrus-learning"
CONFIG_DIR="$HOME/.config/zephyrus-learning"
CACHE_DIR="$HOME/.cache/zephyrus-optimizer"
LOG_FILE="$DATA_DIR/optimizer.log"

# Settings
CHECK_INTERVAL=3  # Check every 3 seconds
STABLE_TIME=10    # Wait 10 seconds after game start before applying
COOLDOWN_TIME=60  # Wait 60 seconds after game ends before switching back

# Create directories
mkdir -p "$DATA_DIR" "$CONFIG_DIR" "$CACHE_DIR"

# Current state
CURRENT_GAME=""
GAME_START_TIME=0
LAST_GAME_END_TIME=0
APPLIED_FOR_CURRENT_GAME=false
DEFAULT_PL1=45  # Default balanced mode

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OPTIMIZER] $1" | tee -a "$LOG_FILE"
}

# Get optimized settings for a game
get_game_optimization() {
    local game=$1
    local rec_file="$DATA_DIR/recommendations/${game}_rec.json"
    local analysis_file="$DATA_DIR/games/${game}_analysis.json"
    
    if [ -f "$rec_file" ]; then
        # Use learned recommendation
        local recommended=$(grep -oP '(?<="recommended_pl1":)[0-9]+' "$rec_file" 2>/dev/null)
        local confidence=$(grep -oP '(?<="confidence":)[0-9.]+' "$rec_file" 2>/dev/null || echo 0.5)
        
        if [ -n "$recommended" ] && [ "$recommended" -gt 0 ]; then
            echo "learned|$recommended|$confidence"
            return
        fi
    fi
    
    if [ -f "$analysis_file" ]; then
        # Use analysis average with small buffer
        local avg_pl=$(grep -oP '(?<="avg_power_limit":)[0-9]+' "$analysis_file" 2>/dev/null)
        if [ -n "$avg_pl" ] && [ "$avg_pl" -gt 0 ]; then
            echo "analyzed|$avg_pl|0.3"
            return
        fi
    fi
    
    # No data - use conservative gaming settings
    echo "default|55|0.0"
}

# Apply power limit
apply_power_limit() {
    local pl1=$1
    local reason=$2
    local current_pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
    
    if [ "$current_pl1" != "$pl1" ]; then
        sudo -n tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value <<< "$pl1" > /dev/null 2>&1
        sudo -n tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value <<< "$((pl1 + 20))" > /dev/null 2>&1
        log "Applied ${pl1}W - $reason"
        return 0
    fi
    return 1
}

# Show notification
notify_optimization() {
    local game=$1
    local pl1=$2
    local source=$3
    local confidence=$4
    
    local icon="🎮"
    local source_text=""
    
    case "$source" in
        learned)
            source_text="Learned optimization"
            icon="🧠"
            ;;
        analyzed)
            source_text="Based on analysis"
            icon="📊"
            ;;
        default)
            source_text="Default gaming mode"
            icon="⚡"
            ;;
    esac
    
    local conf_percent=$(echo "$confidence * 100" | bc 2>/dev/null | cut -d. -f1)
    [ -z "$conf_percent" ] && conf_percent=0
    
    notify-send "${icon} Smart Optimizer" "${game}
${source_text}
Power limit: ${pl1}W
Confidence: ${conf_percent}%" -t 4000 -i applications-games 2>/dev/null || true
}

# Detect running game
detect_game() {
    # Priority: Check for gamemode cgroup first (most reliable)
    if [ -f /sys/fs/cgroup/gameoverlay/cgroup.procs ] && [ -s /sys/fs/cgroup/gameoverlay/cgroup.procs ]; then
        local game_pid=$(head -1 /sys/fs/cgroup/gameoverlay/cgroup.procs 2>/dev/null)
        if [ -n "$game_pid" ]; then
            # Try to get the game name from the process
            local cmdline=$(cat /proc/$game_pid/cmdline 2>/dev/null | tr '\0' ' ')
            local comm=$(cat /proc/$game_pid/comm 2>/dev/null)
            
            # Extract game name
            if [[ "$cmdline" =~ steam ]]; then
                # Try to find the actual game name from Steam
                for pid in $(cat /sys/fs/cgroup/gameoverlay/cgroup.procs 2>/dev/null); do
                    local name=$(cat /proc/$pid/comm 2>/dev/null)
                    if [ -n "$name" ] && [ "$name" != "steam" ] && [ "$name" != "steamwebhelper" ]; then
                        echo "$name"
                        return
                    fi
                done
            fi
            
            echo "$comm"
            return
        fi
    fi
    
    # Fallback: Check for common game processes
    local game_procs="(cs2|dota2|tf2|rust|apex|valorant|cyberpunk|witcher|elden|sekiro|\
godofwar|spiderman|minecraft|terraria|factorio|satisfactory|warframe|\
rocketleague|fallguys|fortnite|overwatch|pubg|gta5|gtav|reddead|\
baldursgate|bg3|palworld|helldivers|destiny|halo|forza|gran-turismo|\
assetto|f1|racing|flight)"
    
    local detected=$(pgrep -fiE "$game_procs" 2>/dev/null | head -1)
    if [ -n "$detected" ]; then
        cat /proc/$detected/comm 2>/dev/null
        return
    fi
    
    # Check GPU utilization (gaming indicator)
    if command -v nvidia-smi &> /dev/null; then
        local gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader 2>/dev/null | tr -d ' ')
        if [ -n "$gpu_util" ] && [ "$gpu_util" -gt 70 ]; then
            echo "gpu-intensive-app"
            return
        fi
    fi
    
    echo ""
}

# Main optimization loop
run_optimizer() {
    log "Smart Optimizer started"
    log "Default PL1: ${DEFAULT_PL1}W"
    
    while true; do
        local detected_game=$(detect_game)
        local current_time=$(date +%s)
        
        if [ -n "$detected_game" ]; then
            # Game is running
            if [ "$detected_game" != "$CURRENT_GAME" ]; then
                # New game started
                CURRENT_GAME="$detected_game"
                GAME_START_TIME=$current_time
                APPLIED_FOR_CURRENT_GAME=false
                log "Game detected: $CURRENT_GAME"
            fi
            
            if [ "$APPLIED_FOR_CURRENT_GAME" = false ]; then
                local elapsed=$((current_time - GAME_START_TIME))
                
                if [ "$elapsed" -ge "$STABLE_TIME" ]; then
                    # Game has been running long enough, apply optimization
                    local opt_data=$(get_game_optimization "$CURRENT_GAME")
                    local source=$(echo "$opt_data" | cut -d'|' -f1)
                    local pl1=$(echo "$opt_data" | cut -d'|' -f2)
                    local confidence=$(echo "$opt_data" | cut -d'|' -f3)
                    
                    if apply_power_limit "$pl1" "Game: $CURRENT_GAME"; then
                        notify_optimization "$CURRENT_GAME" "$pl1" "$source" "$confidence"
                        APPLIED_FOR_CURRENT_GAME=true
                    fi
                fi
            fi
            
            LAST_GAME_END_TIME=0
        else
            # No game running
            if [ -n "$CURRENT_GAME" ]; then
                # Game just ended
                log "Game ended: $CURRENT_GAME"
                CURRENT_GAME=""
                LAST_GAME_END_TIME=$current_time
                APPLIED_FOR_CURRENT_GAME=false
            fi
            
            # Check if we should return to default
            if [ "$LAST_GAME_END_TIME" -gt 0 ]; then
                local time_since_end=$((current_time - LAST_GAME_END_TIME))
                
                if [ "$time_since_end" -ge "$COOLDOWN_TIME" ]; then
                    # Return to default power limit
                    if apply_power_limit "$DEFAULT_PL1" "Returning to default after cooldown"; then
                        notify-send "🌡️ Smart Optimizer" "Returned to balanced mode (${DEFAULT_PL1}W)" -t 3000 2>/dev/null || true
                        LAST_GAME_END_TIME=0
                    fi
                fi
            fi
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# Show current status
show_status() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     🤖 Smart Optimizer Status                            ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if running
    if pgrep -f "zephyrus-smart-optimizer.sh" | grep -v $$ > /dev/null; then
        echo -e "Status: ${GREEN}Running${NC}"
    else
        echo -e "Status: ${RED}Not running${NC}"
    fi
    
    echo ""
    echo "Current Settings:"
    echo "  Default PL1: ${DEFAULT_PL1}W"
    echo "  Check interval: ${CHECK_INTERVAL}s"
    echo "  Stable time: ${STABLE_TIME}s"
    echo "  Cooldown: ${COOLDOWN_TIME}s"
    
    echo ""
    echo "Learned Optimizations:"
    for rec in "$DATA_DIR/recommendations"/*_rec.json 2>/dev/null; do
        if [ -f "$rec" ]; then
            local game=$(basename "$rec" _rec.json)
            local pl=$(grep -oP '(?<="recommended_pl1":)[0-9]+' "$rec" 2>/dev/null)
            local temp=$(grep -oP '(?<="avg_temp":)[0-9]+' "$rec" 2>/dev/null)
            printf "  %-25s %2sW (avg %2s°C)\n" "$game" "$pl" "$temp"
        fi
    done
}

# Test detection
test_detection() {
    echo "Testing game detection..."
    echo ""
    
    for i in {1..5}; do
        local game=$(detect_game)
        if [ -n "$game" ]; then
            echo "Detected: $game"
            local opt=$(get_game_optimization "$game")
            echo "  Optimization: $opt"
        else
            echo "No game detected"
        fi
        sleep 2
    done
}

# Main
main() {
    case "${1:-run}" in
        run|--run|r)
            run_optimizer
            ;;
        status|--status|s)
            show_status
            ;;
        test|--test|t)
            test_detection
            ;;
        set-default|--set-default)
            if [ -z "$2" ]; then
                echo "Usage: $0 set-default <wattage>"
                exit 1
            fi
            DEFAULT_PL1=$2
            echo "Default PL1 set to: ${DEFAULT_PL1}W"
            ;;
        *)
            echo "Zephyrus Smart Optimizer"
            echo ""
            echo "Usage:"
            echo "  $0 run          - Run the optimizer (default)"
            echo "  $0 status       - Show current status"
            echo "  $0 test         - Test game detection"
            echo "  $0 set-default  - Set default power limit"
            echo ""
            echo "The optimizer automatically detects games and applies"
            echo "learned optimal power limits for each game."
            ;;
    esac
}

main "$@"
