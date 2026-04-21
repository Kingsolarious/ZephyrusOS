#!/bin/bash
# Advanced Thermal Throttle Fix for ROG Zephyrus G16
# Addresses CPU thermal throttling during emulation/gaming

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🔥 THERMAL THROTTLE FIX FOR ZEPHYRUS G16            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check current thermal state
echo -e "${YELLOW}Current Thermal State:${NC}"
echo "------------------------"

# Get all core temps
echo "CPU Core Temperatures:"
for i in /sys/class/thermal/thermal_zone*; do
    type=$(cat $i/type 2>/dev/null)
    if [[ "$type" == *"x86_pkg_temp"* ]] || [[ "$type" == *"TCPU"* ]]; then
        temp=$(cat $i/temp 2>/dev/null)
        temp_c=$((temp / 1000))
        echo "  Package: ${temp_c}°C"
    fi
done

# Check throttling status
if [ -f /sys/devices/system/cpu/cpu0/thermal_throttle/core_throttle_count ]; then
    throttle_count=$(cat /sys/devices/system/cpu/cpu0/thermal_throttle/core_throttle_count 2>/dev/null)
    echo "  Throttle Events: $throttle_count"
fi

# Get power limits
pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
pl2=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value 2>/dev/null)
echo "  Power Limits: ${pl1}W / ${pl2}W"
echo ""

# Menu
echo -e "${YELLOW}Select Optimization Strategy:${NC}"
echo ""
echo "1) 🎮 GAMING MODE - Aggressive cooling, sustained 50W"
echo "   Best for: Emulation, AAA games"
echo "   Target: 85°C max, stable clocks"
echo ""
echo "2) 🔄 EMULATION MODE - 40W sustained, 30 FPS target"
echo "   Best for: Ryujinx, Xenia, Yuzu"
echo "   Target: 80°C, no throttling"
echo ""
echo "3) ❄️  MAX COOLING - 35W limit, ultra-cool"
echo "   Best for: Silent gaming, long sessions"
echo "   Target: 75°C"
echo ""
echo "4) 🔧 CUSTOM - Set your own power limit"
echo ""
echo "5) 📊 UNDERVOLT (Advanced) - Reduce voltage for less heat"
echo ""
read -p "Select option [1-5]: " choice

case $choice in
    1)
        echo -e "${GREEN}Applying GAMING MODE...${NC}"
        # Set 50W sustained with 70W boost - sweet spot for thermals
        echo 50 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value > /dev/null
        echo 70 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value > /dev/null
        echo 75 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl3_fppt/current_value > /dev/null
        echo 75 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value > /dev/null
        
        # Aggressive fans
        sudo asusctl fan-curve --enable 2>/dev/null
        sudo asusctl fan-curve --profile-set performance 2>/dev/null
        
        # CPU governor
        echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
        
        echo "✓ GAMING MODE: 50W sustained, 70W boost"
        echo "✓ Target: 85°C sustained gaming"
        ;;
        
    2)
        echo -e "${GREEN}Applying EMULATION MODE...${NC}"
        # Lower sustained power for emulation (CPU heavy, not GPU)
        echo 40 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value > /dev/null
        echo 55 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value > /dev/null
        echo 65 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl3_fppt/current_value > /dev/null
        echo 60 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value > /dev/null
        
        # Balanced fans (less noise, adequate cooling)
        sudo asusctl fan-curve --enable 2>/dev/null
        sudo asusctl fan-curve --profile-set balanced 2>/dev/null
        
        # Schedutil for efficiency
        echo "schedutil" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
        
        echo "✓ EMULATION MODE: 40W sustained"
        echo "✓ Target: 80°C, stable emulation"
        echo ""
        echo -e "${YELLOW}Recommendation:${NC} Cap emulator to 30 FPS for best experience"
        ;;
        
    3)
        echo -e "${GREEN}Applying MAX COOLING...${NC}"
        # Ultra-cool mode
        echo 35 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value > /dev/null
        echo 45 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value > /dev/null
        echo 55 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl3_fppt/current_value > /dev/null
        echo 50 | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value > /dev/null
        
        # Max fans
        sudo asusctl fan-curve --enable 2>/dev/null
        sudo asusctl fan-curve --profile-set performance 2>/dev/null
        
        echo "✓ MAX COOLING: 35W limit"
        echo "✓ Target: 75°C, ultra-quiet operation"
        ;;
        
    4)
        read -p "Enter CPU PL1 (25-65W): " custom_pl1
        read -p "Enter CPU PL2 (35-95W): " custom_pl2
        
        echo "$custom_pl1" | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value > /dev/null
        echo "$custom_pl2" | sudo tee /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value > /dev/null
        
        echo "✓ CUSTOM: ${custom_pl1}W / ${custom_pl2}W"
        ;;
        
    5)
        echo -e "${YELLOW}Undervolting Setup:${NC}"
        echo "------------------------"
        echo "This requires intel-undervolt or similar tools."
        echo ""
        echo "Recommended starting values for Core Ultra 9:"
        echo "  CPU Core: -50mV to -80mV"
        echo "  CPU Cache: -50mV to -80mV"
        echo "  GPU: -25mV to -50mV"
        echo ""
        echo "Installing intel-undervolt..."
        
        # Check if we can install
        if command -v rpm-ostree &> /dev/null; then
            echo "This is an OSTree system. Intel-undervolt needs to be layered:"
            echo "  sudo rpm-ostree install intel-undervolt"
            echo "  reboot"
        else
            sudo dnf install intel-undervolt -y 2>/dev/null || echo "Could not install automatically"
        fi
        ;;
        
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}══════════════════════════════════════════════════════════${NC}"
echo "New power limits applied!"
echo ""
echo "Monitor with: watch -n 1 sensors"
echo ""
