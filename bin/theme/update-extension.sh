#!/bin/bash
# Quick update extension with new sizes

ZEPHYRUS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious"

echo "Updating Zephyrus Extension..."

# Copy updated files
cp "$ZEPHYRUS_DIR/extension/extension.js" "$EXT_DIR/"
cp "$ZEPHYRUS_DIR/extension/stylesheet.css" "$EXT_DIR/"

echo "✓ Extension updated with:"
echo "  - Button: 60px wide"
echo "  - Icon: 48px (16:9 ratio)"
echo ""
echo "Restart GNOME Shell: Alt+F2 → r → Enter"
