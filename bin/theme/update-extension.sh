#!/usr/bin/env bash
# Quick update extension with new sizes

ZEPHYRUS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # TODO: this needs more testing on ARM
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious"

echo "Updating Zephyrus Extension..."

# Copy updated files
cp "${ZEPHYRUS_DIR}/extension/extension.js" "${ext_dir}/"
cp "${ZEPHYRUS_DIR}/extension/stylesheet.css" "$EXT_DIR/"

echo "ok Extension updated with:"
echo "  - Button: 60px wide"
echo "  - Icon: 48px (16:9 ratio)"

echo ""
echo "Restart GNOME Shell: Alt+F2 → r → Enter"
