#!/bin/bash
# Adaptive Thermal Learning Daemon for ASUS ROG Zephyrus
# Monitors gameplay and optimizes power limits over time
# Collects: temps, power, FPS, fan speeds, game performance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$HOME/.local/share/zephyrus-learning"
CONFIG_DIR="$HOME/.config/zephyrus-learning"
LOG_FILE="$DATA_DIR/daemon.log"
SAMPLE_INTERVAL=5  # Sample every 5 seconds during gaming

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Create directories
mkdir -p "$DATA_DIR"/{games,sessions,recommendations}
mkdir -p "$CONFIG_DIR"

# Initialize config if not exists
if [ ! -f "$CONFIG_DIR/settings.conf" ]; then
cat > "$CONFIG_DIR/settings.conf" << 'EOF'
# Adaptive Thermal Learning Settings

# Temperature thresholds (in Celsius)
TARGET_TEMP_GAMING=78
MAX_ACCEPTABLE_TEMP=85
THERMAL_THROTTLE_TEMP=95

# FPS thresholds
MIN_ACCEPTABLE_FPS=45
TARGET_FPS=60

# Power limit ranges
MIN_CPU_PL1=25
MAX_CPU_PL1=80
MIN_GPU_TGP=40
MAX_GPU_TGP=80

# Learning parameters
LEARNING_RATE=0.1
SAMPLES_PER_SESSION=1000
MIN_SESSION_DURATION=300  # 5 minutes

# Auto-adjustment
AUTO_ADJUST=false
ADJUSTMENT_THRESHOLD=5  # Adjust if temp diff > 5°C
NOTIFY_RECOMMENDATIONS=true
EOF
fi

source "$CONFIG_DIR/settings.conf"

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get UNIX timestamp
get_unix_time() {
    date +%s
}

# Detect current game (Steam, Lutris, etc.)
detect_game() {
    local game_name=""
    
    # Check for Steam games by window class
    if command -v xdotool &> /dev/null; then
        local active_window=$(xdotool getactivewindow 2>/dev/null)
        if [ -n "$active_window" ]; then
            game_name=$(xdotool getwindowclassname "$active_window" 2>/dev/null)
        fi
    fi
    
    # Fallback: Check process list for known games
    if [ -z "$game_name" ]; then
        local game_procs=$(pgrep -f "(cs2|dota2|apex|valorant|cyberpunk|witcher|elden|rust|minecraft)" 2>/dev/null | head -1)
        if [ -n "$game_procs" ]; then
            game_name=$(ps -p "$game_procs" -o comm= 2>/dev/null)
        fi
    fi
    
    # Check if gamemode is active
    if [ -z "$game_name" ] && [ -f /sys/fs/cgroup/gameoverlay/cgroup.procs ]; then
        local game_pid=$(head -1 /sys/fs/cgroup/gameoverlay/cgroup.procs 2>/dev/null)
        if [ -n "$game_pid" ]; then
            game_name=$(ps -p "$game_pid" -o comm= 2>/dev/null)
        fi
    fi
    
    echo "$game_name"
}

# Collect sensor data
collect_sensors() {
    local timestamp=$(get_unix_time)
    local data="{\"timestamp\":$timestamp"
    
    # CPU Temperature
    local cpu_temp=0
    for zone in /sys/class/thermal/thermal_zone*; do
        local type=$(cat "$zone/type" 2>/dev/null)
        if [ "$type" = "TCPU" ] || [ "$type" = "x86_pkg_temp" ]; then
            local temp=$(cat "$zone/temp" 2>/dev/null)
            cpu_temp=$((temp / 1000))
            break
        fi
    done
    data="$data,\"cpu_temp\":$cpu_temp"
    
    # GPU Temperature & Power
    local gpu_temp=0
    local gpu_power=0
    local gpu_util=0
    if command -v nvidia-smi &> /dev/null; then
        local nvidia_data=$(nvidia-smi --query-gpu=temperature.gpu,power.draw,utilization.gpu --format=csv,noheader 2>/dev/null)
        gpu_temp=$(echo "$nvidia_data" | cut -d',' -f1 | tr -d ' ')
        gpu_power=$(echo "$nvidia_data" | cut -d',' -f2 | cut -d' ' -f2)
        gpu_util=$(echo "$nvidia_data" | cut -d',' -f3 | tr -d ' ')
    fi
    data="$data,\"gpu_temp\":${gpu_temp:-0},\"gpu_power\":${gpu_power:-0},\"gpu_util\":${gpu_util:-0}"
    
    # Fan speeds
    local fan1=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)
    local fan2=$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)
    data="$data,\"fan1\":${fan1:-0},\"fan2\":${fan2:-0}"
    
    # Power limits
    local pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
    local pl2=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value 2>/dev/null)
    local gpu_tgp=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value 2>/dev/null)
    data="$data,\"cpu_pl1\":${pl1:-45},\"cpu_pl2\":${pl2:-65},\"gpu_tgp\":${gpu_tgp:-60}"
    
    # Profile
    local profile=$(asusctl profile get 2>/dev/null | grep -oP 'Active profile: \K\w+' || echo "Balanced")
    data="$data,\"profile\":\"$profile\"}"
    
    echo "$data"
}

# Get FPS from MangoHud log (if available)
get_fps_data() {
    local fps=0
    local frame_time=0
    
    # Check MangoHud log
    if [ -f "$HOME/.config/MangoHud/MangoHud.log" ]; then
        local last_line=$(tail -1 "$HOME/.config/MangoHud/MangoHud.log" 2>/dev/null)
        if [ -n "$last_line" ]; then
            fps=$(echo "$last_line" | grep -oP '(?<=fps:)[0-9.]+' || echo 0)
            frame_time=$(echo "$last_line" | grep -oP '(?<=frametime:)[0-9.]+' || echo 0)
        fi
    fi
    
    echo "{\"fps\":${fps:-0},\"frame_time\":${frame_time:-0}}"
}

# Start new gaming session
start_session() {
    local game_name=$1
    local session_id=$(get_unix_time)
    local session_file="$DATA_DIR/sessions/${game_name}_${session_id}.jsonl"
    
    log "Starting session for: $game_name (ID: $session_id)"
    
    echo "{\"session_start\":$(get_unix_time),\"game\":\"$game_name\",\"profile\":\"$(asusctl profile get 2>/dev/null | grep -oP 'Active profile: \K\w+')\"}" > "$session_file"
    
    echo "$session_file"
}

# End gaming session and analyze
end_session() {
    local session_file=$1
    local game_name=$2
    
    if [ ! -f "$session_file" ]; then
        return
    fi
    
    log "Ending session for: $game_name"
    echo "{\"session_end\":$(get_unix_time)}" >> "$session_file"
    
    # Analyze this session
    analyze_session "$session_file" "$game_name"
}

# Analyze a gaming session
analyze_session() {
    local session_file=$1
    local game_name=$2
    
    log "Analyzing session for: $game_name"
    
    # Extract metrics using jq if available, otherwise use awk
    if command -v jq &> /dev/null; then
        local avg_cpu_temp=$(cat "$session_file" | jq -s '[.[] | select(.cpu_temp > 0) | .cpu_temp] | add / length' 2>/dev/null | cut -d. -f1)
        local max_cpu_temp=$(cat "$session_file" | jq -s '[.[] | select(.cpu_temp > 0) | .cpu_temp] | max' 2>/dev/null)
        local avg_gpu_temp=$(cat "$session_file" | jq -s '[.[] | select(.gpu_temp > 0) | .gpu_temp] | add / length' 2>/dev/null | cut -d. -f1)
        local max_gpu_temp=$(cat "$session_file" | jq -s '[.[] | select(.gpu_temp > 0) | .gpu_temp] | max' 2>/dev/null)
        local avg_pl1=$(cat "$session_file" | jq -s '[.[] | select(.cpu_pl1 > 0) | .cpu_pl1] | add / length' 2>/dev/null | cut -d. -f1)
    else
        # Fallback to awk
        local avg_cpu_temp=$(grep '"cpu_temp":' "$session_file" | grep -oP '(?<="cpu_temp":)[0-9]+' | awk '{sum+=$1; count++} END {if(count>0) printf "%d", sum/count}')
        local max_cpu_temp=$(grep '"cpu_temp":' "$session_file" | grep -oP '(?<="cpu_temp":)[0-9]+' | sort -n | tail -1)
        local avg_gpu_temp=$(grep '"gpu_temp":' "$session_file" | grep -oP '(?<="gpu_temp":)[0-9]+' | awk '{sum+=$1; count++} END {if(count>0) printf "%d", sum/count}')
        local max_gpu_temp=$(grep '"gpu_temp":' "$session_file" | grep -oP '(?<="gpu_temp":)[0-9]+' | sort -n | tail -1)
        local avg_pl1=$(grep '"cpu_pl1":' "$session_file" | grep -oP '(?<="cpu_pl1":)[0-9]+' | awk '{sum+=$1; count++} END {if(count>0) printf "%d", sum/count}')
    fi
    
    # Save analysis
    local analysis_file="$DATA_DIR/games/${game_name}_analysis.json"
    cat > "$analysis_file" << EOF
{
    "game": "$game_name",
    "last_session": $(get_unix_time),
    "avg_cpu_temp": ${avg_cpu_temp:-0},
    "max_cpu_temp": ${max_cpu_temp:-0},
    "avg_gpu_temp": ${avg_gpu_temp:-0},
    "max_gpu_temp": ${max_gpu_temp:-0},
    "avg_power_limit": ${avg_pl1:-45}
}
EOF
    
    log "Analysis complete: CPU avg=${avg_cpu_temp}°C max=${max_cpu_temp}°C"
    
    # Generate recommendations
    generate_recommendation "$game_name" "$avg_cpu_temp" "$max_cpu_temp" "$avg_pl1"
}

# Generate optimization recommendation
generate_recommendation() {
    local game_name=$1
    local avg_temp=$2
    local max_temp=$3
    local current_pl1=$4
    
    local recommended_pl1=$current_pl1
    local reason=""
    
    if [ "$max_temp" -gt "$THERMAL_THROTTLE_TEMP" ]; then
        # Too hot - reduce power
        recommended_pl1=$((current_pl1 - 10))
        reason="Thermal throttling detected (max ${max_temp}°C)"
    elif [ "$avg_temp" -gt "$MAX_ACCEPTABLE_TEMP" ]; then
        # Running hot - reduce power slightly
        recommended_pl1=$((current_pl1 - 5))
        reason="Running hot (avg ${avg_temp}°C > ${MAX_ACCEPTABLE_TEMP}°C)"
    elif [ "$avg_temp" -lt "$((TARGET_TEMP_GAMING - 10))" ] && [ "$current_pl1" -lt "$MAX_CPU_PL1" ]; then
        # Running cool - can increase power
        recommended_pl1=$((current_pl1 + 5))
        reason="Running cool (avg ${avg_temp}°C), can increase power for better performance"
    else
        reason="Current settings are optimal"
    fi
    
    # Clamp values
    [ "$recommended_pl1" -lt "$MIN_CPU_PL1" ] && recommended_pl1=$MIN_CPU_PL1
    [ "$recommended_pl1" -gt "$MAX_CPU_PL1" ] && recommended_pl1=$MAX_CPU_PL1
    
    # Save recommendation
    local rec_file="$DATA_DIR/recommendations/${game_name}_rec.json"
    cat > "$rec_file" << EOF
{
    "game": "$game_name",
    "timestamp": $(get_unix_time),
    "current_pl1": $current_pl1,
    "recommended_pl1": $recommended_pl1,
    "avg_temp": $avg_temp,
    "max_temp": $max_temp,
    "reason": "$reason",
    "auto_adjust": $AUTO_ADJUST
}
EOF
    
    log "Recommendation: $reason → PL1: ${current_pl1}W → ${recommended_pl1}W"
    
    # Notify user
    if [ "$NOTIFY_RECOMMENDATIONS" = "true" ] && [ "$recommended_pl1" -ne "$current_pl1" ]; then
        notify-send "🎮 Thermal Learning" "${game_name}: $reason
Recommended: ${recommended_pl1}W (was ${current_pl1}W)" -t 5000 2>/dev/null || true
    fi
    
    # Auto-adjust if enabled
    if [ "$AUTO_ADJUST" = "true" ] && [ "$recommended_pl1" -ne "$current_pl1" ]; then
        log "Auto-adjusting power limit to ${recommended_pl1}W"
        sudo -n tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value <<< "$recommended_pl1" > /dev/null 2>&1
    fi
}

# Main monitoring loop
run_daemon() {
    log "Thermal Learning Daemon started"
    log "Target temp: ${TARGET_TEMP_GAMING}°C, Max: ${MAX_ACCEPTABLE_TEMP}°C"
    
    local current_game=""
    local session_file=""
    local sample_count=0
    
    while true; do
        # Check if gaming
        local detected_game=$(detect_game)
        
        if [ -n "$detected_game" ]; then
            # Gaming detected
            if [ "$detected_game" != "$current_game" ]; then
                # New game started
                if [ -n "$session_file" ]; then
                    end_session "$session_file" "$current_game"
                fi
                current_game="$detected_game"
                session_file=$(start_session "$current_game")
                sample_count=0
            fi
            
            # Collect data
            if [ -n "$session_file" ]; then
                local sensor_data=$(collect_sensors)
                echo "$sensor_data" >> "$session_file"
                ((sample_count++))
            fi
        else
            # No game running
            if [ -n "$current_game" ]; then
                # Game ended
                end_session "$session_file" "$current_game"
                current_game=""
                session_file=""
                sample_count=0
            fi
        fi
        
        sleep $SAMPLE_INTERVAL
    done
}

# Show recommendations
show_recommendations() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     🎮 Adaptive Thermal Learning Recommendations         ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -d "$DATA_DIR/recommendations" ] || [ -z "$(ls -A "$DATA_DIR/recommendations" 2>/dev/null)" ]; then
        echo "No recommendations yet. Play some games first!"
        return
    fi
    
    for rec_file in "$DATA_DIR/recommendations"/*_rec.json; do
        if [ -f "$rec_file" ]; then
            local game=$(basename "$rec_file" _rec.json)
            echo -e "${YELLOW}Game: $game${NC}"
            
            if command -v jq &> /dev/null; then
                local current=$(jq -r '.current_pl1' "$rec_file")
                local recommended=$(jq -r '.recommended_pl1' "$rec_file")
                local reason=$(jq -r '.reason' "$rec_file")
                local temp=$(jq -r '.avg_temp' "$rec_file")
                
                echo "  Current PL1: ${current}W"
                echo "  Recommended: ${recommended}W"
                echo "  Avg Temp: ${temp}°C"
                echo "  Reason: $reason"
            else
                cat "$rec_file"
            fi
            echo ""
        fi
    done
}

# Show statistics
show_stats() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     📊 Thermal Learning Statistics                       ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo "Data Directory: $DATA_DIR"
    echo ""
    
    # Count sessions
    local session_count=$(ls -1 "$DATA_DIR/sessions"/*.jsonl 2>/dev/null | wc -l)
    echo "Total Sessions: $session_count"
    
    # Count games
    local game_count=$(ls -1 "$DATA_DIR/games"/*_analysis.json 2>/dev/null | wc -l)
    echo "Games Tracked: $game_count"
    echo ""
    
    # Show per-game stats
    if [ "$game_count" -gt 0 ]; then
        echo "Per-Game Analysis:"
        for analysis in "$DATA_DIR/games"/*_analysis.json; do
            if [ -f "$analysis" ]; then
                local game=$(basename "$analysis" _analysis.json)
                if command -v jq &> /dev/null; then
                    local avg_cpu=$(jq -r '.avg_cpu_temp' "$analysis")
                    local max_cpu=$(jq -r '.max_cpu_temp' "$analysis")
                    echo "  $game: Avg ${avg_cpu}°C, Max ${max_cpu}°C"
                fi
            fi
        done
    fi
}

# Apply recommendation for a game
apply_recommendation() {
    local game=$1
    local rec_file="$DATA_DIR/recommendations/${game}_rec.json"
    
    if [ ! -f "$rec_file" ]; then
        echo "No recommendation found for: $game"
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        local recommended=$(jq -r '.recommended_pl1' "$rec_file")
        echo "Applying recommended PL1: ${recommended}W for $game"
        sudo -n tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value <<< "$recommended" > /dev/null 2>&1
    fi
}

# Main command handler
main() {
    case "${1:-daemon}" in
        daemon|--daemon|-d)
            run_daemon
            ;;
        recommendations|--recommendations|-r)
            show_recommendations
            ;;
        stats|--stats|-s)
            show_stats
            ;;
        apply|--apply|-a)
            if [ -z "$2" ]; then
                echo "Usage: $0 apply <game_name>"
                exit 1
            fi
            apply_recommendation "$2"
            ;;
        export|--export|-e)
            echo "Exporting data to: $DATA_DIR/export.csv"
            echo "timestamp,cpu_temp,gpu_temp,gpu_power,gpu_util,cpu_pl1,cpu_pl2,fan1,fan2,profile" > "$DATA_DIR/export.csv"
            cat "$DATA_DIR/sessions"/*.jsonl 2>/dev/null | grep -v session >> "$DATA_DIR/export.csv"
            echo "Export complete"
            ;;
        help|--help|-h)
            echo "Adaptive Thermal Learning Daemon"
            echo ""
            echo "Usage:"
            echo "  $0 daemon          - Run the monitoring daemon"
            echo "  $0 recommendations - Show optimization recommendations"
            echo "  $0 stats           - Show learning statistics"
            echo "  $0 apply <game>    - Apply recommendation for game"
            echo "  $0 export          - Export data to CSV"
            echo ""
            echo "The daemon automatically monitors gameplay and learns"
            echo "optimal power limits for each game over time."
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage"
            exit 1
            ;;
    esac
}

main "$@"
