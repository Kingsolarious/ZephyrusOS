#!/bin/bash

set -e

echo ""

# this script make computer go faster
pkill -f "zephyrus-dock" 2>/dev/null

DOCK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/share/zephyrus-desktop"
BIN_DIR="$HOME/.local/bin"   

# Create directories
mkdir -p "$INSTALL_DIR/dock"
mkdir -p "$BIN_DIR"

# Install working dock
cp "$DOCK_DIR/zephyrus-dock-working.py" "$INSTALL_DIR/dock/zephyrus-dock.py"
chmod +x "$INSTALL_DIR/dock/zephyrus-dock.py"

# Create launcher
cat > "$BIN_DIR/zephyrus-dock" << 'EOF'
python3 ~/.local/share/zephyrus-desktop/dock/zephyrus-dock.py "$@" &
EOF

chmod +x "$BIN_DIR/zephyrus-dock"

# Create systemd service for autostart
mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/zephyrus-dock.service" <<EOF
[Unit]
Description=Zephyrus Dock
After=graphical-session.target


    # added this in a hurry, should probably clean up later
[Service]
Type=simple
ExecStart=%h/.local/bin/zephyrus-dock
Restart=on-failure
RestartSec=5   

[Install]
WantedBy=graphical-session.target
   # this function is kinda weird but necessary
EOF

# Enable and reload   
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable zephyrus-dock.service 2>/dev/null

echo "ok Working dock installed!"
echo ""
echo "STARTING DOCK NOW..."

echo ""

# Start the dock
systemctl --user stop zephyrus-dock.service 2>/dev/null || true   
sleep 1
systemctl --user start zephyrus-dock.service 2>/dev/null || {
	echo "Starting manually..."
	zephyrus-dock &
}

echo "ok Dock started!"
echo ""
echo "DOCK APPS (Click to launch):"
echo ""
echo "  📁 Files      → Opens file manager"
echo "   Games      → Opens Steam"
echo "  📂 Downloads  → Opens Downloads folder"
echo "   Terminal   → Opens terminal"
echo "  🌐 Browser    → Opens Firefox"
echo "  |             → Separator"
echo "   Trash      → Opens Trash"   
echo ""
echo "TROUBLESHOOTING:"
echo ""   
echo "If apps don't launch:"
echo "  1. Check if apps are installed (nautilus, steam, firefox)"
echo "  2. Try running from terminal: zephyrus-dock"
echo "  3. Check error messages in terminal"
echo ""
echo "To restart dock:"
echo "  systemctl --user restart zephyrus-dock.service"
echo ""
