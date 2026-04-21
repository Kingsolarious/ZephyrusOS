#!/bin/bash
# Setup FN+F5 to use Enhanced Thermal Profiles
# Integrates ASUS profile switching with optimized power limits

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  FN+F5 Enhanced Thermal Profile Setup                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Install the enhanced profile switcher
echo -e "${YELLOW}Installing enhanced profile switcher...${NC}"
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/zephyrus-profile-enhanced.sh" ~/.local/bin/zephyrus-profile-enhanced
chmod +x ~/.local/bin/zephyrus-profile-enhanced
echo -e "${GREEN}✓ Installed: ~/.local/bin/zephyrus-profile-enhanced${NC}"

# Backup existing scripts
if [ -f ~/.local/bin/asus-profile-cycle ]; then
    cp ~/.local/bin/asus-profile-cycle ~/.local/bin/asus-profile-cycle.backup
    echo -e "${YELLOW}✓ Backed up existing asus-profile-cycle${NC}"
fi

# Replace the cycle script with our enhanced version
cat > ~/.local/bin/asus-profile-cycle << 'EOF'
#!/bin/bash
# Wrapper to use enhanced profile switcher
exec ~/.local/bin/zephyrus-profile-enhanced cycle "$@"
EOF
chmod +x ~/.local/bin/asus-profile-cycle
echo -e "${GREEN}✓ Updated: ~/.local/bin/asus-profile-cycle${NC}"

# Also update zephyrus-control-center
cat > ~/.local/bin/zephyrus-control-center << 'EOF'
#!/bin/bash
# Zephyrus Control Center - Enhanced with Power Limits

case "$1" in
    cycle|--cycle|-c)
        exec ~/.local/bin/zephyrus-profile-enhanced cycle
        ;;
    silent|quiet|--silent|-s)
        exec ~/.local/bin/zephyrus-profile-enhanced quiet
        ;;
    balanced|--balanced|-b)
        exec ~/.local/bin/zephyrus-profile-enhanced balanced
        ;;
    performance|--performance|-p)
        exec ~/.local/bin/zephyrus-profile-enhanced performance
        ;;
    status|--status)
        exec ~/.local/bin/zephyrus-profile-enhanced status
        ;;
    *)
        # Launch ROG Control Center GUI
        exec /home/solarious/.local/bin/rog-control-center "$@"
        ;;
esac
EOF
chmod +x ~/.local/bin/zephyrus-control-center
echo -e "${GREEN}✓ Updated: ~/.local/bin/zephyrus-control-center${NC}"

echo ""
echo -e "${YELLOW}Creating keyboard shortcuts...${NC}"

# Create the KDE shortcut config file
mkdir -p ~/.config/khotkeys
cat > ~/.config/khotkeys/zephyrus-profiles.khotkeys << 'KCONF'
[Data]
DataCount=3

[Data_1]
Comment=Cycle ASUS Performance Profile with FN+F5
Enabled=true
Name=ASUS Profile Cycle (FN+F5)
Type=SIMPLE_ACTION_DATA

[Data_1Actions]
ActionsCount=1

[Data_1Actions0]
CommandURL=~/.local/bin/zephyrus-profile-enhanced cycle
Type=COMMAND_URL

[Data_1Conditions]
Comment=
ConditionsCount=0

[Data_1Triggers]
Comment=Simple_action
TriggersCount=1

[Data_1Triggers0]
Key=Fn+F5
Type=SHORTCUT
Uuid={00000000-0000-0000-0000-000000000001}

[Data_2]
Comment=Quick status display
Enabled=true
Name=ROG Quick Status
Type=SIMPLE_ACTION_DATA

[Data_2Actions]
ActionsCount=1

[Data_2Actions0]
CommandURL=konsole -e ~/.local/bin/zephyrus-profile-enhanced status
Type=COMMAND_URL

[Data_2Conditions]
Comment=
ConditionsCount=0

[Data_2Triggers]
Comment=Simple_action
TriggersCount=1

[Data_2Triggers0]
Key=Meta+Shift+R
Type=SHORTCUT
Uuid={00000000-0000-0000-0000-000000000002}

[Data_3]
Comment=Thermal monitor
Enabled=true
Name=ROG Thermal Monitor
Type=SIMPLE_ACTION_DATA

[Data_3Actions]
ActionsCount=1

[Data_3Actions0]
CommandURL=konsole -e ~/Desktop/Zephyrus\ OS/thermal-monitor-simple.sh
Type=COMMAND_URL

[Data_3Conditions]
Comment=
ConditionsCount=0

[Data_3Triggers]
Comment=Simple_action
TriggersCount=1

[Data_3Triggers0]
Key=Meta+Shift+M
Type=SHORTCUT
Uuid={00000000-0000-0000-0000-000000000003}

[Main]
AllowKHotKeysStart=true
ImportId=zephyrus-profiles
KCONF

echo -e "${GREEN}✓ Keyboard shortcuts configured${NC}"

# Create desktop entries for the modes
mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/zephyrus-silent.desktop << 'EOF'
[Desktop Entry]
Name=ROG Silent Mode
Comment=Switch to Silent mode (25W/50W) - Ultra cool
Exec=~/.local/bin/zephyrus-profile-enhanced quiet
Type=Application
Terminal=false
Icon=audio-volume-muted
Categories=Settings;System;
EOF

cat > ~/.local/share/applications/zephyrus-balanced.desktop << 'EOF'
[Desktop Entry]
Name=ROG Balanced Mode
Comment=Switch to Balanced mode (45W/60W) - Daily use
Exec=~/.local/bin/zephyrus-profile-enhanced balanced
Type=Application
Terminal=false
Icon=preferences-system-performance
Categories=Settings;System;
EOF

cat > ~/.local/share/applications/zephyrus-performance.desktop << 'EOF'
[Desktop Entry]
Name=ROG Performance Mode
Comment=Switch to Performance mode (65W/80W) - Gaming
Exec=~/.local/bin/zephyrus-profile-enhanced performance
Type=Application
Terminal=false
Icon=applications-games
Categories=Settings;System;
EOF

cat > ~/.local/share/applications/zephyrus-status.desktop << 'EOF'
[Desktop Entry]
Name=ROG System Status
Comment=Show current power and thermal status
Exec=konsole -e ~/.local/bin/zephyrus-profile-enhanced status
Type=Application
Terminal=false
Icon=utilities-system-monitor
Categories=System;Monitor;
EOF

update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
echo -e "${GREEN}✓ Desktop entries created${NC}"

echo ""
echo -e "${YELLOW}Setting initial profile...${NC}"
~/.local/bin/zephyrus-profile-enhanced balanced 2>/dev/null || true
echo -e "${GREEN}✓ Started in Balanced mode${NC}"

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Setup Complete!                                         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Keyboard Shortcuts:"
echo "  🔥 FN+F5           - Cycle profiles (Silent → Balanced → Performance)"
echo "  📊 Meta+Shift+R    - Show system status"
echo "  🌡️ Meta+Shift+M    - Open thermal monitor"
echo ""
echo "Command Line:"
echo "  zephyrus-profile-enhanced cycle        - Cycle to next profile"
echo "  zephyrus-profile-enhanced quiet        - Silent mode (25W/50W)"
echo "  zephyrus-profile-enhanced balanced     - Balanced mode (45W/60W)"
echo "  zephyrus-profile-enhanced performance  - Gaming mode (65W/80W)"
echo "  zephyrus-profile-enhanced status       - Show current status"
echo ""
echo "Desktop Entries:"
echo "  Search 'ROG' in Activities to find all modes"
echo ""
echo -e "${YELLOW}Note: You may need to restart KDE for FN+F5 to work.${NC}"
echo "      Or run: kquitapp5 kglobalaccel && sleep 2 && kglobalaccel5 &"
echo ""
echo "Profile Power Limits:"
echo "  🔇 Silent:     CPU 25W / GPU 50W  - Office, battery"
echo "  ⚖️ Balanced:   CPU 45W / GPU 60W  - Daily use"
echo "  🚀 Performance: CPU 65W / GPU 80W - Gaming"
echo ""
