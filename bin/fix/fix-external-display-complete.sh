#!/bin/bash
# Complete External Monitor Fix for ASUS ROG Zephyrus with NVIDIA

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  External Monitor Fix - NVIDIA Driver Installation       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if Bazzite
if [ ! -f /run/ostree-booted ]; then
    echo -e "${RED}This script is designed for Bazzite (ostree) systems.${NC}"
    echo "For standard Fedora, use: sudo dnf install akmod-nvidia xorg-x11-drv-nvidia"
    exit 1
fi

echo -e "${BLUE}Detected Bazzite system${NC}"
echo ""

# =============================================================================
# STEP 1: CHECK CURRENT STATE
# =============================================================================
echo -e "${YELLOW}=== Checking Current GPU Status ===${NC}"
echo ""

if [ -f /proc/driver/nvidia/version ]; then
    echo -e "${GREEN}✓ NVIDIA proprietary driver already loaded${NC}"
    cat /proc/driver/nvidia/version | head -1
    DRIVER_INSTALLED=1
else
    echo -e "${RED}✗ NVIDIA proprietary driver NOT loaded${NC}"
    echo "  Only nouveau (open-source) driver present"
    echo "  External displays will NOT work until fixed"
    DRIVER_INSTALLED=0
fi

echo ""

if command -v supergfxctl &> /dev/null; then
    echo -e "${GREEN}✓ supergfxctl installed${NC}"
    echo "  Current mode: $(supergfxctl --status 2>/dev/null || echo 'Unknown')"
    SUPERGFX_INSTALLED=1
else
    echo -e "${RED}✗ supergfxctl NOT installed${NC}"
    SUPERGFX_INSTALLED=0
fi

echo ""

# =============================================================================
# STEP 2: INSTALL NVIDIA DRIVER
# =============================================================================
if [ "$DRIVER_INSTALLED" -eq 0 ]; then
    echo -e "${YELLOW}=== Installing NVIDIA Proprietary Driver ===${NC}"
    echo ""
    echo "This is REQUIRED for external monitor support."
    echo "The installation will take several minutes..."
    echo ""
    echo -e "${BLUE}Running: sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia${NC}"
    echo ""
    
    read -p "Proceed with installation? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓ NVIDIA driver installed successfully${NC}"
            REBOOT_REQUIRED=1
        else
            echo ""
            echo -e "${RED}✗ Installation failed${NC}"
            exit 1
        fi
    else
        echo "Installation cancelled."
        exit 0
    fi
else
    echo -e "${GREEN}✓ NVIDIA driver already installed${NC}"
    REBOOT_REQUIRED=0
fi

echo ""

# =============================================================================
# STEP 3: INSTALL ASUS LINUX TOOLS
# =============================================================================
if [ "$SUPERGFX_INSTALLED" -eq 0 ]; then
    echo -e "${YELLOW}=== Installing ASUS Linux Tools ===${NC}"
    echo ""
    echo "These tools allow GPU switching (hybrid/integrated/dedicated modes)"
    echo ""
    echo -e "${BLUE}Running: sudo rpm-ostree install asusctl supergfxctl${NC}"
    echo ""
    
    read -p "Proceed with installation? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        sudo rpm-ostree install asusctl supergfxctl
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓ ASUS Linux tools installed${NC}"
            REBOOT_REQUIRED=1
        else
            echo ""
            echo -e "${RED}✗ Installation failed${NC}"
        fi
    else
        echo "Installation cancelled."
    fi
else
    echo -e "${GREEN}✓ ASUS Linux tools already installed${NC}"
fi

echo ""

# =============================================================================
# STEP 4: POST-REBOOT SETUP (Create script to run after reboot)
# =============================================================================
echo -e "${YELLOW}=== Creating Post-Reboot Setup Script ===${NC}"
echo ""

cat > ~/Desktop/Zephyrus\ OS/post-reboot-gpu-setup.sh << 'POSTSCRIPT'
#!/bin/bash
# Run this after rebooting to complete GPU setup

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Post-Reboot GPU Setup                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Enable supergfxd
if command -v supergfxctl &> /dev/null; then
    echo "Enabling supergfxd service..."
    sudo systemctl enable --now supergfxd
    echo "✓ supergfxd enabled"
    
    echo ""
    echo "Setting GPU mode to HYBRID (recommended)..."
    sudo supergfxctl --mode hybrid
    echo "✓ GPU mode set to hybrid"
    
    echo ""
    echo "Current status:"
    supergfxctl --status
else
    echo "supergfxctl not found. Did you install ASUS Linux tools?"
fi

echo ""
echo "You can now connect your external monitor!"
echo ""
echo "GPU Modes:"
echo "  supergfxctl --mode hybrid     - Best balance (recommended)"
echo "  supergfxctl --mode dedicated  - Always use NVIDIA (more power)"
echo "  supergfxctl --mode integrated - Intel only (save battery)"
POSTSCRIPT

chmod +x ~/Desktop/Zephyrus\ OS/post-reboot-gpu-setup.sh

echo -e "${GREEN}✓ Created post-reboot setup script${NC}"
echo "  Location: ~/Desktop/Zephyrus OS/post-reboot-gpu-setup.sh"
echo ""

# =============================================================================
# STEP 5: SUMMARY
# =============================================================================
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  INSTALLATION SUMMARY                                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

if [ "$REBOOT_REQUIRED" -eq 1 ]; then
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT: You MUST reboot to activate the NVIDIA driver${NC}"
    echo ""
    echo "After reboot, run:"
    echo "  ${GREEN}~/Desktop/Zephyrus\ OS/post-reboot-gpu-setup.sh${NC}"
    echo ""
    echo "This will:"
    echo "  1. Enable supergfxd service"
    echo "  2. Set GPU mode to HYBRID (best for external displays)"
    echo ""
    echo "Then connect your external monitor!"
    echo ""
    
    read -p "Reboot now? (y/N): " reboot
    if [[ $reboot == [yY] ]]; then
        echo "Rebooting in 5 seconds..."
        sleep 5
        reboot
    else
        echo ""
        echo "Remember to reboot later and run the post-reboot script!"
    fi
else
    echo -e "${GREEN}Everything is already installed!${NC}"
    echo ""
    
    if command -v supergfxctl &> /dev/null; then
        echo "Current GPU mode:"
        supergfxctl --status
        echo ""
        echo "To switch modes:"
        echo "  ${GREEN}supergfxctl --mode hybrid${NC}     (recommended)"
        echo "  ${GREEN}supergfxctl --mode dedicated${NC}  (always NVIDIA)"
        echo "  ${GREEN}supergfxctl --mode integrated${NC} (Intel only)"
    fi
    
    echo ""
    echo "Try connecting your external monitor now!"
fi

echo ""
