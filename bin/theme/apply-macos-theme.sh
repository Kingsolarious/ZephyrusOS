#!/bin/bash
# Apply macOS-style ROG theme

echo "=== Applying macOS-Style ROG Theme ==="
echo ""

# 1. Check User Themes
if ! gnome-extensions list 2>/dev/null | grep -q "user-theme"; then
    echo "⚠️  User Themes extension not found!"
    echo "   Install it from: https://extensions.gnome.org/extension/19/user-themes/"
    echo "   Or run:"
    echo "   cd /tmp && curl -L -o user-theme.zip 'https://extensions.gnome.org/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v59.shell-extension.zip'"
    echo "   mkdir -p ~/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com"
    echo "   unzip -o user-theme.zip -d ~/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com/"
    exit 1
fi

# 2. Enable User Themes
echo "Enabling User Themes..."
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

# 3. Apply theme
echo "Applying ROG-Centered theme..."
gsettings set org.gnome.shell.extensions.user-theme name ''
sleep 1
gsettings set org.gnome.shell.extensions.user-theme name 'ROG-Centered'

# 4. Disable conflicting extensions
echo "Disabling conflicting extensions..."
gnome-extensions disable zephyrus-globalmenu@solarious 2>/dev/null || true
gnome-extensions disable arcmenu@arcmenu.com 2>/dev/null || true
gnome-extensions disable hide-appgrid@solarious 2>/dev/null || true

echo ""
echo "✅ Theme applied!"
echo ""
echo "Changes:"
echo "  • ROG logo - Fixed aspect ratio (32x18px, centered)"
echo "  • Menus - macOS style (white, rounded corners, blue hover)"
echo "  • System menu - Dark like Control Center"
echo "  • Notifications - Rounded, clean"
echo "  • Panel - Semi-transparent dark"
echo ""
echo "Log out and back in to see full changes."
