#!/bin/bash
# Build and install the unified Zephyrus Control Center from in-repo source
# This is the SINGLE source of truth for asusctl/asusd/rog-control-center

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ASUSCTL_DIR="$PROJECT_ROOT/build/scripts/custom-asusctl"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Zephyrus Control Center - Build & Install               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ ! -d "$ASUSCTL_DIR" ]; then
    echo -e "${YELLOW}✗ custom-asusctl source not found at $ASUSCTL_DIR${NC}"
    exit 1
fi

cd "$ASUSCTL_DIR"

echo -e "${YELLOW}Building custom-asusctl (release)...${NC}"
make clean 2>/dev/null || true
make build 2>/dev/null

echo -e "${YELLOW}Installing binaries and data...${NC}"
sudo make install

# Install Zephyrus-branded desktop entry
echo -e "${YELLOW}Installing Zephyrus Control Center desktop entry...${NC}"
# /usr/share is read-only on rpm-ostree; use /usr/local/share instead
sudo install -Dm644 "$PROJECT_ROOT/config/desktop-entries/zephyrus-control-center.desktop" \
    /usr/local/share/applications/zephyrus-control-center.desktop
sudo update-desktop-database /usr/local/share/applications/ 2>/dev/null || true

# Ensure asusd service is enabled
if command -v systemctl &> /dev/null; then
    echo -e "${YELLOW}Enabling asusd service...${NC}"
    sudo systemctl daemon-reload
    sudo systemctl enable --now asusd 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}✓ Zephyrus Control Center installed successfully!${NC}"
echo ""
echo "Installed components:"
echo "  • asusd          - System daemon (D-Bus service)"
echo "  • asusctl        - CLI tool"
echo "  • asusd-user     - User-level companion daemon"
echo "  • rog-control-center - GUI application"
echo ""
echo "Desktop entry:"
echo "  • Zephyrus Control Center (zephyrus-control-center.desktop)"
echo ""
echo "The app includes all Zephyrus-specific enhancements:"
echo "  • Slash LED control (16 animation modes)"
echo "  • Enhanced Aura keyboard settings"
echo "  • Profile-integrated power management"
echo ""
