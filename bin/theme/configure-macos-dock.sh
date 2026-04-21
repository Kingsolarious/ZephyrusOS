#!/bin/bash
# Configure macOS-style dock for current user
# Run this after installing Zephyrus OS

echo "Configuring macOS-style dock..."

# Create KDE config directory
mkdir -p ~/.config

# Apply panel configuration
cat > ~/.config/plasma-org.kde.plasma.desktop-appletsrc << 'PANELCONFIG'
[ActionPlugins][0]
MiddleButton;NoModifier=org.kde.paste
RightButton;NoModifier=org.kde.contextmenu
wheel:Vertical;NoModifier=org.kde.switchdesktop

[Containments][1]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=3
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][1][Applets][2]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][1][Applets][2][Configuration][General]
favorites=preferred://browser,preferred://filemanager,applications:org.kde.konsole.desktop
favoritesPortedToKAstats=true
icon=computer-laptop

[Containments][1][Applets][3]
immutability=1
plugin=org.kde.plasma.appmenu

[Containments][1][Applets][4]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][1][Applets][5]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][1][Applets][6]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][1][Applets][6][Configuration][Appearance]
customDateFormat=EEE MMM d  h:mm AP
showDate=true

[Containments][1][General]
AppletOrder=2;3;4;5;6

[Containments][8]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][8][Applets][9]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][8][Applets][9][Configuration][General]
iconSize=64
launchers=preferred://filemanager,preferred://browser,applications:org.kde.konsole.desktop
maxStripes=1
showOnlyCurrentScreen=false
indicateAudioStreams=true
launchersGroup=Global

[Containments][8][Applets][10]
immutability=1
plugin=org.kde.plasma.trash

[Containments][8][General]
AppletOrder=9;10

[Containments][11]
activityId=
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.desktopcontainment
wallpaperplugin=org.kde.image

[Containments][11][Configuration][General]
showToolbox=false

[ScreenMapping]
itemsOnDisabledScreens=
PANELCONFIG

# Configure blur effects
cat > ~/.config/kwinrc << 'KWINCONFIG'
[Compositing]
Backend=OpenGL
GLTextureFilter=1
WindowsBlockCompositing=false

[Effect-Blur]
BlurStrength=15
NoiseStrength=3

[PlasmaViews][Panel 8][Defaults]
thickness=76
floating=true
panelTransparency=1

[org.kde.kdecoration2]
ButtonsOnLeft=XIA
ButtonsOnRight=
KWINCONFIG

# Configure panel settings
cat > ~/.config/plasmashellrc << 'PLASMASHELLCONFIG'
[PlasmaViews][Panel 1][Defaults]
thickness=38

[PlasmaViews][Panel 8][Defaults]
thickness=76
floating=true
panelTransparency=1

[PlasmaViews][Panel 8][Horizontal]
floating=true
PLASMASHELLCONFIG

# Configure screenshot shortcuts
cat > ~/.config/kglobalshortcutsrc << 'SHORTCUTSCONFIG'
[org.kde.spectacle.desktop][Desktop Entry]
Print=Print,none,Capture Entire Desktop
Shift+Print=Shift+Print,none,Capture Active Window
Meta+Ctrl+S=Meta+Ctrl+S,none,Capture Rectangular Region
Meta+Shift+Print=Meta+Shift+Print,none,Capture Rectangular Region

[krunner][_launch]
_launch=Meta+Space,Alt+Space,KRunner
SHORTCUTSCONFIG

echo "✅ macOS-style dock configured!"
echo ""
echo "To apply changes, restart Plasma:"
echo "  killall plasmashell && plasmashell &"
