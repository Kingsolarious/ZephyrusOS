#!/bin/bash
# Apply macOS Big Sur/Monterey style theme to KDE Plasma
# Uses KDE's native Icons Only Task Manager for dock functionality

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  MACOS BIG SUR THEME FOR ZEPHYRUS OS                     ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =============================================================================
# 1. CREATE MACOS COLOR SCHEME
# =============================================================================
echo -e "${YELLOW}Creating macOS color scheme...${NC}"

mkdir -p ~/.local/share/color-schemes

cat > ~/.local/share/color-schemes/macOS.colors << 'EOF'
[ColorEffects:Disabled]
Color=180,180,180
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=180,180,180
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundNormal=240,240,240
BackgroundAlternate=230,230,230
ForegroundNormal=0,0,0
ForegroundInactive=100,100,100
DecorationFocus=0,122,255
DecorationHover=50,150,255

[Colors:Complementary]
BackgroundNormal=30,30,30
BackgroundAlternate=50,50,50
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=0,122,255
DecorationHover=50,150,255

[Colors:Header]
BackgroundNormal=245,245,245
BackgroundAlternate=235,235,235
ForegroundNormal=0,0,0
ForegroundInactive=100,100,100
DecorationFocus=0,122,255
DecorationHover=50,150,255

[Colors:Header][Inactive]
BackgroundNormal=240,240,240
BackgroundAlternate=230,230,230
ForegroundNormal=80,80,80
ForegroundInactive=120,120,120
DecorationFocus=0,122,255
DecorationHover=50,150,255

[Colors:Selection]
BackgroundNormal=0,122,255
BackgroundAlternate=30,140,255
ForegroundNormal=255,255,255
ForegroundInactive=230,230,230
DecorationFocus=50,150,255
DecorationHover=80,170,255

[Colors:Tooltip]
BackgroundNormal=50,50,50
BackgroundAlternate=70,70,70
ForegroundNormal=255,255,255
ForegroundInactive=200,200,200
DecorationFocus=0,122,255
DecorationHover=50,150,255

[Colors:View]
BackgroundNormal=255,255,255
BackgroundAlternate=245,245,245
ForegroundNormal=0,0,0
ForegroundInactive=100,100,100
DecorationFocus=0,122,255
DecorationHover=50,150,255

[Colors:Window]
BackgroundNormal=240,240,240
BackgroundAlternate=230,230,230
ForegroundNormal=0,0,0
ForegroundInactive=100,100,100
DecorationFocus=0,122,255
DecorationHover=50,150,255

[General]
ColorScheme=macOS
Name=macOS Big Sur
shadeSortColumn=true

[KWin]
ActiveBackground=245,245,245
ActiveBlend=0,0,0
ActiveForeground=0,0,0
InactiveBackground=240,240,240
InactiveBlend=100,100,100
InactiveForeground=120,120,120

[WM]
activeBackground=245,245,245
activeBlend=0,122,255
activeForeground=0,0,0
inactiveBackground=240,240,240
inactiveBlend=150,150,150
inactiveForeground=120,120,120
EOF

# Create dark macOS variant for ROG
cat > ~/.local/share/color-schemes/macOS-Dark.colors << 'EOF'
[ColorEffects:Disabled]
Color=80,80,80
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=100,100,100
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundNormal=50,50,50
BackgroundAlternate=60,60,60
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Complementary]
BackgroundNormal=30,30,30
BackgroundAlternate=40,40,40
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Header]
BackgroundNormal=40,40,40
BackgroundAlternate=50,50,50
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Header][Inactive]
BackgroundNormal=35,35,35
BackgroundAlternate=45,45,45
ForegroundNormal=200,200,200
ForegroundInactive=150,150,150
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Selection]
BackgroundNormal=255,51,51
BackgroundAlternate=220,40,40
ForegroundNormal=255,255,255
ForegroundInactive=220,220,220
DecorationFocus=255,80,80
DecorationHover=255,100,100

[Colors:Tooltip]
BackgroundNormal=40,40,40
BackgroundAlternate=50,50,50
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:View]
BackgroundNormal=30,30,30
BackgroundAlternate=40,40,40
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Window]
BackgroundNormal=25,25,25
BackgroundAlternate=35,35,35
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[General]
ColorScheme=macOS-Dark
Name=macOS Dark (ROG Crimson)
shadeSortColumn=true

[KWin]
ActiveBackground=40,40,40
ActiveBlend=255,255,255
ActiveForeground=255,255,255
InactiveBackground=35,35,35
InactiveBlend=150,150,150
InactiveForeground=180,180,180

[WM]
activeBackground=40,40,40
activeBlend=255,51,51
activeForeground=255,255,255
inactiveBackground=35,35,35
inactiveBlend=120,120,120
inactiveForeground=150,150,150
EOF

echo -e "${GREEN}✓ macOS color schemes created${NC}"

# =============================================================================
# 2. APPLY MACOS THEME SETTINGS
# =============================================================================
echo -e "${YELLOW}Applying macOS theme settings...${NC}"

# Set the dark macOS theme (with ROG crimson)
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "macOS-Dark"

# Window decoration - use Breeze with macOS settings
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library "org.kde.breeze"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__SierraBreeze"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "XIA"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""

# Icon theme - use something close to macOS
kwriteconfig6 --file kdeglobals --group Icons --key Theme "breeze"

# Style
kwriteconfig6 --file kcm_style --group Style --key WidgetStyle "Breeze"

# Fonts - macOS uses San Francisco, we'll use Noto as fallback
kwriteconfig6 --file kcmfonts --group General --key font "Noto Sans,11,-1,5,50,0,0,0,0,0"
kwriteconfig6 --file kcmfonts --group General --key fixed "Noto Sans Mono,10,-1,5,50,0,0,0,0,0"
kwriteconfig6 --file kcmfonts --group General --key menuFont "Noto Sans,11,-1,5,50,0,0,0,0,0"
kwriteconfig6 --file kcmfonts --group General --key taskbarFont "Noto Sans,11,-1,5,50,0,0,0,0,0"
kwriteconfig6 --file kcmfonts --group General --key toolBarFont "Noto Sans,11,-1,5,50,0,0,0,0,0"

echo -e "${GREEN}✓ macOS theme applied${NC}"

# =============================================================================
# 3. CONFIGURE PANELS (TOP + DOCK)
# =============================================================================
echo -e "${YELLOW}Configuring panels for macOS look...${NC}"

# Create panel configuration with Icons Only Task Manager for dock
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

[Containments][1][Applets][2][Configuration]
PreloadWeight=100

[Containments][1][Applets][2][Configuration][General]
favorites=preferred://browser,preferred://filemanager,applications:org.kde.konsole.desktop
favoritesPortedToKAstats=true
icon=computer-laptop
systemFavorites=suspend\,hibernate\,reboot\,shutdown

[Containments][1][Applets][3]
immutability=1
plugin=org.kde.plasma.appmenu

[Containments][1][Applets][3][Configuration]
PreloadWeight=42

[Containments][1][Applets][3][Configuration][General]
compactView=true

[Containments][1][Applets][4]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][1][Applets][5]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][1][Applets][5][Configuration]
PreloadWeight=100
SystrayContainmentId=6

[Containments][1][Applets][6]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][1][Applets][6][Configuration]
PreloadWeight=55

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

[Containments][8][Applets][9][Configuration]
PreloadWeight=42

[Containments][8][Applets][9][Configuration][General]
iconSize=64
launchers=preferred://filemanager,preferred://browser,applications:org.kde.konsole.desktop
maxStripes=1
showOnlyCurrentScreen=false
indicateAudioStreams=true
launchersGroup=Global
middleClickAction=ToggleGrouping
showOnlyCurrentActivity=true
showOnlyCurrentDesktop=false
wheelEnabled=false

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

[Containments][11][ConfigDialog]
DialogHeight=540
DialogWidth=720

[Containments][11][Configuration]
PreloadWeight=0

[Containments][11][Configuration][General]
showToolbox=false

[Containments][11][Wallpaper][org.kde.image][General]
Image=/home/solarious/Desktop/Zephyrus OS/Rog Logo2.png
PreviewImage=/home/solarious/Desktop/Zephyrus OS/Rog Logo2.png
SlidePaths=/usr/share/wallpapers

[Containments][6]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=3
plugin=org.kde.plasma.private.systemtray
wallpaperplugin=org.kde.image

[ScreenMapping]
itemsOnDisabledScreens=
PANELCONFIG

# Panel height settings for macOS look
kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel 1" --group Defaults --key thickness 38
kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel 8" --group Defaults --key thickness 76

echo -e "${GREEN}✓ Panels configured${NC}"

# =============================================================================
# 4. ENABLE BLUR EFFECTS
# =============================================================================
echo -e "${YELLOW}Enabling blur effects...${NC}"

kwriteconfig6 --file kwinrc --group Compositing --key Backend "OpenGL"
kwriteconfig6 --file kwinrc --group Compositing --key GLTextureFilter "1"
kwriteconfig6 --file kwinrc --group Compositing --key WindowsBlockCompositing "false"

# Enable blur effect
kwriteconfig6 --file kwinrc --group Effect-Blur --key BlurStrength "20"
kwriteconfig6 --file kwinrc --group Effect-Blur --key NoiseStrength "5"

# Enable background blur for panels
kwriteconfig6 --file kwinrc --group Plasmoids --group "org.kde.panel" --key blurEnabled "true"

echo -e "${GREEN}✓ Blur effects enabled${NC}"

# =============================================================================
# 5. CREATE HELPER SCRIPTS
# =============================================================================
mkdir -p ~/.local/bin

cat > ~/.local/bin/zephyrus-add-dock-icon << 'EOF'
#!/bin/bash
# Add an icon to the Icons Only Task Manager dock
# Usage: zephyrus-add-dock-icon firefox.desktop

APP="$1"

if [ -z "$APP" ]; then
    echo "Usage: zephyrus-add-dock-icon <desktop-file>"
    echo "Example: zephyrus-add-dock-icon firefox.desktop"
    exit 1
fi

# Find the desktop file
if [ -f "/usr/share/applications/$APP" ]; then
    DESKTOP_FILE="/usr/share/applications/$APP"
elif [ -f "$HOME/.local/share/applications/$APP" ]; then
    DESKTOP_FILE="$HOME/.local/share/applications/$APP"
elif [ -f "$APP" ]; then
    DESKTOP_FILE="$APP"
else
    echo "Desktop file not found: $APP"
    exit 1
fi

# Add to dock via Plasma script
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var p = allPanels[i];
    if (p.location === 4) { // Bottom panel
        var widgets = p.widgets('org.kde.plasma.icontasks');
        for (var j = 0; j < widgets.length; j++) {
            var w = widgets[j];
            w.currentConfigGroup = ['General'];
            var current = w.readConfig('launchers') || '';
            if (current) current += ',';
            current += 'file://$DESKTOP_FILE';
            w.writeConfig('launchers', current);
        }
    }
}
" 2>/dev/null

echo "Added $APP to dock"
EOF

chmod +x ~/.local/bin/zephyrus-add-dock-icon

echo -e "${GREEN}✓ Dock management tool created${NC}"

# =============================================================================
# 6. RESTART TO APPLY
# =============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  MACOS THEME APPLIED!                                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Changes:"
echo "  ✅ macOS Dark color scheme with ROG Crimson accents"
echo "  ✅ Window buttons on LEFT (red/yellow/green dots)"
echo "  ✅ Top menu bar with Global Menu"
echo "  ✅ Bottom dock with Icons Only Task Manager (64px icons)"
echo "  ✅ Blur effects enabled"
echo "  ✅ macOS-style date format"
echo ""
echo "To add apps to dock:"
echo "  Method 1: Right-click app in Application Menu → 'Pin to Task Manager'"
echo "  Method 2: zephyrus-add-dock-icon firefox.desktop"
echo ""
echo "Restart Plasma to apply all changes:"
echo "  killall plasmashell && plasmashell &"
echo ""
