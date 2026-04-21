#!/bin/bash
# Quick test script for extension development
# Rebuilds and reloads the extension

set -e

echo "=========================================="
echo "Testing Zephyrus Global Menu Extension"
echo "=========================================="
echo ""

SCRIPT_DIR="$(dirname "$0")"
UUID="zephyrus-globalmenu@solarious"

# Build
echo "Building extension..."
"$SCRIPT_DIR/build-extension.sh"

# Install
echo ""
echo "Installing extension..."
gnome-extensions install "$SCRIPT_DIR/../extension/${UUID}.shell-extension.zip" --force

# Enable
echo "Enabling extension..."
gnome-extensions enable "$UUID" 2>/dev/null || true

echo ""
echo "=========================================="
echo "Extension installed and enabled"
echo "=========================================="
echo ""
echo "On X11: Press Alt+F2, type 'r', press Enter"
echo "On Wayland: Log out and log back in"
echo ""
echo "View logs:"
echo "  journalctl -f -o cat | grep zephyrus"
echo ""
