#!/bin/bash
# Setup script for Gaming Mode Manager
# Run this to install the auto-switching daemon

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ASUS ROG Gaming Mode Manager - Setup                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make scripts executable
chmod +x "$SCRIPT_DIR/gaming-mode-manager.sh"
chmod +x "$SCRIPT_DIR/gamemode-steam-wrapper.sh"
chmod +x "$SCRIPT_DIR/thermal-optimize.sh"
chmod +x "$SCRIPT_DIR/thermal-monitor-simple.sh"

echo "✓ Scripts made executable"

# Create user systemd directory if needed
mkdir -p ~/.config/systemd/user

# Install systemd service
cp "$SCRIPT_DIR/gaming-daemon.service" ~/.config/systemd/user/
echo "✓ Service installed"

# Reload systemd
systemctl --user daemon-reload

echo ""
echo "Starting Gaming Mode Manager..."
systemctl --user enable gaming-daemon.service
systemctl --user start gaming-daemon.service

if [ $? -eq 0 ]; then
    echo "✓ Gaming Mode Manager started!"
else
    echo "⚠ Could not start service, but scripts are ready"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Setup Complete!                                         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Usage:"
echo "  • Manual control: ./gaming-mode-manager.sh [gaming|balanced|battery]"
echo "  • Check status:   ./gaming-mode-manager.sh status"
echo "  • Monitor temps:  ./thermal-monitor-simple.sh"
echo ""
echo "Steam Integration:"
echo "  Add this to Steam game launch options:"
echo "    $SCRIPT_DIR/gamemode-steam-wrapper.sh %command%"
echo ""
echo "Or use gamemoderun directly:"
echo "  gamemoderun %command%"
echo ""
echo "With MangoHud overlay:"
echo "  mangohud gamemoderun %command%"
echo ""
echo "Services:"
echo "  • Check status: systemctl --user status gaming-daemon"
echo "  • Stop:         systemctl --user stop gaming-daemon"
echo "  • Start:        systemctl --user start gaming-daemon"
echo ""
