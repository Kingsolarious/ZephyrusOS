#!/bin/bash
# Rebase to Bazzite NVIDIA and restore customizations

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Rebase to Bazzite NVIDIA + Restore Customizations       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}This will:${NC}"
echo "  1. Rebase to ghcr.io/ublue-os/bazzite-nvidia:stable"
echo "  2. Keep your current customizations (asusctl, supergfxctl)"
echo "  3. Your macOS theme and dock setup will remain"
echo ""

read -p "Continue? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Step 1: Rebase to Bazzite NVIDIA...${NC}"
echo ""

sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}✗ Rebase failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Rebase staged successfully!${NC}"
echo ""

# Create post-reboot setup script
cat > ~/Desktop/Zephyrus\ OS/post-nvidia-reboot.sh << 'POSTSCRIPT'
#!/bin/bash
# Post-reboot setup after NVIDIA rebase

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Post-Reboot NVIDIA Setup                                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if NVIDIA driver loaded
if [ -f /proc/driver/nvidia/version ]; then
    echo "✓ NVIDIA driver loaded!"
    cat /proc/driver/nvidia/version | head -1
else
    echo "✗ NVIDIA driver not loaded yet (may need another reboot)"
fi

echo ""
echo "Installing customizations..."

# Re-add your custom rog-control-center
cd ~/Desktop/asusctl-gu605my-fork-20260303-173948 2>/dev/null && ./INSTALL.sh 2>/dev/null && echo "✓ Custom rog-control-center installed"

# Check supergfxctl
if command -v supergfxctl &> /dev/null; then
    echo "✓ supergfxctl available"
    sudo systemctl enable --now supergfxd 2>/dev/null
    supergfxctl --mode hybrid 2>/dev/null
    echo "✓ GPU mode set to hybrid"
else
    echo "Installing supergfxctl..."
    sudo rpm-ostree install supergfxctl
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  DONE!                                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "External displays should now work!"
echo "Connect your monitor and run: kscreen-doctor --outputs"
POSTSCRIPT

chmod +x ~/Desktop/Zephyrus\ OS/post-nvidia-reboot.sh

echo -e "${YELLOW}IMPORTANT: You must REBOOT to activate the new image${NC}"
echo ""
echo "After reboot, run:"
echo "  ${GREEN}~/Desktop/Zephyrus\\ OS/post-nvidia-reboot.sh${NC}"
echo ""

read -p "Reboot now? (y/N): " reboot
if [[ $reboot =~ ^[Yy]$ ]]; then
    reboot
fi
