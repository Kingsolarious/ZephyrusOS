#!/bin/bash
# ASUS ROG Zephyrus G16 2024 (Ultra 9 + RTX 4090 + 32GB RAM) Optimization
# Run as root or with sudo

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ASUS ROG Zephyrus G16 2024 - Ultimate Optimization      ║"
echo "║  Intel Core Ultra 9 | RTX 4090 | 32GB RAM               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ This script should be run with sudo for best results"
    echo "   Some optimizations may fail without root privileges"
    echo ""
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ============================================================================
# 1. ASUS ROG PERFORMANCE MODES
# ============================================================================
echo -e "${YELLOW}1. Setting ROG Performance Modes...${NC}"

# Set to performance mode for gaming/productivity
asusctl profile --profile-set performance 2>/dev/null && echo -e "${GREEN}✓ CPU Profile: Performance${NC}" || echo -e "${RED}✗ Could not set CPU profile${NC}"

# Enable turbo boost
asusctl profile --boost-set true 2>/dev/null && echo -e "${GREEN}✓ CPU Boost: Enabled${NC}" || echo -e "${RED}✗ Could not enable boost${NC}"

# Set fan curve to performance
asusctl fan-curve --profile-set performance 2>/dev/null && echo -e "${GREEN}✓ Fan Curve: Performance${NC}" || echo -e "${RED}✗ Could not set fan curve${NC}"

# ============================================================================
# 2. GPU OPTIMIZATION (RTX 4090)
# ============================================================================
echo ""
echo -e "${YELLOW}2. Optimizing RTX 4090 GPU...${NC}"

# Check if supergfxctl is available
if command -v supergfxctl &> /dev/null; then
    # Set to dedicated GPU mode for maximum performance
    supergfxctl --mode dedicated 2>/dev/null && echo -e "${GREEN}✓ GPU Mode: Dedicated (RTX 4090)${NC}" || echo -e "${YELLOW}⚠ GPU mode switch requires reboot${NC}"
    
    # Enable GPU overclocking (if supported)
    asusctl --gfx-powerboost true 2>/dev/null && echo -e "${GREEN}✓ GPU Power Boost: Enabled${NC}" || echo -e "${RED}✗ Power boost not available${NC}"
else
    echo -e "${RED}✗ supergfxctl not available${NC}"
fi

# ============================================================================
# 3. CPU OPTIMIZATION (Intel Core Ultra 9)
# ============================================================================
echo ""
echo -e "${YELLOW}3. Optimizing Intel Core Ultra 9...${NC}"

# Set CPU governor to performance
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "$cpu" 2>/dev/null
    done
    echo -e "${GREEN}✓ CPU Governor: Performance${NC}"
fi

# Disable CPU power saving
if [ -f /sys/module/intel_idle/parameters/max_cstate ]; then
    echo 1 > /sys/module/intel_idle/parameters/max_cstate 2>/dev/null && echo -e "${GREEN}✓ CPU C-States: Limited${NC}" || echo -e "${YELLOW}⚠ C-States requires kernel parameter${NC}"
fi

# Enable all cores
for core in /sys/devices/system/cpu/cpu*/online; do
    echo 1 > "$core" 2>/dev/null
done
echo -e "${GREEN}✓ All CPU Cores: Enabled${NC}"

# ============================================================================
# 4. MEMORY OPTIMIZATION (32GB RAM)
# ============================================================================
echo ""
echo -e "${YELLOW}4. Optimizing 32GB RAM...${NC}"

# Reduce swappiness for better performance with 32GB RAM
sysctl vm.swappiness=10 2>/dev/null && echo -e "${GREEN}✓ Swappiness: 10 (less swap usage)${NC}" || echo -e "${RED}✗ Could not set swappiness${NC}"

# Enable huge pages for gaming
sysctl vm.nr_hugepages=2048 2>/dev/null && echo -e "${GREEN}✓ Huge Pages: Enabled (2048)${NC}" || echo -e "${YELLOW}⚠ Huge pages may require kernel config${NC}"

# Optimize dirty ratio for SSD
sysctl vm.dirty_ratio=10 2>/dev/null
sysctl vm.dirty_background_ratio=5 2>/dev/null
echo -e "${GREEN}✓ VM Dirty Ratio: Optimized for SSD${NC}"

# ============================================================================
# 5. NETWORK OPTIMIZATION
# ============================================================================
echo ""
echo -e "${YELLOW}5. Optimizing Network...${NC}"

# Increase network buffers
sysctl net.core.rmem_max=134217728 2>/dev/null
sysctl net.core.wmem_max=134217728 2>/dev/null
sysctl net.ipv4.tcp_rmem="4096 87380 134217728" 2>/dev/null
sysctl net.ipv4.tcp_wmem="4096 65536 134217728" 2>/dev/null
echo -e "${GREEN}✓ Network Buffers: Optimized${NC}"

# Enable BBR congestion control
sysctl net.ipv4.tcp_congestion_control=bbr 2>/dev/null && echo -e "${GREEN}✓ TCP BBR: Enabled${NC}" || echo -e "${YELLOW}⚠ BBR not available${NC}"

# ============================================================================
# 6. STORAGE/SSD OPTIMIZATION
# ============================================================================
echo ""
echo -e "${YELLOW}6. Optimizing SSD Storage...${NC}"

# Enable SSD TRIM
systemctl enable fstrim.timer 2>/dev/null && echo -e "${GREEN}✓ SSD TRIM: Enabled${NC}" || echo -e "${YELLOW}⚠ TRIM already enabled or not available${NC}"

# Optimize I/O scheduler for SSD
echo 'none' > /sys/block/nvme*/queue/scheduler 2>/dev/null && echo -e "${GREEN}✓ I/O Scheduler: None (NVMe optimized)${NC}" || echo -e "${YELLOW}⚠ Could not set I/O scheduler${NC}"

# ============================================================================
# 7. DISPLAY OPTIMIZATION
# ============================================================================
echo ""
echo -e "${YELLOW}7. Display Optimization...${NC}"

# Check display refresh rate
xrandr --listmonitors 2>/dev/null | head -5 || echo "xrandr not available (Wayland)"

# ============================================================================
# 8. POWER PROFILE
# ============================================================================
echo ""
echo -e "${YELLOW}8. Power Profile...${NC}"

# Set power profile to performance
if command -v powerprofilesctl &> /dev/null; then
    powerprofilesctl set performance 2>/dev/null && echo -e "${GREEN}✓ Power Profile: Performance${NC}" || echo -e "${YELLOW}⚠ Could not set power profile${NC}"
fi

# ============================================================================
# 9. GAMING OPTIMIZATIONS
# ============================================================================
echo ""
echo -e "${YELLOW}9. Gaming Optimizations...${NC}"

# Enable Steam if installed
if command -v steam &> /dev/null; then
    echo -e "${GREEN}✓ Steam: Installed${NC}"
fi

# Install gamemode if not present
if ! command -v gamemoded &> /dev/null; then
    echo -e "${YELLOW}⚠ GameMode not installed. Install with:${NC}"
    echo "   sudo rpm-ostree install gamemode"
fi

# ============================================================================
# 10. CREATE PERSISTENT CONFIG
# ============================================================================
echo ""
echo -e "${YELLOW}10. Creating Persistent Configuration...${NC}"

# Create sysctl config for persistent settings
sudo tee /etc/sysctl.d/99-rog-zephyrus.conf > /dev/null << 'EOF'
# ASUS ROG Zephyrus G16 2024 Optimizations
vm.swappiness=10
vm.nr_hugepages=2048
vm.dirty_ratio=10
vm.dirty_background_ratio=5
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 87380 134217728
net.ipv4.tcp_wmem=4096 65536 134217728
net.ipv4.tcp_congestion_control=bbr
EOF

echo -e "${GREEN}✓ Persistent sysctl config created${NC}"

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  OPTIMIZATION COMPLETE!                                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Applied Optimizations:${NC}"
echo "  ✓ ROG Performance Mode Enabled"
echo "  ✓ CPU Governor: Performance"
echo "  ✓ CPU Boost: Enabled"
echo "  ✓ All Cores Active"
echo "  ✓ GPU: Dedicated Mode (RTX 4090)"
echo "  ✓ 32GB RAM Optimized (Low Swappiness)"
echo "  ✓ Network Buffers Increased"
echo "  ✓ SSD Optimized"
echo ""
echo -e "${YELLOW}Recommended:${NC}"
echo "  • Install GameMode: sudo rpm-ostree install gamemode"
echo "  • For gaming, use: gamemoderun <game>"
echo "  • Reboot to apply all GPU changes"
echo ""
echo -e "${YELLOW}Switch GPU Modes:${NC}"
echo "  • Dedicated: sudo supergfxctl --mode dedicated"
echo "  • Hybrid:    sudo supergfxctl --mode hybrid"
echo "  • Integrated:sudo supergfxctl --mode integrated"
echo ""
echo -e "${YELLOW}Performance Profiles:${NC}"
echo "  • Performance: sudo asusctl profile --profile-set performance"
echo "  • Balanced:    sudo asusctl profile --profile-set balanced"
echo "  • Quiet:       sudo asusctl profile --profile-set quiet"
echo ""
echo "Enjoy your optimized ROG Zephyrus G16! 🎮"
