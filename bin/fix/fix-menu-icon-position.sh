#!/bin/bash
# Fix top-left menu icon position - revert to stock KDE positioning

echo "Reverting menu icon to stock position..."

# Remove any offset settings from plasmashellrc
# This ensures the panel starts at the absolute left edge
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --key "offset" --delete 2>/dev/null || true
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --key "panelLengthMode" --delete 2>/dev/null || true
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --key "panelVisibility" --delete 2>/dev/null || true

# Set panel to not float (stock style)
kwriteconfig6 --file plasmashellrc --group "PlasmaViews" --group "Panel 1" --key "floating" 0

# Reset the kickoff applet configuration to remove any custom padding/icon sizing
# First, get the current applet ID for kickoff
APPLET_ID=$(grep -B2 "plugin=org.kde.plasma.kickoff" ~/.config/plasma-org.kde.plasma.desktop-appletsrc | grep "\[Containments\]\[1\]\[Applets\]" | head -1 | sed 's/.*\[Applets\]\[\([0-9]*\)\].*/\1/')

if [ -z "$APPLET_ID" ]; then
    echo "Kickoff applet not found in config, trying applet 2..."
    APPLET_ID="2"
fi

echo "Found kickoff applet ID: $APPLET_ID"

# Remove any custom positioning config for the kickoff applet
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "Applets" --group "$APPLET_ID" --group "Configuration" --group "General" --key "icon" --delete 2>/dev/null || true

# Reset to stock icon (or keep custom if you prefer, just fix position)
# kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "Applets" --group "$APPLET_ID" --group "Configuration" --group "General" --key "icon" "start-here-kde"

# Ensure applet order is correct (kickoff first)
kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "1" --group "General" --key "AppletOrder" "2;3;4;5;6"

echo ""
echo "Menu icon position reset to stock!"
echo "Restarting Plasma shell to apply changes..."
echo ""

# Restart plasmashell to apply
killall plasmashell 2>/dev/null && sleep 1 && plasmashell &

echo "Done! The menu icon should now be at the stock position."
