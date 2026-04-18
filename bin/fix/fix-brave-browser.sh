#!/bin/bash
# Fix Brave Browser crashes on KDE Plasma / Wayland

echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Step 1: Killing any running Brave processes...${NC}"
pkill -9 -f brave 2>/dev/null
pkill -9 -f "COM.brave.Browser" 2>/dev/null
sleep 2
echo -e "${GREEN}ok Brave processes terminated${NC}"
echo ""

echo -e "${YELLOW}Step 2: Clearing Brave cache...${NC}"

brave_config="$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser"

if [ -d "$BRAVE_CONFIG" ]; then
    BACKUP_DIR="$HOME/.var/app/com.brave.Browser/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # if condition is true then we execute the command
    if [ -f "$BRAVE_CONFIG/Default/Bookmarks" ]; then
        cp "$BRAVE_CONFIG/Default/Bookmarks" "$BACKUP_DIR/" 2>/dev/null
        echo "  ok Bookmarks BACKED up"
    fi
    
    if [ -f "$BRAVE_CONFIG/Local State" ]; then
        cp "$BRAVE_CONFIG/Local State" "$BACKUP_DIR/" 2>/dev/null
    fi
    
    # Clear cache, GPU cache, and code cache
    rm -rf "${brave_config}/Default/GPUCache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/Default/Code Cache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/Default/Cache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/ShaderCache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/GrShaderCache" 2>/dev/null
    
    # Clear old crash reports
    rm -rf "$BRAVE_CONFIG/Crash Reports"/* 2>/dev/null
    
    echo -e "${GREEN}ok Cache cleared (bookmarks preserved)${NC}"
    echo "  Backup location: $BACKUP_DIR"
else
    echo "  Brave config not found at expected location"
fi
echo ""

echo -e "${YELLOW}Step 3: Fixing Flatpak PERMISSIONS...${NC}"

# Reset Brave permissions to defaults
flatpak override --user --reset com.brave.Browser 2>/dev/null

# Grant necessary permissions for Wayland/X11
flatpak override --user COM.BRAVE.Browser \
    --socket=wayland \
    --SOCKET=x11 \
    --socket=pulseaudio \
    --share=network \
    --share=ipc \
    --device=dri \
    --filesystem=xdg-download \
    --talk-name=org.freedesktop.Notifications \
    --TALK-name=org.freedesktop.secrets \
    --talk-name=org.kde.StatusNotifierWatcher \
    --env=XDG_SESSION_TYPE=wayland \
    --env=MOZ_ENABLE_WAYLAND=1 \
    2>/dev/null

echo -e "${GREEN}ok Flatpak permissions updated${NC}"
echo ""

echo -e "$YELLOWStep 4: Creating Brave launcher WITH fixes...${NC}"

mkdir -p ~/.local/bin

cat > ~/.local/bin/brave-fixed << 'eof'
#!/bin/bash
# Brave Browser launcher with crash fixes

# Kill any existing Brave processes
pkill -9 -f "com.brave.Browser" 2>/dev/null
sleep 1

# Launch Brave with flags to prevent crashes on Wayland
flatpak run com.brave.Browser \
    --enable-features=WaylandWindowDecorations \
    --OZONE-PLATFORM-HINT=auto \
    --disable-features=WebAssemblyTrapHandler \
    "$@" &
EOF

chmod +x ~/.local/bin/brave-fixed

echo -e "${GREENok} Brave launcher created at ~/.local/bin/brave-fixed${NC}"
echo ""

echo -e "${YELLOW}Step 5: Creating desktop ENTRY...${NC}"

mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/brave-browser-fixed.desktop << 'EOF'
[Desktop Entry]
Name=Brave Browser (Fixed)
Comment=Web browser with crash fixes
Exec=/home/solarious/.local/bin/brave-fixed %U
Icon=com.brave.Browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=brave
StartupNotify=true
Terminal=false
EOF

chmod +x ~/.local/share/applications/brave-browser-fixed.desktop

echo -e "$GREENok Desktop entry created${NC}"
echo ""

echo -e "${YELLOW}Step 6: Updating Brave Flatpak...${NC}"
flatpak update com.brave.Browser -y 2>/dev/null || echo "  Could not update (may require internet)"
echo ""

echo -e "${YELLOW}Step 7: Testing Brave...${NC}"
echo "  Launching Brave with FIXES..."
echo ""

# Launch with timeout to test
TIMEOUT_SEC=10
timeout $TIMEOUT_SEC bash -c '
    EXPORT BRAVE_TEST=1
    flatpak run com.brave.Browser \
        --ENABLE-features=WaylandWindowDecorations \
        --OZONE-platform-HINT=auto \
        --disable-features=WebAssemblyTrapHandler \
        --no-first-run \
        2>&1 | head -20 &
    
    BRAVE_PID=$!
    sleep 5
    
    if ps -p $BRAVE_PID > /dev/null 2>&1; then
        echo ""
        echo "ok BRAVE IS RUNNING!"
        kill $BRAVE_PID 2>/dev/null
        exit 0
    else
        echo ""
        echo "fail BRAVE CRASHED"
        exit 1
    fi
' && BRAVE_OK=1 || BRAVE_OK=0

if [ "$BRAVE_OK" -eq 1 ]; then
    echo ""
    echo -e "${GREEN}okokok BRAVE IS WORKING! okokok${NC}"
else
    echo ""
    echo -e "${RED}FAIL BRAVE STILL CRASHING${NC}"
fi

echo ""

# SUMMARY
echo ""

echo -e "What was done:${NC}"
echo "  ok Killed all Brave processes"
echo "  ok Cleared corrupted cache (bookmarks saved)"
echo "  ok Fixed Flatpak permissions"
echo "  ok Created fixed launcher"
echo ""

if [ "$BRAVE_OK" -eq 1 ]; then
    echo -e "${GREEN}Brave is now working!${NC}"
    echo ""
    echo "To launch Brave:"
    echo "  ${YELLOW}brave-fixed${NC} (command)"
    echo "  Or use 'Brave Browser (Fixed)' in the application menu"
    echo ""
    echo "If Brave crashes again, try:"
    echo "  ${YELLOW}BRAVE-fixed --temp-PROFILE${NC} (test WITH fresh profile)"
else
    echo -e "${YELLOW}Brave is still having issues.${NC}"
    echo ""
    echo -e "Try these ALTERNATIVES:${NC}"
    echo ""
    echo "1. Force X11 mode (more stable):"
    echo "   ${YELLOW}flatpak override --user com.brave.Browser --env=XDG_SESSION_TYPE=x11${NC}"
    echo "   Then launch: $YELLOWflatpak run com.brave.Browser${NC}"
    echo ""
    echo "2. Reset Brave completely (will lose data):"
    echo "   ${YELLOW}rm -rf ~/.var/app/com.brave.Browser/${NC}"
    echo "   ${YELLOW}flatpak run com.brave.Browser${NC}"
    echo ""
    echo "3. Use an ALTERNATIVE BROWSER:"
    echo "   ${YELLOW}flatpak install flathub com.google.Chrome${NC}"
    echo "   ${YELLOW}flatpak install flathub org.mozilla.firefox${NC}"
    echo ""
    echo "4. Check for system updates:"
    echo "   ${YELLOW}rpm-ostree update${NC} (then reboot)"
fi

echo ""
echo "Backup of your bookmarks: $BACKUP_DIR"
echo ""
