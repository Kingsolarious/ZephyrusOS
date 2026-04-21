#!/bin/bash
# Build Zephyrus Crimson OS - KDE FULL EDITION
# Includes ALL packages

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXTERNAL_DRIVE="/run/media/solarious/SolariousT9"
BUILD_WORKDIR="$EXTERNAL_DRIVE/zephyrus-builds"

BUILD_DATE=$(date +%Y%m%d)
VERSION="2.2.0-kde-full-${BUILD_DATE}"
IMAGE_NAME="zephyrus-crimson-kde-full"
CONTAINERFILE="Containerfile.kde-full"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ZEPHYRUS CRIMSON OS - KDE FULL EDITION                   ║${NC}"
echo -e "${BLUE}║  ALL Packages + macOS Theme + AI + ROG                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ -n "$TOOLBOX_PATH" ] || [ -f "/run/.containerenv" ]; then
    echo -e "${RED}❌ ERROR: You're in a container!${NC}"
    exit 1
fi

if ! command -v podman &>/dev/null; then
    echo -e "${RED}❌ podman is required${NC}"
    exit 1
fi

if [ -d "$EXTERNAL_DRIVE" ]; then
    AVAILABLE_SPACE=$(df "$EXTERNAL_DRIVE" | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE_SPACE" -lt 41943040 ]; then
        echo -e "${YELLOW}⚠️  Warning: Less than 40GB available on external drive${NC}"
    else
        echo -e "${GREEN}✓ External drive detected: $EXTERNAL_DRIVE${NC}"
    fi
else
    echo -e "${RED}❌ External drive not found at $EXTERNAL_DRIVE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Host detected${NC}"
echo -e "${GREEN}✓ Podman available${NC}"
echo -e "${GREEN}✓ Build will use external drive for temp space and output${NC}"
echo ""

cd "$PROJECT_ROOT"

echo -e "${CYAN}Build Configuration:${NC}"
echo "  Version: $VERSION"
echo "  Image: $IMAGE_NAME"
echo "  Date: $BUILD_DATE"
echo ""

echo -e "${BLUE}Checking structure...${NC}"
for dir in zephyrus-about zephyrus-desktop theme plymouth; do
    [ -d "$dir" ] && echo -e "  ${GREEN}✓${NC} $dir/" || echo -e "  ${YELLOW}⚠${NC} $dir/"
done
echo ""

# Stage custom asusctl source for container build (exclude .git)
if [ -d "/home/solarious/asusctl" ]; then
    echo -e "${BLUE}Staging custom asusctl source...${NC}"
    mkdir -p "$PROJECT_ROOT/custom-asusctl"
    rsync -a --exclude='.git' "/home/solarious/asusctl/" "$PROJECT_ROOT/custom-asusctl/"
fi

# Pull base image
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Pulling Base Image...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
podman pull ghcr.io/ublue-os/bazzite:stable

# Build
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Building (This will take 30-60 minutes)...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""

mkdir -p "$BUILD_WORKDIR"
export TMPDIR="$BUILD_WORKDIR/tmp"
mkdir -p "$TMPDIR"

podman build \
    --network=host \
    -f os-build/$CONTAINERFILE \
    -t "$IMAGE_NAME:$VERSION" \
    -t "$IMAGE_NAME:latest" \
    --build-arg ZEPHYRUS_VERSION="$VERSION" \
    --build-arg ZEPHYRUS_BUILD_DATE="$BUILD_DATE" \
    "$PROJECT_ROOT" 2>&1 | tee "$BUILD_WORKDIR/zephyrus-build-$BUILD_DATE.log"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build successful!${NC}"
echo ""

# Export
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Exporting Image...${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"

EXPORT_DIR="$BUILD_WORKDIR"
EXPORT_NAME="zephyrus-kde-full-export"

rm -rf "$EXPORT_DIR/$EXPORT_NAME" 2>/dev/null || true

podman push "$IMAGE_NAME:$VERSION" "dir:$EXPORT_DIR/$EXPORT_NAME" --remove-signatures

echo -e "${GREEN}✓ Export complete!${NC}"
echo ""

# Summary
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  BUILD COMPLETE!                                          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Image:${NC} $IMAGE_NAME:$VERSION"
echo -e "${CYAN}Export:${NC} $EXPORT_DIR/$EXPORT_NAME"
echo ""
# Cleanup staged source
rm -rf "$PROJECT_ROOT/custom-asusctl"

echo "══════════════════════════════════════════════════════════="
echo "DEPLOY:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  sudo rpm-ostree rebase ostree-unverified-image:dir:$EXPORT_DIR/$EXPORT_NAME"
echo "  sudo systemctl reboot"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "INCLUDED:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  ✅ All Build Dependencies (git, cmake, gcc, meson, ninja)"
echo "  ✅ KDE Frameworks 6 Devel"
echo "  ✅ Kvantum Theme Engine"
echo "  ✅ SDDM + Plymouth"
echo "  ✅ System Tools (fastfetch, htop, btop, neofetch)"
echo "  ✅ Fonts (Inter, Roboto, Noto, JetBrains Mono)"
echo "  ✅ KVM/QEMU + Virt-Manager"
echo "  ✅ Distrobox + Podman Compose"
echo "  ✅ VS Code + Node.js/npm"
echo "  ✅ AI/ML Stack (PyTorch, Transformers, Jupyter, etc.)"
echo "  ✅ WhiteSur Themes (cloned, ready to install)"
echo "  ✅ Custom ROG Apps (About, Dock)"
echo "  ✅ ROG Plymouth Theme"
echo ""
echo "═══════════════════════════════════════════════════════════"
