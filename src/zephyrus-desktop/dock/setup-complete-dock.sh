#!/bin/bash
# Complete Zephyrus Dock Setup
# Hardcoded dock with ROG theme - replaces all dock extensions

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ZEPHYRUS DOCK - COMPLETE SETUP                           ║"
echo "║  Hardcoded ROG dock - No extensions needed!               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if running on host
if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
    echo "⚠️  You are in a container!"
    echo "   Please exit and run this on the HOST system"
    echo "   Type: exit"
    exit 1
fi

DOCK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Step 1: Removing existing dock extensions..."

# Disable common dock extensions
EXTENSIONS_TO_DISABLE=(
    "dash-to-dock@micxgx.gmail.com"
    "ubuntu-dock@ubuntu.com"
    "ding@rastersoft.com"
    "dock@lansing.codes"
)

for ext in "${EXTENSIONS_TO_DISABLE[@]}"; do
    gnome-extensions disable "$ext" 2>/dev/null || true
done

echo "  ✓ Existing docks disabled"
echo ""

echo "Step 2: Installing Zephyrus Dock..."

# Run the installer
bash "$DOCK_DIR/install-dock.sh"

echo ""
echo "Step 3: Setting up autostart..."

# Enable systemd service
systemctl --user daemon-reload
systemctl --user enable zephyrus-dock.service

echo "  ✓ Dock will auto-start on login"
echo ""

echo "Step 4: Starting dock now..."

# Kill any existing dock process
pkill -f "zephyrus-dock" 2>/dev/null || true

# Start the dock
systemctl --user start zephyrus-dock.service || {
    echo "  Starting manually..."
    zephyrus-dock &
}

echo "  ✓ Dock started!"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "SETUP COMPLETE!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Your ROG dock is now running at the bottom of the screen!"
echo ""
echo "Features:"
echo "  • Crimson gradient with red glow"
echo "  • Glass-like translucent effect"
echo "  • 6 dock icons (Files, Games, Downloads, Terminal, NVIDIA, Trash)"
echo "  • Hover animations (icons lift up)"
echo "  • NO EXTENSIONS REQUIRED"
echo ""
echo "The dock will automatically start every time you log in."
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "MANAGEMENT COMMANDS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Start dock:"
echo "  systemctl --user start zephyrus-dock.service"
echo ""
echo "Stop dock:"
echo "  systemctl --user stop zephyrus-dock.service"
echo ""
echo "Restart dock:"
echo "  systemctl --user restart zephyrus-dock.service"
echo ""
echo "Disable autostart:"
echo "  systemctl --user disable zephyrus-dock.service"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
