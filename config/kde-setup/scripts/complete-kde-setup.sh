#!/bin/bash
# Complete Zephyrus OS KDE Setup
# Automates panel configuration, themes, and ROG branding

set -e

ZEPHYRUS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ZEPHYRUS OS - COMPLETE KDE SETUP                        ║${NC}"
echo -e "${BLUE}║  Automating ROG + macOS Factory Experience               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# 1. CREATE ROG COLOR SCHEME FOR KDE
# =============================================================================
echo -e "${YELLOW}Creating ROG Crimson color scheme...${NC}"

mkdir -p ~/.local/share/color-schemes

cat > ~/.local/share/color-schemes/ZephyrusCrimson.colors << 'EOF'
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundNormal=35,35,35
BackgroundAlternate=45,45,45
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Complementary]
BackgroundNormal=13,13,13
BackgroundAlternate=25,25,25
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Header]
BackgroundNormal=20,20,20
BackgroundAlternate=30,30,30
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Header][Inactive]
BackgroundNormal=15,15,15
BackgroundAlternate=25,25,25
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
BackgroundNormal=25,25,25
BackgroundAlternate=35,35,35
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:View]
BackgroundNormal=18,18,18
BackgroundAlternate=25,25,25
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[Colors:Window]
BackgroundNormal=13,13,13
BackgroundAlternate=20,20,20
ForegroundNormal=255,255,255
ForegroundInactive=180,180,180
DecorationFocus=255,51,51
DecorationHover=255,80,80

[General]
ColorScheme=ZephyrusCrimson
Name=Zephyrus Crimson
shadeSortColumn=true

[KWin]
ActiveBackground=20,20,20
ActiveBlend=255,255,255
ActiveForeground=255,255,255
InactiveBackground=15,15,15
InactiveBlend=200,200,200
InactiveForeground=180,180,180

[WM]
activeBackground=20,20,20
activeBlend=255,255,255
activeForeground=255,255,255
inactiveBackground=15,15,15
inactiveBlend=200,200,200
inactiveForeground=180,180,180
activeBlend=255,51,51
EOF

echo -e "${GREEN}✓ ROG color scheme created${NC}"

# =============================================================================
# 2. CREATE ROG PLASMA THEME
# =============================================================================
echo -e "${YELLOW}Creating ROG Plasma theme...${NC}"

mkdir -p ~/.local/share/plasma/desktoptheme/ZephyrusCrimson

cat > ~/.local/share/plasma/desktoptheme/ZephyrusCrimson/metadata.json << 'EOF'
{
    "KPlugin": {
        "Authors": [
            {
                "Email": "solarious@zephyrus.com",
                "Name": "Solarious"
            }
        ],
        "Category": "",
        "Description": "ROG Zephyrus Crimson theme for Plasma",
        "Icon": "preferences-desktop-theme",
        "Id": "ZephyrusCrimson",
        "License": "GPL",
        "Name": "Zephyrus Crimson",
        "Version": "1.0",
        "Website": ""
    },
    "X-Plasma-API-Minimum-Version": "6.0"
}
EOF

echo -e "${GREEN}✓ Plasma theme created${NC}"

# =============================================================================
# 3. CONFIGURE KDE PLASMA SETTINGS
# =============================================================================
echo -e "${YELLOW}Configuring KDE Plasma...${NC}"

# Set window buttons to left (macOS style)
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "XIA"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""

# Set color scheme
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "ZephyrusCrimson"

# Set theme
kwriteconfig6 --file kdeglobals --group kcm_style --key Theme "ZephyrusCrimson"

# Disable screen edge actions
kwriteconfig6 --file kwinrc --group Effect-PresentWindows --key BorderAll ""

# Set up Alt-Tab style
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName "compact"

# Enable blur effects
kwriteconfig6 --file kwinrc --group Compositing --key Backend "OpenGL"
kwriteconfig6 --file kwinrc --group Compositing --key GlTextureFilter "1"

echo -e "${GREEN}✓ Plasma settings configured${NC}"

# =============================================================================
# 4. CREATE PANEL CONFIGURATION
# =============================================================================
echo -e "${YELLOW}Setting up panels...${NC}"

# Backup existing config
cp ~/.config/plasma-org.kde.plasma.desktop-appletsrc ~/.config/plasma-org.kde.plasma.desktop-appletsrc.backup.$(date +%Y%m%d) 2>/dev/null || true

# Create the panel configuration
cat > ~/.config/plasma-org.kde.plasma.desktop-appletsrc << 'PANELCONFIG'
[ActionPlugins][0]
MiddleButton;NoModifier=org.kde.paste
RightButton;NoModifier=org.kde.contextmenu
RightButton;Ctrl=org.kde.switchdesktop
wheel:Vertical;NoModifier=org.kde.switchdesktop

[ActionPlugins][1]
RightButton;NoModifier=org.kde.contextmenu

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
favoritesPortedToKAstats=true
icon=computer-laptop
systemFavorites=suspend\,hibernate\,reboot\,shutdown

[Containments][1][Applets][3]
immutability=1
plugin=org.kde.plasma.pager

[Containments][1][Applets][5]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][1][Applets][5][Configuration]
PreloadWeight=100
SystrayContainmentId=6

[Containments][1][Applets][7]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][1][Applets][8]
immutability=1
plugin=org.kde.plasma.showdesktop

[Containments][1][General]
AppletOrder=2;3;5;7;8

[Containments][12]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][12][Applets][13]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][12][Applets][13][Configuration]
PreloadWeight=42

[Containments][12][Applets][13][Configuration][General]
launchers=preferred://filemanager,preferred://browser,applications:org.kde.konsole.desktop,applications:steam.desktop
maxStripes=1

[Containments][12][General]
AppletOrder=13

[Containments][2]
activityId=82dd571c-8991-4774-8a9f-c80b38bf8e3b
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.desktopcontainment
wallpaperplugin=org.kde.image

[Containments][2][ConfigDialog]
DialogHeight=540
DialogWidth=720

[Containments][2][Configuration]
PreloadWeight=0

[Containments][2][Configuration][General]
ToolBoxButtonState=topcenter
ToolBoxButtonX=248
showToolbox=false

[Containments][2][Wallpaper][org.kde.image][General]
Image=/home/solarious/Desktop/Zephyrus OS/Rog Logo2.png
PreviewImage=/home/solarious/Desktop/Zephyrus OS/Rog Logo2.png
SlidePaths=/usr/share/wallpapers

[Containments][25]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=3
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][25][Applets][26]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][25][Applets][27]
immutability=1
plugin=org.kde.plasma.appmenu

[Containments][25][Applets][28]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][25][Applets][29]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][25][Applets][30]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][25][General]
AppletOrder=26;27;28;29;30

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
0=0
1=0
2=0
3=0
4=0
5=0
6=0
PANELCONFIG

echo -e "${GREEN}✓ Panel configuration created${NC}"

# =============================================================================
# 5. CREATE KEYBOARD SHORTCUTS
# =============================================================================
echo -e "${YELLOW}Setting up keyboard shortcuts...${NC}"

mkdir -p ~/.config/kglobalshortcutsrc

cat > ~/.config/kglobalshortcutsrc << 'EOF'
[ActivityManager]
_name=Activity Manager
switch-to-activity-82dd571c-8991-4774-8a9f-c80b38bf8e3b=none,none,Switch to activity "Default"

[KDE Keyboard Layout Switcher]
Switch to Last-Used Keyboard Layout=Meta+Alt+L,Meta+Alt+L,Switch to Last-Used Keyboard Layout
Switch to Next Keyboard Layout=Meta+Alt+K,Meta+Alt+K,Switch to Next Keyboard Layout

[kaccess]
Toggle Screen Reader On and Off=Meta+Alt+S,Meta+Alt+S,Toggle Screen Reader On and Off

[kcm_touchpad]
Disable Touchpad=Touchpad Off,Touchpad Off,Disable Touchpad
Enable Touchpad=Touchpad On,Touchpad On,Enable Touchpad
Toggle Touchpad=Touchpad Toggle,Touchpad Toggle,Toggle Touchpad

[kded5]
Show System Activity=Ctrl+Esc,Ctrl+Esc,Show System Activity

[khotkeys]
Launch Browser=Meta+B,Meta+B,Launch Browser
Launch Terminal=Meta+Return,Meta+Return,Launch Terminal
Show Desktop=Meta+D,Meta+D,Show Desktop

[krunner]
Run Command=Alt+Space,Alt+Space,Run Command
Run Command on clipboard contents=Alt+Shift+F2,Alt+Shift+F2,Run Command on clipboard contents

[kwin]
Close Window=Alt+F4,Alt+F4,Close Window
Expose=Meta+Tab,Meta+Tab,Expose
ExposeAll=Meta+Shift+Tab,Meta+Shift+Tab,ExposeAll
Kill Window=Meta+Ctrl+Esc,Meta+Ctrl+Esc,Kill Window
Maximize Window=Meta+Up,Meta+Up,Maximize Window
Minimize Window=Meta+Down,Meta+Down,Minimize Window
Move Window=Meta+Shift+Up,Meta+Shift+Up,Move Window
Move Window Down=Meta+Shift+Down,Meta+Shift+Down,Move Window Down
Move Window Left=Meta+Shift+Left,Meta+Shift+Left,Move Window Left
Move Window Right=Meta+Shift+Right,Meta+Shift+Right,Move Window Right
Show Desktop=Meta+D,Meta+D,Show Desktop
Switch One Desktop Down=Meta+Ctrl+Down,Meta+Ctrl+Down,Switch One Desktop Down
Switch One Desktop Up=Meta+Ctrl+Up,Meta+Ctrl+Up,Switch One Desktop Up
Switch One Desktop to the Left=Meta+Ctrl+Left,Meta+Ctrl+Left,Switch One Desktop to the Left
Switch One Desktop to the Right=Meta+Ctrl+Right,Meta+Ctrl+Right,Switch One Desktop to the Right
Switch Window Down=Meta+Alt+Down,Meta+Alt+Down,Switch Window Down
Switch Window Left=Meta+Alt+Left,Meta+Alt+Left,Switch Window Left
Switch Window Right=Meta+Alt+Right,Meta+Alt+Right,Switch Window Right
Switch Window Up=Meta+Alt+Up,Meta+Alt+Up,Switch Window Up
Window Fullscreen=Meta+F,Meta+F,Window Fullscreen
Window Maximize=Meta+M,Meta+M,Window Maximize
Window Minimize=Meta+N,Meta+N,Window Minimize
Window Quick Tile Bottom=Meta+End,Meta+End,Window Quick Tile Bottom
Window Quick Tile Bottom Left=Meta+Home,Meta+Home,Window Quick Tile Bottom Left
Window Quick Tile Bottom Right=Meta+PgDown,Meta+PgDown,Window Quick Tile Bottom Right
Window Quick Tile Left=Meta+Left,Meta+Left,Window Quick Tile Left
Window Quick Tile Right=Meta+Right,Meta+Right,Window Quick Tile Right
Window Quick Tile Top=Meta+PgUp,Meta+PgUp,Window Quick Tile Top
Window Quick Tile Top Left=none,none,Window Quick Tile Top Left
Window Quick Tile Top Right=none,none,Window Quick Tile Top Right
Window Shade=Meta+S,Meta+S,Window Shade
Window to Desktop 1=Meta+!,Meta+!,Window to Desktop 1
Window to Desktop 2=Meta+@,Meta+@,Window to Desktop 2
Window to Desktop 3=Meta+#,Meta+#,Window to Desktop 3
Window to Desktop 4=Meta+$,Meta+$,Window to Desktop 4
Window to Next Desktop=Meta+>,Meta+>,Window to Next Desktop
Window to Previous Desktop=Meta+<,Meta+<,Window to Previous Desktop
view_actual_size=Meta+0,Meta+0,Actual Size
view_zoom_in=Meta+=,Meta+=,Zoom In
view_zoom_out=Meta+-,Meta+-,Zoom Out

[mediacontrol]
Next=Media Next,Media Next,Next Track
PlayPause=Media Play,Media Play,Play/Pause
Previous=Media Previous,Media Previous,Previous Track
Stop=Media Stop,Media Stop,Stop Playback

[org.kde.screensaver]
Lock Session=Meta+L,Meta+L,Lock Session
EOF

echo -e "${GREEN}✓ Keyboard shortcuts configured${NC}"

# =============================================================================
# 6. CREATE ROG MENU ENTRY
# =============================================================================
echo -e "${YELLOW}Creating ROG application menu...${NC}"

mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/zephyrus-settings.desktop << 'EOF'
[Desktop Entry]
Name=Zephyrus Settings
Comment=ROG System Configuration
Exec=systemsettings5
Icon=preferences-system
Type=Application
Categories=Settings;System;
EOF

cat > ~/.local/share/applications/zephyrus-armoury.desktop << 'EOF'
[Desktop Entry]
Name=Armoury Crate
Comment=ROG Gaming Center
Exec=asusctl profile --next
Icon=computer-laptop
Type=Application
Categories=System;Game;
Terminal=false
EOF

echo -e "${GREEN}✓ ROG menu entries created${NC}"

# =============================================================================
# 7. RESTART PLASMA TO APPLY
# =============================================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}SETUP COMPLETE!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Restarting Plasma Shell to apply changes...${NC}"

# Restart KDE
kquitapp6 plasmashell 2>/dev/null || true
sleep 2
kstart6 plasmashell &

# Restart KWin
qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ZEPHYRUS OS KDE IS READY!                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Features configured:"
echo "  ✅ ROG Crimson color scheme"
echo "  ✅ Window buttons on LEFT (macOS style)"
echo "  ✅ Bottom dock panel with icon task manager"
echo "  ✅ Top panel with Global Menu"
echo "  ✅ ROG keyboard shortcuts"
echo "  ✅ ROG wallpaper"
echo ""
echo "Keyboard shortcuts:"
echo "  Meta+Return  - Launch terminal"
echo "  Meta+B       - Launch browser"
echo "  Meta+D       - Show desktop"
echo "  Meta+L       - Lock screen"
echo "  Meta+Arrows  - Window tiling"
echo ""
echo "Run 'zephyrus-about' anytime to see system info"
echo ""
