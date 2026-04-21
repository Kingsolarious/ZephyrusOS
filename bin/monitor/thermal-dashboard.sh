#!/bin/bash
# Thermal Learning Dashboard - Visualize and control adaptive optimization

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$HOME/.local/share/zephyrus-learning"
CONFIG_DIR="$HOME/.config/zephyrus-learning"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Draw a progress bar
draw_bar() {
    local value=$1
    local max=$2
    local width=30
    local label=$3
    
    local filled=$((width * value / max))
    local empty=$((width - filled))
    
    printf "  %-20s [" "$label"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%%\n" "$((100 * value / max))"
}

# Colorize temperature
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

# Show real-time dashboard
show_dashboard() {
    clear
    
    while true; do
        # Move cursor to top
        tput cup 0 0
        
        # Header
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        🎮 ROG ZEPHYRUS THERMAL LEARNING DASHBOARD               ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        # Current Status
        echo -e "${CYAN}📊 CURRENT SYSTEM STATUS${NC}"
        echo "═══════════════════════════════════════════════════════════════════"
        
        # Get current temps
        local cpu_temp=0
        for zone in /sys/class/thermal/thermal_zone*; do
            local type=$(cat "$zone/type" 2>/dev/null)
            if [ "$type" = "TCPU" ] || [ "$type" = "x86_pkg_temp" ]; then
                local temp=$(cat "$zone/temp" 2>/dev/null)
                cpu_temp=$((temp / 1000))
                break
            fi
        done
        
        # GPU info
        local gpu_temp=0
        local gpu_power=0
        local gpu_util=0
        if command -v nvidia-smi &> /dev/null; then
            local nvidia_data=$(nvidia-smi --query-gpu=temperature.gpu,power.draw,utilization.gpu --format=csv,noheader 2>/dev/null)
            gpu_temp=$(echo "$nvidia_data" | cut -d',' -f1 | tr -d ' ')
            gpu_power=$(echo "$nvidia_data" | cut -d',' -f2 | cut -d' ' -f2 | cut -d'.' -f1)
            gpu_util=$(echo "$nvidia_data" | cut -d',' -f3 | tr -d ' ')
        fi
        
        # Power limits
        local pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
        local pl2=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value 2>/dev/null)
        local gpu_tgp=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value 2>/dev/null)
        
        # Display
        printf "  CPU Temperature:    %b\n" "$(color_temp $cpu_temp)"
        printf "  GPU Temperature:    %b\n" "$(color_temp ${gpu_temp:-0})"
        echo ""
        printf "  CPU Power Limit:    ${YELLOW}%sW${NC} (PL1) / %sW (PL2)\n" "$pl1" "$pl2"
        printf "  GPU Power Limit:    ${YELLOW}%sW${NC}\n" "$gpu_tgp"
        printf "  GPU Power Draw:     %sW\n" "${gpu_power:-0}"
        printf "  GPU Utilization:    %s%%\n" "${gpu_util:-0}"
        echo ""
        
        # Visual bars
        draw_bar "$cpu_temp" 100 "CPU Temp"
        draw_bar "${gpu_temp:-0}" 100 "GPU Temp"
        draw_bar "$pl1" 80 "CPU Power"
        draw_bar "${gpu_power:-0}" "${gpu_tgp:-80}" "GPU Power"
        draw_bar "${gpu_util:-0}" 100 "GPU Util"
        
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        
        # Learning Stats
        echo -e "${CYAN}🧠 LEARNING STATISTICS${NC}"
        echo "═══════════════════════════════════════════════════════════════════"
        
        if [ -d "$DATA_DIR/sessions" ]; then
            local session_count=$(ls -1 "$DATA_DIR/sessions"/*.jsonl 2>/dev/null | wc -l)
            local game_count=$(ls -1 "$DATA_DIR/games"/*_analysis.json 2>/dev/null | wc -l)
            printf "  Sessions Recorded:  ${GREEN}%d${NC}\n" "$session_count"
            printf "  Games Analyzed:     ${GREEN}%d${NC}\n" "$game_count"
            
            if [ "$game_count" -gt 0 ]; then
                echo ""
                echo "  Learned Profiles:"
                for analysis in "$DATA_DIR/games"/*_analysis.json; do
                    if [ -f "$analysis" ]; then
                        local game=$(basename "$analysis" _analysis.json)
                        local avg_cpu=$(grep -oP '(?<="avg_cpu_temp":)[0-9]+' "$analysis" 2>/dev/null || echo 0)
                        local max_cpu=$(grep -oP '(?<="max_cpu_temp":)[0-9]+' "$analysis" 2>/dev/null || echo 0)
                        local pl=$(grep -oP '(?<="avg_power_limit":)[0-9]+' "$analysis" 2>/dev/null || echo 0)
                        printf "    %-20s Avg: %3s°C  Max: %3s°C  PL: %2sW\n" "$game" "$avg_cpu" "$max_cpu" "$pl"
                    fi
                done
            fi
        else
            echo "  No data yet. Start the learning daemon and play some games!"
        fi
        
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        
        # Recommendations
        echo -e "${CYAN}💡 CURRENT RECOMMENDATIONS${NC}"
        echo "═══════════════════════════════════════════════════════════════════"
        
        local has_recs=false
        for rec in "$DATA_DIR/recommendations"/*_rec.json; do
            if [ -f "$rec" ]; then
                has_recs=true
                local game=$(basename "$rec" _rec.json)
                local current=$(grep -oP '(?<="current_pl1":)[0-9]+' "$rec" 2>/dev/null || echo 0)
                local recommended=$(grep -oP '(?<="recommended_pl1":)[0-9]+' "$rec" 2>/dev/null || echo 0)
                local reason=$(grep -oP '(?<="reason":")[^"]+' "$rec" 2>/dev/null || echo "No reason")
                
                if [ "$recommended" -ne "$current" ]; then
                    echo -e "  ${YELLOW}$game:${NC}"
                    printf "    Current: %2dW → Recommended: %2dW\n" "$current" "$recommended"
                    echo "    Reason: $reason"
                    echo ""
                fi
            fi
        done
        
        if [ "$has_recs" = false ]; then
            echo "  No recommendations yet."
        fi
        
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo "  Press Ctrl+C to exit | Updates every 2 seconds"
        
        sleep 2
    done
}

# Show game-specific optimization menu
optimize_game_menu() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        🎮 PER-GAME OPTIMIZATION MENU                            ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ ! -d "$DATA_DIR/games" ] || [ -z "$(ls -A "$DATA_DIR/games" 2>/dev/null)" ]; then
        echo "No game data available. Play some games first!"
        return
    fi
    
    local games=()
    local i=1
    
    echo "Available Games:"
    echo ""
    for analysis in "$DATA_DIR/games"/*_analysis.json; do
        if [ -f "$analysis" ]; then
            local game=$(basename "$analysis" _analysis.json)
            games+=("$game")
            local avg_cpu=$(grep -oP '(?<="avg_cpu_temp":)[0-9]+' "$analysis" 2>/dev/null || echo 0)
            local recommended=$(grep -oP '(?<="recommended_pl1":)[0-9]+' "$DATA_DIR/recommendations/${game}_rec.json" 2>/dev/null || echo 0)
            printf "  %d) %-25s Avg: %3s°C  Rec: %2sW\n" "$i" "$game" "$avg_cpu" "$recommended"
            ((i++))
        fi
    done
    
    echo ""
    read -p "Select game (1-$((i-1))): " choice
    
    if [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
        local selected_game="${games[$((choice-1))]}"
        echo ""
        echo "Selected: $selected_game"
        echo ""
        echo "Options:"
        echo "  1) Apply recommended power limit"
        echo "  2) Set custom power limit"
        echo "  3) View detailed analysis"
        echo "  4) Create launcher with optimized settings"
        echo ""
        read -p "Select option: " opt
        
        case "$opt" in
            1)
                local rec=$(grep -oP '(?<="recommended_pl1":)[0-9]+' "$DATA_DIR/recommendations/${selected_game}_rec.json" 2>/dev/null)
                if [ -n "$rec" ]; then
                    echo "Applying ${rec}W power limit..."
                    sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value <<< "$rec" > /dev/null
                    echo "✓ Applied"
                fi
                ;;
            2)
                read -p "Enter CPU PL1 (25-80W): " custom_pl
                if [ "$custom_pl" -ge 25 ] && [ "$custom_pl" -le 80 ]; then
                    sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value <<< "$custom_pl" > /dev/null
                    echo "✓ Applied ${custom_pl}W"
                else
                    echo "Invalid value"
                fi
                ;;
            3)
                echo ""
                cat "$DATA_DIR/games/${selected_game}_analysis.json"
                ;;
            4)
                create_game_launcher "$selected_game"
                ;;
        esac
    fi
}

# Create optimized game launcher
create_game_launcher() {
    local game=$1
    local rec=$(grep -oP '(?<="recommended_pl1":)[0-9]+' "$DATA_DIR/recommendations/${game}_rec.json" 2>/dev/null || echo 55)
    
    local launcher_file="$HOME/.local/share/applications/${game}-optimized.desktop"
    
    cat > "$launcher_file" << EOF
[Desktop Entry]
Name=${game} (Optimized ${rec}W)
Comment=Launch ${game} with optimized thermal profile
Exec=bash -c 'sudo -n tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value <<< "${rec}" > /dev/null && notify-send "Thermal Profile" "${game}: ${rec}W applied" && steam steam://rungameid/$(grep -r "$game" ~/.steam/steam/userdata/*/config/localconfig.vdf 2>/dev/null | head -1 | grep -oP '\d+' | head -1)'
Type=Application
Terminal=false
Icon=applications-games
Categories=Game;
EOF
    
    echo "✓ Created optimized launcher: $launcher_file"
    echo "  Power limit: ${rec}W"
}

# Configure learning settings
configure_learning() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        ⚙️  LEARNING CONFIGURATION                               ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ -f "$CONFIG_DIR/settings.conf" ]; then
        echo "Current settings:"
        cat "$CONFIG_DIR/settings.conf"
        echo ""
    fi
    
    echo "Configure adaptive learning:"
    echo ""
    read -p "Target gaming temperature (default 78): " target_temp
    read -p "Maximum acceptable temperature (default 85): " max_temp
    read -p "Enable auto-adjustment? (true/false, default false): " auto_adjust
    read -p "Notify on recommendations? (true/false, default true): " notify
    
    # Update config
    cat > "$CONFIG_DIR/settings.conf" << EOF
# Adaptive Thermal Learning Settings

# Temperature thresholds (in Celsius)
TARGET_TEMP_GAMING=${target_temp:-78}
MAX_ACCEPTABLE_TEMP=${max_temp:-85}
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
MIN_SESSION_DURATION=300

# Auto-adjustment
AUTO_ADJUST=${auto_adjust:-false}
ADJUSTMENT_THRESHOLD=5
NOTIFY_RECOMMENDATIONS=${notify:-true}
EOF
    
    echo ""
    echo "✓ Configuration saved"
}

# Main menu
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        🎮 ROG THERMAL LEARNING SYSTEM                           ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "  1) 📊 Live Dashboard"
        echo "  2) 🎮 Per-Game Optimization"
        echo "  3) 💡 View Recommendations"
        echo "  4) 📈 View Statistics"
        echo "  5) ⚙️  Configure Learning"
        echo "  6) ▶️  Start Learning Daemon"
        echo "  7) ⏹️  Stop Learning Daemon"
        echo "  8) 📤 Export Data"
        echo "  9) ❌ Exit"
        echo ""
        read -p "Select option: " choice
        
        case "$choice" in
            1) show_dashboard ;;
            2) optimize_game_menu ;;
            3) "$SCRIPT_DIR/thermal-learning-daemon.sh" recommendations ;;
            4) "$SCRIPT_DIR/thermal-learning-daemon.sh" stats ;;
            5) configure_learning ;;
            6) 
                echo "Starting daemon..."
                nohup "$SCRIPT_DIR/thermal-learning-daemon.sh" daemon > /dev/null 2>&1 &
                echo "✓ Daemon started (PID: $!)"
                sleep 2
                ;;
            7)
                pkill -f "thermal-learning-daemon.sh"
                echo "✓ Daemon stopped"
                sleep 1
                ;;
            8) "$SCRIPT_DIR/thermal-learning-daemon.sh" export ;;
            9) exit 0 ;;
            *) echo "Invalid option" ; sleep 1 ;;
        esac
    done
}

# Main
case "${1:-menu}" in
    dashboard|d)
        show_dashboard
        ;;
    menu|m)
        main_menu
        ;;
    *)
        main_menu
        ;;
esac
