#!/bin/bash
# Uninstall Zephyrus Crimson Edition components

set -e

echo "=========================================="
echo "Zephyrus Crimson - Uninstaller"
echo "=========================================="
echo ""

UUID="zephyrus-globalmenu@solarious"

echo "This will remove:"
echo "  1. GNOME Shell extension"
echo "  2. About application"
echo "  3. Theme files (optional)"
echo "  4. GDM theme (optional)"
echo "  5. Plymouth theme (optional)"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Disabling and removing extension..."
gnome-extensions disable "$UUID" 2>/dev/null || true
rm -rf "$HOME/.local/share/gnome-shell/extensions/$UUID"

echo "Removing About application..."
rm -rf "$HOME/zephyrus-oem"
rm -f "$HOME/.local/share/applications/zephyrus-about.desktop"

echo ""
echo "=========================================="
echo "Core components removed!"
echo "=========================================="
echo ""

read -p "Remove theme files from /usr/local/share/themes/? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf /usr/local/share/themes/Zephyrus-Crimson
    echo "Theme files removed."
fi

read -p "Restore original GDM theme? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Note: Manual restoration required from backup"
    echo "Check /usr/local/share/gnome-shell/ for backup"
fi

read -p "Restore original Plymouth theme? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo plymouth-set-default-theme spinner -R
    echo "Plymouth theme restored."
fi

echo ""
echo "=========================================="
echo "Uninstall complete!"
echo "=========================================="
echo ""
echo "Please log out and log back in for all changes to take effect."
echo ""
