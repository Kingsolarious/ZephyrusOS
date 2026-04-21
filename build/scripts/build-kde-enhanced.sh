#!/bin/bash
# Build Zephyrus Crimson OS - KDE Enhanced Edition
# Includes: macOS WhiteSur Theme + ROG Branding + AI Environment
# Following build plan: Phase 1-9

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Build configuration
BUILD_DATE=$(date +%Y%m%d)
VERSION="2.1.0-kde-enhanced-${BUILD_DATE}"
IMAGE_NAME="zephyrus-crimson-kde-enhanced"
CONTAINERFILE="Containerfile.kde-enhanced"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ZEPHYRUS CRIMSON OS - KDE ENHANCED EDITION               ║${NC}"
echo -e "${BLUE}║  Phase 1-9: Complete Build with macOS Theme + AI          ║${NC}"
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

# Check available disk space
AVAILABLE_SPACE=$(df /var/tmp | awk 'NR==2 {print $4}')
if [ "$AVAILABLE_SPACE" -lt 52428800 ]; then  # 50GB in KB
    echo -e "${YELLOW}⚠️  Warning: Less than 50GB available in /var/tmp${NC}"
    echo "Available: $(df -h /var/tmp | awk 'NR==2 {print $4}')"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}✓ Host system detected${NC}"
echo -e "${GREEN}✓ Podman available${NC}"
echo -e "${GREEN}✓ Disk space check passed${NC}"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Verify Containerfile exists
if [ ! -f "os-build/$CONTAINERFILE" ]; then
    echo -e "${RED}❌ $CONTAINERFILE not found!${NC}"
    exit 1
fi

echo -e "${CYAN}Build Configuration:${NC}"
echo "  Version: $VERSION"
echo "  Image: $IMAGE_NAME"
echo "  Date: $BUILD_DATE"
echo "  Directory: $PROJECT_ROOT"
echo "  Containerfile: $CONTAINERFILE"
echo ""

# Check if required directories exist
echo -e "${BLUE}Checking project structure...${NC}"

REQUIRED_DIRS=("zephyrus-about" "zephyrus-desktop" "theme" "plymouth" "os-build/overlays")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir/"
    else
        echo -e "  ${YELLOW}⚠${NC} $dir/ (creating...)"
        mkdir -p "$dir"
    fi
done

echo ""

# =============================================================================
# PHASE 0-1: BASE SYSTEM (Pull base image)
# =============================================================================

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Phase 0-1: Base System Setup${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}Pulling base image (bazzite:stable)...${NC}"
podman pull ghcr.io/ublue-os/bazzite:stable || {
    echo -e "${RED}Failed to pull base image${NC}"
    echo "Make sure you have internet connection."
    exit 1
}

echo -e "${GREEN}✓ Base image ready${NC}"
echo ""

# Stage custom asusctl source for container build (exclude .git)
if [ -d "/home/solarious/asusctl" ]; then
    echo -e "${BLUE}Staging custom asusctl source...${NC}"
    mkdir -p "$PROJECT_ROOT/custom-asusctl"
    rsync -a --exclude='.git' "/home/solarious/asusctl/" "$PROJECT_ROOT/custom-asusctl/"
fi

# =============================================================================
# MAIN BUILD
# =============================================================================

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Building Zephyrus Crimson KDE Enhanced...${NC}"
echo -e "${CYAN}This includes: macOS Theme + ROG Assets + AI Tools${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}⚠ This will take 30-60 minutes depending on your system.${NC}"
echo ""

# Build the custom image
echo -e "${BLUE}Starting build...${NC}"
podman build \
    -f os-build/$CONTAINERFILE \
    -t "$IMAGE_NAME:$VERSION" \
    -t "$IMAGE_NAME:latest" \
    --build-arg ZEPHYRUS_VERSION="$VERSION" \
    --build-arg ZEPHYRUS_BUILD_DATE="$BUILD_DATE" \
    "$PROJECT_ROOT" 2>&1 | tee /var/tmp/zephyrus-build-$BUILD_DATE.log

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    echo "Check log: /var/tmp/zephyrus-build-$BUILD_DATE.log"
    exit 1
fi

echo -e "${GREEN}✓ Build completed successfully!${NC}"
echo ""

# =============================================================================
# EXPORT FOR OSTREE REBASE
# =============================================================================

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Phase 9: Exporting Image for Deployment${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

EXPORT_DIR="/var/tmp"
EXPORT_NAME="zephyrus-kde-enhanced-export"

echo -e "${YELLOW}Exporting container to OSTree format...${NC}"
echo "  Source: $IMAGE_NAME:$VERSION"
echo "  Destination: $EXPORT_DIR/$EXPORT_NAME"
echo ""

# Remove old export if exists
if [ -d "$EXPORT_DIR/$EXPORT_NAME" ]; then
    echo -e "${YELLOW}Removing old export...${NC}"
    rm -rf "$EXPORT_DIR/$EXPORT_NAME"
fi

# Export the image
podman push "$IMAGE_NAME:$VERSION" "dir:$EXPORT_DIR/$EXPORT_NAME" --remove-signatures

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Export failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Image exported successfully${NC}"
echo ""

# =============================================================================
# SUMMARY
# =============================================================================

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  BUILD COMPLETE!                                          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Image Details:${NC}"
echo "  Name: $IMAGE_NAME"
echo "  Version: $VERSION"
echo "  Export: $EXPORT_DIR/$EXPORT_NAME"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}DEPLOYMENT INSTRUCTIONS:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}1. Rebase to your new enhanced KDE image:${NC}"
echo ""
echo -e "   ${GREEN}sudo rpm-ostree rebase ostree-unverified-image:dir:$EXPORT_DIR/$EXPORT_NAME${NC}"
echo ""
echo -e "${YELLOW}2. Reboot to new deployment:${NC}"
echo ""
echo -e "   ${GREEN}sudo systemctl reboot${NC}"
echo ""
echo -e "${YELLOW}3. After reboot, verify:${NC}"
echo ""
echo -e "   ${GREEN}cat /etc/zephyrus-release${NC}"
echo ""
echo -e "${YELLOW}4. Optional: Remove broken deployment 0 after confirming new one works:${NC}"
echo ""
echo -e "   ${GREEN}sudo rpm-ostree cleanup -p${NC}"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}FEATURES INCLUDED:${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  ✅ KDE Plasma 6 Desktop"
echo "  ✅ WhiteSur macOS Theme (Dark/Light)"
echo "  ✅ WhiteSur Icons & Cursors"
echo "  ✅ Inter Font (San Francisco alternative)"
echo "  ✅ ROG Custom Color Scheme"
echo "  ✅ ROG Plymouth Boot Theme"
echo "  ✅ ASUS ROG Hardware Tools (asusctl, supergfxctl)"
echo "  ✅ AI Coder Environment (VS Code, Distrobox, KVM)"
echo "  ✅ Python ML Stack (PyTorch, Transformers, Jupyter)"
echo "  ✅ Zephyrus Custom Apps (About, Dock)"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Save deployment info
cat > "$EXPORT_DIR/zephyrus-deployment-info.txt" << EOF
Zephyrus Crimson OS - Deployment Info
=====================================
Version: $VERSION
Build Date: $BUILD_DATE
Image: $IMAGE_NAME
Export Path: $EXPORT_DIR/$EXPORT_NAME

Deployment Command:
sudo rpm-ostree rebase ostree-unverified-image:dir:$EXPORT_DIR/$EXPORT_NAME

Post-Install Setup:
1. Reboot: sudo systemctl reboot
2. Login to KDE Plasma
3. Apply theme: System Settings → Appearance → Global Theme → WhiteSur-dark
4. Configure Kvantum: kvantummanager → Select WhiteSur-dark
5. Set up AI environment: zephyrus-ai-coder distrobox

Rollback if needed:
sudo rpm-ostree rollback
sudo systemctl reboot
EOF

echo -e "${GREEN}Deployment info saved to: $EXPORT_DIR/zephyrus-deployment-info.txt${NC}"
echo ""

# Cleanup staged source
rm -rf "$PROJECT_ROOT/custom-asusctl"
