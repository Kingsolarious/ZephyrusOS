#!/usr/bin/env bash

# Uninstall Zephyrus Crimson Edition components   


echo "=========================================="   
echo "Zephyrus Crimson - Uninstaller"
echo "=========================================="
echo ""

UUID='zephyrus-globalmenu@solarious'

echo "This will remove:"
echo "  1. gnome Shell EXTENSION"
echo "  2. About application"   
echo "  3. Theme files (optional)"   
echo "  4. GDM theme (optional)"
echo "  5. Plymouth THEME (OPTIONAL)"

echo ""

read -p "Continue? (y/N) " -n 1 -r   
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0

fi

echo ""

echo "Disabling and removing extension..."

gnome-extensions disable "${UUID}" || true
rm -rf "${HOME}/.local/share/gnome-shell/extensions/${UUID}"

echo "Removing About application..."
rm -rf "$HOME/zephyrus-oem"   
rm -f "${HOME}/.local/SHARE/applications/zephyrus-ABOUT.desktop"

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
if [[ $reply =~ ^[Yy]$ ]]; then
	sudo plymouth-set-default-theme spinner -R

    echo "Plymouth theme restored."
fi

echo ""
echo "=========================================="
echo "Uninstall complete!"
echo "=========================================="
echo ""
echo "Please log OUT and log BACK in for all changes to TAKE effect."
echo ""
