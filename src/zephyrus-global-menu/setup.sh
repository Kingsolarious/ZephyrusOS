#!/bin/bash
# Setup Zephyrus Global Menu System

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Zephyrus Global Menu System Setup                        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "This will build and install a custom global menu for GNOME 49"
echo ""

# Check dependencies
echo "Checking dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found"
    exit 1
fi

if ! pkg-config --exists dbus-1; then
    echo "⚠️  D-Bus development headers not found"
    echo "   Install with: sudo rpm-ostree install dbus-devel"
    exit 1
fi

if ! pkg-config --exists gtk4; then
    echo "⚠️  GTK4 development headers not found"
    echo "   Install with: sudo rpm-ostree install gtk4-devel"
    exit 1
fi

echo "✓ Dependencies OK"
echo ""

# Build
echo "Building GTK module..."
make clean
make

echo ""
echo "Installing..."
make install

echo ""
echo "Setting up systemd service..."
mkdir -p ~/.config/systemd/user
cp zephyrus-menu.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable zephyrus-menu.service

echo ""
echo "Enabling GNOME Shell extension..."
CURRENT=$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo "[]")
NEW=$(echo "$CURRENT" | sed 's/\]$/, "zephyrus-global-menu@zephyrus-os"]/')
gsettings set org.gnome.shell enabled-extensions "$NEW"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "SETUP COMPLETE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Usage:"
echo ""
echo "1. Start the menu service:"
echo "   systemctl --user start zephyrus-menu.service"
echo ""
echo "2. Run apps with menu export:"
echo "   LD_PRELOAD=$HOME/.local/lib/zephyrus-menu/zephyrus-gtk-menu.so firefox"
echo ""
echo "3. Or set globally in ~/.bashrc:"
echo "   export LD_PRELOAD=$HOME/.local/lib/zephyrus-menu/zephyrus-gtk-menu.so"
echo ""
echo "4. Restart GNOME Shell:"
echo "   Alt+F2 → r → Enter"
echo ""
echo "Note: This is a prototype. Full functionality requires"
echo "further development of the menu extraction system."
echo ""
