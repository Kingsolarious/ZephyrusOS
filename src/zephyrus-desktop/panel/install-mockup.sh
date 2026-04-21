#!/bin/bash
# Install Zephyrus Panel - Exact mockup version

set -e

PANEL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/zephyrus-panel-mockup@zephyrus-os"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Install Zephyrus Panel - Mockup Edition                  ║"
echo "║  Exact match to your design!                              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Create extension directory
mkdir -p "$EXT_DIR/assets"

echo "Installing panel files..."

# Copy mockup files
cp "$PANEL_DIR/zephyrus-panel-mockup.js" "$EXT_DIR/extension.js"
cp "$PANEL_DIR/stylesheet-mockup.css" "$EXT_DIR/stylesheet.css"

# Create metadata
cat > "$EXT_DIR/metadata.json" << 'JSON'
{
    "name": "Zephyrus Panel - Mockup",
    "description": "Exact mockup implementation - ROG logo, Rüe brand, macOS menus",
    "uuid": "zephyrus-panel-mockup@zephyrus-os",
    "shell-version": ["45", "46", "47", "48", "49"],
    "version": 1
}
JSON

# Copy ROG logo
echo "Copying ROG logo..."
if [ -f "$HOME/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.svg" ]; then
    cp "$HOME/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.svg" "$EXT_DIR/assets/"
    echo "  ✓ ROG logo found and copied"
elif [ -f "$HOME/Desktop/Zephyrus OS/rog-icons/rog-eye.svg" ]; then
    cp "$HOME/Desktop/Zephyrus OS/rog-icons/rog-eye.svg" "$EXT_DIR/assets/"
    echo "  ✓ ROG logo found and copied"
else
    echo "  ⚠️  ROG logo not found - will use fallback"
fi

echo ""
echo "✓ Panel installed successfully!"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "YOUR NEW PANEL LOOKS LIKE:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  [⚡] [Rüe] [Finder] [File] [Edit] [View] [Go] [Window] [System]   [WiFi] [Battery] [Clock]"
echo ""
echo "  • Crimson gradient background"
echo "  • ROG logo on the left"
echo "  • Rüe brand text"
echo "  • App name (Finder)"
echo "  • Full menu bar (File, Edit, View, Go, Window, System)"
echo "  • System icons and clock on the right"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TO ENABLE (run on HOST):"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Disable old extensions:"
echo "   gsettings set org.gnome.shell enabled-extensions \"[]\""
echo ""
echo "2. Enable new panel:"
echo "   gsettings set org.gnome.shell enabled-extensions \"['zephyrus-panel-mockup@zephyrus-os']\""
echo ""
echo "3. Restart GNOME Shell:"
echo "   Alt+F2 → r → Enter"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
