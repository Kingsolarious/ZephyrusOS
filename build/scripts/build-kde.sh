#!/bin/bash
# Build Zephyrus Crimson OS - KDE Edition
# This creates a custom OSTree image with KDE Plasma + ROG branding

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Build configuration
BUILD_DATE=$(date +%Y%m%d)
VERSION="2.0.0-kde-${BUILD_DATE}"
IMAGE_NAME="zephyrus-crimson-kde"
CONTAINERFILE="Containerfile.kde"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ZEPHYRUS CRIMSON OS - KDE EDITION BUILD                  ║${NC}"
echo -e "${BLUE}║  ROG Branding + KDE Plasma 6                              ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify we're on the host (not in a container)
if [ -n "$TOOLBOX_PATH" ] || [ -f "/run/.containerenv" ]; then
    echo -e "${RED}❌ ERROR: You're in a container!${NC}"
    echo "Run this script on the host system."
    exit 1
fi

# Check for podman
if ! command -v podman &>/dev/null; then
    echo -e "${RED}❌ podman is required but not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Host system detected${NC}"
echo -e "${GREEN}✓ Podman available${NC}"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Verify Containerfile exists
if [ ! -f "os-build/$CONTAINERFILE" ]; then
    echo -e "${RED}❌ Containerfile.kde not found!${NC}"
    exit 1
fi

echo -e "${BLUE}Build Configuration:${NC}"
echo "  Version: $VERSION"
echo "  Image: $IMAGE_NAME"
echo "  Date: $BUILD_DATE"
echo "  Directory: $PROJECT_ROOT"
echo ""

# Check if required directories exist
echo -e "${BLUE}Checking project structure...${NC}"

for dir in zephyrus-about zephyrus-desktop icons kde-setup plymouth; do
    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir/"
    else
        echo -e "  ${YELLOW}⚠${NC} $dir/ (will be created if needed)"
        mkdir -p "$dir"
    fi
done

echo ""

# Stage custom asusctl source for container build (exclude .git)
if [ -d "/home/solarious/asusctl" ]; then
    echo -e "${BLUE}Staging custom asusctl source...${NC}"
    mkdir -p "$PROJECT_ROOT/custom-asusctl"
    rsync -a --exclude='.git' "/home/solarious/asusctl/" "$PROJECT_ROOT/custom-asusctl/"
fi

# Build the image
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Starting Build...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "This will take 10-30 minutes depending on your system."
echo ""

# Pull the base image first
echo -e "${YELLOW}Pulling base image (bazzite:stable)...${NC}"
podman pull ghcr.io/ublue-os/bazzite:stable || {
    echo -e "${RED}Failed to pull base image${NC}"
    echo "Make sure you have internet connection."
    exit 1
}

# Build the custom image
echo -e "${YELLOW}Building Zephyrus Crimson KDE image...${NC}"
podman build \
    -f os-build/$CONTAINERFILE \
    -t "$IMAGE_NAME:$VERSION" \
    -t "$IMAGE_NAME:latest" \
    --build-arg ZEPHYRUS_VERSION="$VERSION" \
    --build-arg ZEPHYRUS_BUILD_DATE="$BUILD_DATE" \
    "$PROJECT_ROOT"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build completed successfully!${NC}"
echo ""

# Export the image for installation
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Exporting Image...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

EXPORT_DIR="/var/tmp"
EXPORT_FILE="$EXPORT_DIR/zephyrus-crimson-kde-$VERSION.tar"

echo -e "${YELLOW}Exporting container to OSTree format...${NC}"
podman push "$IMAGE_NAME:$VERSION" "dir:$EXPORT_DIR/zephyrus-kde-export" --remove-signatures

echo -e "${GREEN}✓ Image exported${NC}"
echo ""

# Show summary
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  BUILD COMPLETE!                                          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Image: $IMAGE_NAME:$VERSION"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "NEXT STEPS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Rebase to your new KDE image:"
echo ""
echo "   sudo rpm-ostree rebase ostree-unverified-image:dir:$EXPORT_DIR/zephyrus-kde-export"
echo ""
echo "2. Reboot:"
echo ""
echo "   sudo systemctl reboot"
echo ""
echo "3. After reboot into KDE, run:"
echo ""
echo "   cd ~/Desktop/Zephyrus\\ OS"
echo "   ./kde-setup/scripts/install-kde-zephyrus.sh"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}Note: Your personal data in /home is preserved automatically${NC}"
echo -e "${YELLOW}      when rebasing to the new image.${NC}"
echo ""

# Ask to rebase now
read -p "Rebase to the new KDE image now? (y/N): " rebase_now
if [[ "$rebase_now" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Rebasing to KDE edition...${NC}"
    sudo rpm-ostree rebase "ostree-unverified-image:dir:$EXPORT_DIR/zephyrus-kde-export"
    
    echo ""
    echo -e "${GREEN}✓ Rebase staged!${NC}"
    read -p "Reboot now? (y/N): " reboot_now
    if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
        sudo systemctl reboot
    else
        echo "Run 'sudo systemctl reboot' when ready."
    fi
else
    echo ""
    echo "You can rebase later with:"
    echo "  sudo rpm-ostree rebase ostree-unverified-image:dir:$EXPORT_DIR/zephyrus-kde-export"
fi

# Cleanup staged source
rm -rf "$PROJECT_ROOT/custom-asusctl"
