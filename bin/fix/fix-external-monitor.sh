#!/bin/bash
# Fix External Monitor on ASUS ROG Zephyrus with NVIDIA GPU
# This script helps diagnose and fix external display issues

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  External Monitor Fix for Zephyrus NVIDIA Laptops        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running on Bazzite/ostree system
if [ -f /run/ostree-booted ]; then
    IS_OSTREE=true
    echo -e "${BLUE}Detected Bazzite (ostree) system${NC}"
else
    IS_OSTREE=false
    echo -e "${BLUE}Detected standard Fedora system${NC}"
fi

# =============================================================================
# 1. DIAGNOSE CURRENT STATE
# =============================================================================
echo ""
echo -e "${YELLOW}=== DIAGNOSING CURRENT STATE ===${NC}"

echo ""
echo "GPU Status:"
echo "  Internal (iGPU): $(lspci | grep -i vga | grep -i intel | cut -d':' -f3 || echo 'Not found')"
echo "  External (dGPU): $(lspci | grep -i vga | grep -i nvidia | cut -d':' -f3 || echo 'Not found')"

echo ""
echo "Current GPU in use:"
glxinfo 2>/dev/null | grep "OpenGL renderer" || echo "  Unknown"

echo ""
echo "NVIDIA Driver:"
if [ -f /proc/driver/nvidia/version ]; then
    echo -e "  ${GREEN}Proprietary driver loaded${NC}"
    cat /proc/driver/nvidia/version | head -1
else
    echo -e "  ${RED}Proprietary driver NOT loaded${NC}"
    echo "  Only nouveau (open-source) driver present"
fi

echo ""
echo "External Display Ports:"
for f in /sys/class/drm/card*-*; do
    if [[ "$(basename $f)" != *"eDP"* ]]; then
        status=$(cat $f/status 2>/dev/null)
        echo "  $(basename $f): $status"
    fi
done

echo ""
echo "ASUS Linux Tools:"
if command -v asusctl &> /dev/null; then
    echo -e "  ${GREEN}asusctl installed${NC}"
else
    echo -e "  ${RED}asusctl NOT installed${NC}"
fi

if command -v supergfxctl &> /dev/null; then
    echo -e "  ${GREEN}supergfxctl installed${NC}"
    echo "  Current mode: $(supergfxctl --status 2>/dev/null || echo 'Unknown')"
else
    echo -e "  ${RED}supergfxctl NOT installed${NC}"
fi

# =============================================================================
# 2. INSTALL REQUIRED COMPONENTS
# =============================================================================
echo ""
echo -e "${YELLOW}=== INSTALLATION OPTIONS ===${NC}"
echo ""

if [ "$IS_OSTREE" = true ]; then
    echo -e "${BLUE}For Bazzite (rpm-ostree):${NC}"
    echo ""
    echo "1. Install NVIDIA driver (required for external displays on dGPU ports):"
    echo "   ${GREEN}sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia${NC}"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   ${GREEN}sudo rpm-ostree install asusctl supergfxctl${NC}"
    echo ""
    echo "3. After installation, reboot and run:"
    echo "   ${GREEN}sudo systemctl enable --now supergfxd${NC}"
    echo ""
else
    echo -e "${BLUE}For standard Fedora:${NC}"
    echo ""
    echo "1. Install NVIDIA driver:"
    echo "   ${GREEN}sudo dnf install akmod-nvidia xorg-x11-drv-nvidia${NC}"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   ${GREEN}sudo dnf install asusctl supergfxctl${NC}"
    echo ""
    echo "3. After installation, reboot and run:"
    echo "   ${GREEN}sudo systemctl enable --now supergfxd${NC}"
fi

# =============================================================================
# 3. QUICK FIXES TO TRY NOW
# =============================================================================
echo ""
echo -e "${YELLOW}=== QUICK FIXES TO TRY NOW ===${NC}"
echo ""

# Check if we can detect any displays
echo "Checking for connected displays..."
CONNECTED_DISPLAYS=$(kscreen-doctor --outputs 2>/dev/null | grep -c "connected" || echo "0")
if [ "$CONNECTED_DISPLAYS" -gt "1" ]; then
    echo -e "${GREEN}Found $CONNECTED_DISPLAYS connected displays!${NC}"
    echo "External monitor detected but may need configuration."
else
    echo -e "${RED}Only internal display detected${NC}"
fi

echo ""
echo -e "${BLUE}Quick fixes to try:${NC}"
echo ""
echo "1. Check cable connection:"
echo "   - Try a different cable/adapter"
echo "   - Make sure monitor is powered on and set to correct input"
echo "   - For USB-C to DisplayPort, ensure cable supports DP Alt Mode"
echo ""

echo "2. Restart display manager:"
echo "   ${GREEN}sudo systemctl restart sddm${NC}"
echo ""

echo "3. Check if display is disabled in KDE:"
echo "   Open System Settings → Display & Monitor → Displays"
echo "   Look for disabled outputs and enable them"
echo ""

echo "4. Force display detection (run this after connecting monitor):"
echo "   ${GREEN}kscreen-doctor --outputs${NC}"
echo ""

# =============================================================================
# 4. GPU MODE EXPLANATION
# =============================================================================
echo ""
echo -e "${YELLOW}=== UNDERSTANDING GPU MODES ===${NC}"
echo ""
echo "Your laptop has hybrid graphics (Intel + NVIDIA)."
echo "External ports (HDMI/USB-C) are usually wired to the NVIDIA GPU."
echo ""
echo "GPU Modes (requires supergfxctl):"
echo "  ${GREEN}Hybrid${NC}     - Uses Intel for desktop, NVIDIA for demanding apps (recommended)"
echo "  ${GREEN}Dedicated${NC}  - Uses NVIDIA for everything (more power, external displays work)"
echo "  ${GREEN}Integrated${NC} - Uses Intel only (saves battery, external displays may not work)"
echo ""
echo "Once supergfxctl is installed, switch modes:"
echo "  ${GREEN}supergfxctl --mode hybrid${NC}"
echo "  ${GREEN}supergfxctl --mode dedicated${NC}"
echo "  ${GREEN}supergfxctl --mode integrated${NC}"
echo ""

# =============================================================================
# 5. MANUAL DISPLAY CONFIGURATION
# =============================================================================
echo ""
echo -e "${YELLOW}=== MANUAL DISPLAY CONFIGURATION ===${NC}"
echo ""
echo "If monitor is connected but not showing:"
echo ""
echo "1. List all outputs:"
echo "   ${GREEN}kscreen-doctor --outputs${NC}"
echo ""
echo "2. Enable a specific output (replace DP-1 with your output):"
echo "   ${GREEN}kscreen-doctor output.DP-1.enable${NC}"
echo ""
echo "3. Set resolution (example):"
echo "   ${GREEN}kscreen-doctor output.DP-1.mode.1920x1080@60${NC}"
echo ""
echo "4. Position displays (example):"
echo "   ${GREEN}kscreen-doctor output.eDP-1.position.0,0 output.DP-1.position.1920,0${NC}"
echo ""

# =============================================================================
# 6. CREATE AUTOSTART SCRIPT FOR MONITOR DETECTION
# =============================================================================
echo ""
echo -e "${YELLOW}=== AUTOMATED MONITOR DETECTION ===${NC}"
echo ""

mkdir -p ~/.config/autostart

cat > ~/.config/autostart/monitor-detect.desktop << 'EOF'
[Desktop Entry]
Name=Monitor Auto-Detect
Comment=Auto-detect external monitors on login
Exec=/bin/bash -c "sleep 5 && kscreen-doctor --outputs"
Type=Application
Terminal=false
Hidden=false
X-KDE-autostart-phase=2
EOF

echo -e "${GREEN}Created autostart entry for monitor detection${NC}"
echo "This will refresh display outputs 5 seconds after login."
echo ""

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  SUMMARY & NEXT STEPS                                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo -e "${BLUE}Most likely cause:${NC}"
echo "  NVIDIA proprietary driver not installed/loaded"
echo "  OR supergfxctl not configured for hybrid graphics"
echo ""

echo -e "${BLUE}Recommended next steps:${NC}"
echo ""

if [ "$IS_OSTREE" = true ]; then
    echo "1. Install NVIDIA driver (will require reboot):"
    echo "   ${GREEN}sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia${NC}"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   ${GREEN}sudo rpm-ostree install asusctl supergfxctl${NC}"
    echo ""
    echo "3. Reboot the system"
    echo ""
    echo "4. Enable supergfxd:"
    echo "   ${GREEN}sudo systemctl enable --now supergfxd${NC}"
    echo ""
    echo "5. Set hybrid mode:"
    echo "   ${GREEN}supergfxctl --mode hybrid${NC}"
else
    echo "1. Install NVIDIA driver:"
    echo "   ${GREEN}sudo dnf install akmod-nvidia xorg-x11-drv-nvidia${NC}"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   ${GREEN}sudo dnf install asusctl supergfxctl${NC}"
    echo ""
    echo "3. Reboot the system"
    echo ""
    echo "4. Enable supergfxd:"
    echo "   ${GREEN}sudo systemctl enable --now supergfxd${NC}"
    echo ""
    echo "5. Set hybrid mode:"
    echo "   ${GREEN}supergfxctl --mode hybrid${NC}"
fi

echo ""
echo -e "${YELLOW}Alternative if you need external monitor NOW:${NC}"
echo "  Try connecting to the laptop before booting"
echo "  The BIOS/UEFI might initialize the external display"
echo ""
