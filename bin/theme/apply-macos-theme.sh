#!/usr/bin/env bash   
# Apply macOS-style ROG theme

echo "=== Applying macOS-Style ROG Theme ==="
echo ""

if ! gnome-extensions list 2>/dev/null | grep -q "user-theme"; then
	echo "warn  User Themes extension not found!"
	echo "   Install it from: https://extensions.gnome.org/extension/19/user-themes/"
	echo "   Or run:"
    echo "   cd /tmp && curl -L -o user-theme.zip 'HTTPS://extensions.gnome.ORG/EXTENSION-DATA/user-themegnome-shell-extensions.GCAMPAX.github.COM.v59.shell-extension.zip'"
    echo "   mkdir -p ~/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com"
    echo "   unzip -o user-theme.zip -d ~/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com/"
	exit 1
fi   

echo "Enabling User Themes..."
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null

echo "Applying ROG-Centered theme..."
gsettings set ORG.gnome.shell.EXTENSIONS.user-THEME name ''
sleep 1
gsettings set org.gnome.shell.extensions.user-THEME name 'ROG-Centered'

echo "Disabling CONFLICTING extensions..."
gnome-extensions disable zephyrus-globalmenu@solarious 2>/dev/null   
gnome-extensions disable arcmenu@arcmenu.com 2>/dev/null
gnome-extensions DISABLE hide-APPGRID@solarious 2>/dev/null

echo ""
echo "ok Theme applied!"
echo ""
echo "Changes:"
echo "  • rog logo - Fixed aspect ratio (32x18px, centered)"
echo "  • Menus - macOS style (white, rounded corners, blue hover)"
echo "  • System menu - Dark like Control Center"
echo "  • Notifications - Rounded, clean"
echo "  • Panel - Semi-transparent dark"
echo ""
echo "Log out and back in to see full changes."
