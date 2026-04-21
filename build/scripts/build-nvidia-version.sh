#!/bin/bash
# Build and Install Zephyrus OS with NVIDIA Support

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Build Zephyrus OS with NVIDIA Support                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$(dirname "$0")"

# Check if running from Zephyrus OS directory
if [ ! -f "Containerfile.nvidia" ]; then
    echo "Error: Containerfile.nvidia not found!"
    echo "Please run this script from the Zephyrus OS directory."
    exit 1
fi

echo -e "${BLUE}This will build a new Zephyrus OS image with NVIDIA support.${NC}"
echo ""
echo "Key changes:"
echo "  • Base image: ghcr.io/ublue-os/bazzite-nvidia:stable"
echo "  • Includes: NVIDIA proprietary driver (akmod-nvidia)"
echo "  • Includes: supergfxctl for GPU switching"
echo "  • Your setup (macOS theme, dock, etc.) will be preserved"
echo ""

read -p "Continue? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Step 1: Building NVIDIA image...${NC}"
echo "This will take several minutes..."
echo ""

# Build the NVIDIA image
podman build -f Containerfile.nvidia -t zephyrus-os-nvidia:latest . 2>&1 | tee /tmp/zephyrus-nvidia-build.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo -e "${RED}✗ Build failed!${NC}"
    echo "Check the log: /tmp/zephyrus-nvidia-build.log"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Build successful!${NC}"
echo ""

# Export the image for local installation
echo -e "${YELLOW}Step 2: Exporting image for installation...${NC}"
mkdir -p /var/tmp/zephyrus-nvidia-export
podman push zephyrus-os-nvidia:latest dir:/var/tmp/zephyrus-nvidia-export

echo ""
echo -e "${GREEN}✓ Image exported${NC}"
echo ""

# Create installation script
cat > /tmp/install-zephyrus-nvidia.sh << 'INSTALLSCRIPT'
#!/bin/bash
# Install Zephyrus OS with NVIDIA support

echo "Installing Zephyrus OS with NVIDIA support..."
echo ""

# Rebase to the new image
sudo rpm-ostree rebase ostree-unverified-image:dir:/var/tmp/zephyrus-nvidia-export

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Installation staged successfully!"
    echo ""
    echo "IMPORTANT: You must REBOOT to activate the new image."
    echo ""
    read -p "Reboot now? (y/N): " reboot
    if [[ $reboot =~ ^[Yy]$ ]]; then
        reboot
    fi
else
    echo "✗ Installation failed!"
    exit 1
fi
INSTALLSCRIPT

chmod +x /tmp/install-zephyrus-nvidia.sh

echo -e "${YELLOW}Step 3: Ready to install!${NC}"
echo ""
echo "To install the new image, run:"
echo "  ${GREEN}sudo /tmp/install-zephyrus-nvidia.sh${NC}"
echo ""
echo "Or manually:"
echo "  ${GREEN}sudo rpm-ostree rebase ostree-unverified-image:dir:/var/tmp/zephyrus-nvidia-export${NC}"
echo ""
echo -e "${BLUE}After reboot:${NC}"
echo "  1. External displays should work via HDMI/USB-C"
echo "  2. Run: supergfxctl --status"
echo "  3. GPU switching: supergfxctl --mode hybrid"
echo ""
echo "Your current setup (macOS theme, dock, etc.) will be preserved!"
echo ""
