#!/bin/bash
# Install Zephyrus Panel (macOS-style top bar)

set -e

PANEL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/zephyrus-panel@zephyrus-os"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Install Zephyrus Panel                                   ║"
echo "║  macOS-style Top Bar for Zephyrus OS                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if in container
if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
    echo "⚠️  You're in a container!"
    echo "   Files will be copied but you must enable on HOST"
    echo ""
fi

# Create extension directory
mkdir -p "$EXT_DIR/assets"

echo "Installing panel extension..."

# Copy files
cp "$PANEL_DIR/zephyrus-panel.js" "$EXT_DIR/extension.js"
cp "$PANEL_DIR/stylesheet.css" "$EXT_DIR/"
cp "$PANEL_DIR/metadata.json" "$EXT_DIR/" 2>/dev/null || cat > "$EXT_DIR/metadata.json" << 'JSON'
{
    "name": "Zephyrus Panel",
    "description": "macOS-style top panel for Zephyrus OS",
    "uuid": "zephyrus-panel@zephyrus-os",
    "shell-version": ["45", "46", "47", "48", "49"],
    "version": 1
}
JSON

# Copy ROG logo if exists
if [ -f "$HOME/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.svg" ]; then
    cp "$HOME/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.svg" "$EXT_DIR/assets/"
elif [ -f "$HOME/Desktop/Zephyrus\ OS/rog-icons/rog-eye.svg" ]; then
    cp "$HOME/Desktop/Zephyrus\ OS/rog-icons/rog-eye.svg" "$EXT_DIR/assets/"
fi

echo "✓ Panel installed"
echo ""

# Enable instruction
echo "═══════════════════════════════════════════════════════════"
echo "TO ENABLE (run on HOST):"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Enable the extension:"
echo "   gsettings set org.gnome.shell enabled-extensions \"['zephyrus-panel@zephyrus-os']\""
echo ""
echo "2. Disable conflicting extensions:"
echo "   gsettings set org.gnome.shell enabled-extensions \"['zephyrus-panel@zephyrus-os']\""
echo ""
echo "3. Restart GNOME Shell:"
echo "   Alt+F2 → r → Enter"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "WHAT YOU GET:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  [ROG Logo] [App Name] [File] [Edit] [View]...    [Clock]"
echo ""
echo "  • ROG Logo: System menu (About, Settings, ROG Control)"
echo "  • App Name: Current application name"
echo "  • Global Menu: File, Edit, View, etc. (placeholders)"
echo "  • Clock: Time display"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "NOTE: This replaces GNOME's default top panel completely!"
echo "═══════════════════════════════════════════════════════════"
echo ""
