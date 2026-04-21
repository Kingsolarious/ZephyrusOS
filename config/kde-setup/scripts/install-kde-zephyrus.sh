#!/bin/bash
# Complete KDE Zephyrus Installation
# Run after rebasing to KDE

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ZEPHYRUS OS - KDE PLASMA SETUP                           ║"
echo "║  ROG + macOS Factory Integration                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if running on KDE
if ! command -v plasmashell &>/dev/null; then
    echo "❌ KDE Plasma not detected!"
    echo ""
    echo "Run this FIRST (on host, not container):"
    echo "  sudo rpm-ostree rebase fedora:fedora/41/x86_64/kde"
    echo "  sudo systemctl reboot"
    echo ""
    echo "Then run this script again after rebooting."
    exit 1
fi

echo "✓ KDE Plasma detected!"
echo ""

ZEPHYRUS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALL_DIR="$HOME/.local/share/zephyrus-desktop"

# Create directories
echo "Creating directories..."
mkdir -p "$INSTALL_DIR"/{panel,dock,about,config}
mkdir -p "$HOME/.config/autostart"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/color-schemes"
mkdir -p "$HOME/.local/share/plasma/desktoptheme"

# ============================================
# 1. INSTALL WORKING DOCK
# ============================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "INSTALLING WORKING DOCK"
echo "═══════════════════════════════════════════════════════════"

# Install dock
cp "$ZEPHYRUS_DIR/zephyrus-desktop/dock/zephyrus-dock-working.py" \
   "$INSTALL_DIR/dock/zephyrus-dock.py"
chmod +x "$INSTALL_DIR/dock/zephyrus-dock.py"

# Create launcher
cat > "$HOME/.local/bin/zephyrus-dock" << EOF
#!/bin/bash
python3 ~/.local/share/zephyrus-desktop/dock/zephyrus-dock.py "\$@"
EOF
chmod +x "$HOME/.local/bin/zephyrus-dock"

# Create autostart desktop entry
cat > "$HOME/.config/autostart/zephyrus-dock.desktop" << 'EOF'
[Desktop Entry]
Name=Zephyrus Dock
Comment=ROG macOS-style dock
Exec=/home/USER_PLACEHOLDER/.local/bin/zephyrus-dock
Type=Application
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

sed -i "s/USER_PLACEHOLDER/$USER/g" "$HOME/.config/autostart/zephyrus-dock.desktop"

echo "✓ Dock installed"

# ============================================
# 2. INSTALL ROG THEMES
# ============================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "INSTALLING ROG THEMES"
echo "═══════════════════════════════════════════════════════════"

# Install color scheme if available
if [ -f "$ZEPHYRUS_DIR/kde-setup/themes/ZephyrusCrimson/ZephyrusCrimson.colors" ]; then
    cp "$ZEPHYRUS_DIR/kde-setup/themes/ZephyrusCrimson/ZephyrusCrimson.colors" \
       "$HOME/.local/share/color-schemes/"
    echo "✓ Color scheme installed"
fi

# Apply ROG wallpaper
if [ -f "$ZEPHYRUS_DIR/kde-setup/wallpapers/ROG_Zephyrus_Default_4K.png" ]; then
    mkdir -p "$HOME/.local/share/wallpapers"
    cp "$ZEPHYRUS_DIR/kde-setup/wallpapers/ROG_Zephyrus_Default_4K.png" \
       "$HOME/.local/share/wallpapers/"
    
    # Set wallpaper using plasma-apply-wallpaperimage
    if command -v plasma-apply-wallpaperimage &>/dev/null; then
        plasma-apply-wallpaperimage \
            "$HOME/.local/share/wallpapers/ROG_Zephyrus_Default_4K.png" 2>/dev/null || true
    fi
    echo "✓ Wallpaper installed"
fi

# ============================================
# 3. INSTALL ABOUT APP
# ============================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "INSTALLING ABOUT APP"
echo "═══════════════════════════════════════════════════════════"

cp "$ZEPHYRUS_DIR/zephyrus-about/about.py" "$INSTALL_DIR/about/zephyrus-about.py"
chmod +x "$INSTALL_DIR/about/zephyrus-about.py"

cat > "$HOME/.local/bin/zephyrus-about" << EOF
#!/bin/bash
python3 ~/.local/share/zephyrus-desktop/about/zephyrus-about.py "\$@"
EOF
chmod +x "$HOME/.local/bin/zephyrus-about"

cat > "$HOME/.local/share/applications/zephyrus-about.desktop" << 'EOF'
[Desktop Entry]
Name=About This Zephyrus
Comment=System information and specifications
Exec=/home/USER_PLACEHOLDER/.local/bin/zephyrus-about
Type=Application
Icon=computer
Categories=System;
EOF

sed -i "s/USER_PLACEHOLDER/$USER/g" "$HOME/.local/share/applications/zephyrus-about.desktop"

echo "✓ About app installed"

# ============================================
# 4. KDE CONFIGURATION
# ============================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "CONFIGURING KDE PLASMA"
echo "═══════════════════════════════════════════════════════════"

# Set window controls to left (macOS style)
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "XAI"
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""
kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key ShowToolTips false

# Disable screen lock (optional - user preference)
# kwriteconfig5 --file kscreenlockerrc --group Daemon --key Autolock false
# kwriteconfig5 --file kscreenlockerrc --group Daemon --key LockOnResume false

echo "✓ KDE configured"

# ============================================
# 5. START SERVICES
# ============================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STARTING SERVICES"
echo "═══════════════════════════════════════════════════════════"

# Start dock
pkill -f "zephyrus-dock" 2>/dev/null || true
sleep 1
~/.local/bin/zephyrus-dock &

echo "✓ Dock started"

# Reload KWin configuration
if command -v kwin_x11 &>/dev/null; then
    kwin_x11 --replace & 2>/dev/null || true
fi

echo "✓ KWin restarted"

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  SETUP COMPLETE!                                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "INSTALLED COMPONENTS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  ✅ Working Dock        - Clickable apps, crimson glass"
echo "  ✅ About App           - System info with glass effect"
echo "  ✅ ROG Wallpaper       - 4K ROG background"
echo "  ✅ KDE Configuration   - macOS-style window controls"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "WHAT'S CONFIGURED:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  • Window controls: Left side (macOS style)"
echo "  • Dock: Bottom of screen, auto-starts on login"
echo "  • About app: Available in application menu"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "NEXT STEPS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Configure top panel for global menu:"
echo "   - Right-click top panel → Edit Panel"
echo "   - Add 'Global Menu' widget"
echo "   - Add 'Application Launcher' with ROG logo"
echo ""
echo "2. Apply ROG color scheme:"
echo "   - System Settings → Appearance → Colors"
echo "   - Select 'ZephyrusCrimson'"
echo ""
echo "3. Test the dock - click icons to launch apps:"
echo "   - Files, Games, Downloads, Terminal, Browser, Trash"
echo ""
echo "4. Run complete ROG setup if desired:"
echo "   cd ~/Desktop/Zephyrus\\ OS"
echo "   ./complete-macos-rog-setup.sh"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Zephyrus OS KDE is ready! Enjoy the factory experience 🎮"
echo ""
