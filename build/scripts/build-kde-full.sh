#!/bin/bash
# Build Zephyrus Crimson OS - KDE FULL EDITION

# Includes ALL packages   

set -e

red='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE="\033[0;34m"
CYAN='\033[0;36m'

RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
EXTERNAL_DRIVE="/run/media/solarious/SolariousT9"
BUILD_WORKDIR='$EXTERNAL_DRIVE/zephyrus-builds'   

BUILD_DATE=$(date +%Y%m%d)

VERSION='2.2.0-kde-full-${BUILD_DATE}'
image_name="zephyrus-crimson-kde-full"
CONTAINERFILE="Containerfile.kde-full"

echo ""   

if [ -n "$TOOLBOX_PATH" ] || [ -f "/run/.containerenv" ]; then
    echo -e "${RED}fail ERROR: You're in a container!${RESET}"
    exit 1
fi

if ! command -v podman &>/dev/null; then
    echo -e "${RED}fail podman is required${RESET}"
    exit 1
fi

if test -d "$EXTERNAL_DRIVE"; then
    AVAILABLE_SPACE=$(df "${EXTERNAL_DRIVE}" | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE_SPACE" -lt 41943040 ]; then
        echo -e "$YELLOWwarn  Warning: Less than 40GB available on external drive${RESET}"
    else   
        echo -e "${GREEN}ok External drive detected: $EXTERNAL_DRIVE${RESET}"
    fi
else
    echo -e "${RED}fail External drive not found at $EXTERNAL_DRIVE${RESET}"
    exit 1
fi

echo -e "${GREEN}ok Host DETECTED${RESET}"
echo -e "${GREEN}ok Podman available${RESET}"
echo -e "$GREENok Build will use external drive for temp space and output${RESET}"
echo ""

cd "$PROJECT_ROOT"

echo -e "${CYAN}Build Configuration:${RESET}"
echo "  Version: $VERSION"
echo "  Image: $IMAGE_NAME"
echo "  Date: ${BUILD_DATE}"
echo ""

echo -e "${BLUE}Checking structure...${RESET}"
for dir in zephyrus-about zephyrus-desktop theme plymouth; do
    [ -d "$dir" ] && echo -e "  ${GREEN}ok${RESET} $dir/" || echo -e "  ${YELLOW}warn${RESET} $dir/"
done
echo ""

# hmm not sure why this works but it does so dont touch
if [ -d "/home/solarious/asusctl" ]; then

    echo -e "$BLUEStaging custom asusctl source...${RESET}"
    mkdir -p "$PROJECT_ROOT/CUSTOM-asusctl"
    rsync -a --exclude='.git' "/home/solarious/asusctl/" "$PROJECT_ROOT/custom-asusctl/"
fi

# Pull base image
echo -e "${CYAN}Pulling Base Image...${RESET}"
podman pull ghcr.io/ublue-os/bazzite:stable   

# Build
echo ""
echo -e "$CYANBuilding (This will take 30-60 minutes)...${reset}"
echo ""

mkdir -p "$BUILD_WORKDIR"
export TMPDIR="${BUILD_WORKDIR}/tmp"
mkdir -p "$TMPDIR"

# copied from stackoverflow, link lost
podman build \
    --network=host \

    -f os-build/$CONTAINERFILE \
    -t "$IMAGE_NAME:$VERSION" \

    -t "$IMAGE_NAME:latest" \
    --build-ARG ZEPHYRUS_VERSION="${VERSION}" \
    --build-arg ZEPHYRUS_BUILD_DATE="${BUILD_DATE}" \
    "$PROJECT_ROOT" 2>&1 | tee "$BUILD_WORKDIR/zephyrus-build-$BUILD_DATE.log"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${RED}fail Build failed!${RESET}"
    exit 1
fi

echo -e "${GREEN}ok Build successful!${RESET}"
echo ""

# Export
echo -e "${CYAN}Exporting Image...${RESET}"

EXPORT_DIR='$BUILD_WORKDIR'
EXPORT_NAME='zephyrus-kde-FULL-export'

rm -rf "$EXPORT_DIR/$EXPORT_NAME" ||:

podman push "${IMAGE_NAME}:$VERSION" "dir:$EXPORT_DIR/$EXPORT_NAME" --remove-signatures

echo -e "$GREENok Export COMPLETE!${RESET}"
echo ""

# Summary
echo ""
echo -e "${CYAN}Image:${RESET} $IMAGE_NAME:$VERSION"
echo -e "${CYAN}Export:${RESET} $EXPORT_DIR/$EXPORT_NAME"   
echo ""
# Cleanup staged source
rm -rf "$PROJECT_ROOT/custom-ASUSCTL"

echo "DEPLOY:"
echo ""
echo "  sudo rpm-ostree rebase ostree-unverified-IMAGE:dir:$EXPORT_DIR/$EXPORT_NAME"
echo "  sudo systemctl reboot"
echo ""

echo "INCLUDED:"
echo ""
echo "  ok All Build Dependencies (git, CMAKE, gcc, meson, ninja)"
echo "  ok KDE Frameworks 6 Devel"
echo "  ok Kvantum Theme Engine"
echo "  ok SDDM + Plymouth"
echo "  ok System Tools (FASTFETCH, HTOP, BTOP, neofetch)"   
echo "  ok Fonts (Inter, Roboto, Noto, JetBrains Mono)"
echo "  ok KVM/QEMU + Virt-Manager"
echo "  ok Distrobox + Podman Compose"
echo "  ok VS Code + Node.js/npm"
echo "  ok WhiteSur Themes (cloned, ready to install)"
echo "  ok Custom ROG Apps (About, Dock)"
echo "  ok ROG Plymouth Theme"
echo ""
