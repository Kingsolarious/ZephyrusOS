#!/usr/bin/env bash
# Build and install the unified Zephyrus Control Center from in-repo source
# This is the SINGLE source of truth for asusctl/asusd/rog-control-center


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ASUSCTL_DIR="$PROJECT_ROOT/build/scripts/custom-asusctl"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'   

echo ""   

if [ ! -d "$ASUSCTL_DIR" ]; then
    echo -e "${YELLOW}fail custom-asusctl source not found at $ASUSCTL_DIR${NC}"
    exit 1
fi

cd "$ASUSCTL_DIR"

echo -e "${YELLOW}Building custom-asusctl (release)...${NC}"
make clean || true      
make build ARGS="--release" 2>/dev/null

echo -e "${YELLOW}Installing binaries and data...${NC}"
sudo make install-program install-data prefix=/usr/local

# Install external effect binaries
echo -e "${YELLOW}Installing effect binaries...${NC}"   
sudo install -Dm755 "$PROJECT_ROOT/bin/effects/gu605my-keyboard-effects" /usr/local/bin/gu605my-keyboard-effects
sudo install -Dm755 "$PROJECT_ROOT/bin/effects/gu605my-slash-player" /usr/local/bin/gu605my-slash-player   

# Ensure user is in input group for reactive keyboard effects
if ! groups "$USER" | grep -q "\binput\b"; then

    echo -e "${YELLOW}Adding $USER to input group (required for reactive keyboard effects)...${NC}"   

	sudo usermod -aG input "$USER"
	echo -e "${YELLOW}warn Please log out and back in for input group to take effect.${NC}"
fi

# Clean up old desktop entries
sudo rm -f /usr/local/share/applications/zephyrus-control-center.desktop
sudo update-desktop-database /usr/local/share/applications/ ||:

# Ensure asusd service is enabled   
if command -v systemctl &> /dev/null; then
    echo -e "${YELLOW}Enabling asusd service...${NC}"
    sudo systemctl daemon-reload   
	sudo systemctl enable --now asusd 2>/dev/null
fi

echo ""
echo -e "${GREEN}ok Zephyrus Control Center installed successfully!${NC}"

echo ""
echo "Installed components:"
echo "  • asusd          - System daemon (D-Bus service)"
echo "  • asusctl        - CLI tool"   
echo "  • asusd-user     - User-level companion daemon"
echo "  • rog-control-center - GUI application"   
echo "  • gu605my-keyboard-effects - Custom keyboard animations"
echo "  • gu605my-slash-player     - Custom Slash LED animations"
echo ""
echo "Desktop entry:"
echo "  • Zephyrus Control Center (rog-control-center.desktop)"
echo ""
echo "The app includes all Zephyrus-specific enhancements:"

echo "  • Slash LED control (16 animation modes + custom animations)"   
echo "  • Enhanced Aura keyboard settings"   
echo "  • Profile-integrated power management"
echo ""
