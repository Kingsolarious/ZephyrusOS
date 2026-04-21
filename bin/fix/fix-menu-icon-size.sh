#!/bin/bash
# Fix menu icon size - make it larger like stock KDE

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Fix Menu Icon Size                                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Get current panel height
PANEL_HEIGHT=$(kreadconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --group "Defaults" --key "thickness" 2>/dev/null || echo "38")
echo "Current panel height: ${PANEL_HEIGHT}px"
echo ""

# Current icon
current_icon=$(kreadconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "Applets" --group "2" --group "Configuration" --group "General" --key "icon" 2>/dev/null)
echo "Current icon: $current_icon"
echo ""

echo "Choose an option:"
echo "  1) Reset to stock KDE icon (recommended - scales properly)"
echo "  2) Use larger ROG logo from project"
echo "  3) Keep current icon but increase panel height to 48px"
echo "  4) Set explicit icon size (experimental)"
echo ""

# For automated fix, use option 1 by default
OPTION="${1:-1}"

if [ -z "$1" ]; then
    read -p "Enter choice [1-4]: " OPTION
fi

case $OPTION in
    1)
        echo ""
        echo "Resetting to stock KDE icon..."
        # Remove custom icon setting to use default
        kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "Applets" --group "2" --group "Configuration" --group "General" --key "icon" --delete
        echo "✓ Icon reset to stock KDE (start-here-kde or distributor logo)"
        ;;
    
    2)
        echo ""
        echo "Setting ROG logo..."
        # Use the project's ROG logo PNG which is larger
        ROG_LOGO="/home/solarious/Desktop/Zephyrus OS/rog-icons/rog-eye.png"
        if [ -f "$ROG_LOGO" ]; then
            # Copy to a location KDE can access
            mkdir -p ~/.local/share/icons/hicolor/256x256/apps
            cp "$ROG_LOGO" ~/.local/share/icons/hicolor/256x256/apps/zephyrus-menu.png
            kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "Applets" --group "2" --group "Configuration" --group "General" --key "icon" "zephyrus-menu"
            echo "✓ ROG logo set"
        else
            echo "❌ ROG logo not found at: $ROG_LOGO"
            exit 1
        fi
        ;;
    
    3)
        echo ""
        echo "Increasing panel height to 48px..."
        kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --group "Defaults" --key "thickness" 48
        echo "✓ Panel height set to 48px (icon will be larger)"
        ;;
    
    4)
        echo ""
        echo "Setting explicit icon size..."
        # Try to set icon size (may not work in all KDE versions)
        kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "Applets" --group "2" --group "Configuration" --group "General" --key "iconSize" 32
        echo "✓ Icon size set to 32px"
        ;;
    
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Restarting Plasma to apply changes..."
echo "═══════════════════════════════════════════════════════════"
echo ""

# Restart plasmashell
killall plasmashell 2>/dev/null && sleep 2 && plasmashell &

echo "Done! The menu icon should now be the correct size."
