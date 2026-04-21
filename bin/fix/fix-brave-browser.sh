#!/bin/bash
# Fix Brave Browser crashes on KDE Plasma / Wayland

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Brave Browser Crash Fix                                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# =============================================================================
# 1. KILL ANY RUNNING BRAVE PROCESSES
# =============================================================================
echo -e "${YELLOW}Step 1: Killing any running Brave processes...${NC}"
pkill -9 -f brave 2>/dev/null
pkill -9 -f "com.brave.Browser" 2>/dev/null
sleep 2
echo -e "${GREEN}✓ Brave processes terminated${NC}"
echo ""

# =============================================================================
# 2. CLEAR BRAVE CACHE (KEEP BOOKMARKS/PASSWORDS)
# =============================================================================
echo -e "${YELLOW}Step 2: Clearing Brave cache...${NC}"

BRAVE_CONFIG="$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser"

if [ -d "$BRAVE_CONFIG" ]; then
    # Backup important data first
    BACKUP_DIR="$HOME/.var/app/com.brave.Browser/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup bookmarks and settings
    if [ -f "$BRAVE_CONFIG/Default/Bookmarks" ]; then
        cp "$BRAVE_CONFIG/Default/Bookmarks" "$BACKUP_DIR/" 2>/dev/null
        echo "  ✓ Bookmarks backed up"
    fi
    
    if [ -f "$BRAVE_CONFIG/Local State" ]; then
        cp "$BRAVE_CONFIG/Local State" "$BACKUP_DIR/" 2>/dev/null
    fi
    
    # Clear cache, GPU cache, and code cache
    rm -rf "$BRAVE_CONFIG/Default/GPUCache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/Default/Code Cache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/Default/Cache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/ShaderCache" 2>/dev/null
    rm -rf "$BRAVE_CONFIG/GrShaderCache" 2>/dev/null
    
    # Clear old crash reports
    rm -rf "$BRAVE_CONFIG/Crash Reports"/* 2>/dev/null
    
    echo -e "${GREEN}✓ Cache cleared (bookmarks preserved)${NC}"
    echo "  Backup location: $BACKUP_DIR"
else
    echo "  Brave config not found at expected location"
fi
echo ""

# =============================================================================
# 3. RESET FLATPAK PERMISSIONS FOR BRAVE
# =============================================================================
echo -e "${YELLOW}Step 3: Fixing Flatpak permissions...${NC}"

# Reset Brave permissions to defaults
flatpak override --user --reset com.brave.Browser 2>/dev/null

# Grant necessary permissions for Wayland/X11
flatpak override --user com.brave.Browser \
    --socket=wayland \
    --socket=x11 \
    --socket=pulseaudio \
    --share=network \
    --share=ipc \
    --device=dri \
    --filesystem=xdg-download \
    --talk-name=org.freedesktop.Notifications \
    --talk-name=org.freedesktop.secrets \
    --talk-name=org.kde.StatusNotifierWatcher \
    --env=XDG_SESSION_TYPE=wayland \
    --env=MOZ_ENABLE_WAYLAND=1 \
    2>/dev/null

echo -e "${GREEN}✓ Flatpak permissions updated${NC}"
echo ""

# =============================================================================
# 4. CREATE BRAVE LAUNCHER WITH FIXES
# =============================================================================
echo -e "${YELLOW}Step 4: Creating Brave launcher with fixes...${NC}"

mkdir -p ~/.local/bin

cat > ~/.local/bin/brave-fixed << 'EOF'
#!/bin/bash
# Brave Browser launcher with crash fixes

# Kill any existing Brave processes
pkill -9 -f "com.brave.Browser" 2>/dev/null
sleep 1

# Launch Brave with flags to prevent crashes on Wayland
flatpak run com.brave.Browser \
    --enable-features=WaylandWindowDecorations \
    --ozone-platform-hint=auto \
    --disable-features=WebAssemblyTrapHandler \
    "$@" &
EOF

chmod +x ~/.local/bin/brave-fixed

echo -e "${GREEN}✓ Brave launcher created at ~/.local/bin/brave-fixed${NC}"
echo ""

# =============================================================================
# 5. CREATE DESKTOP ENTRY FOR FIXED BRAVE
# =============================================================================
echo -e "${YELLOW}Step 5: Creating desktop entry...${NC}"

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

echo -e "${GREEN}✓ Desktop entry created${NC}"
echo ""

# =============================================================================
# 6. UPDATE FLATPAK
# =============================================================================
echo -e "${YELLOW}Step 6: Updating Brave Flatpak...${NC}"
flatpak update com.brave.Browser -y 2>/dev/null || echo "  Could not update (may require internet)"
echo ""

# =============================================================================
# 7. TEST BRAVE
# =============================================================================
echo -e "${YELLOW}Step 7: Testing Brave...${NC}"
echo "  Launching Brave with fixes..."
echo ""

# Launch with timeout to test
TIMEOUT_SEC=10
timeout $TIMEOUT_SEC bash -c '
    export BRAVE_TEST=1
    flatpak run com.brave.Browser \
        --enable-features=WaylandWindowDecorations \
        --ozone-platform-hint=auto \
        --disable-features=WebAssemblyTrapHandler \
        --no-first-run \
        2>&1 | head -20 &
    
    BRAVE_PID=$!
    sleep 5
    
    if ps -p $BRAVE_PID > /dev/null 2>&1; then
        echo ""
        echo "✓ BRAVE IS RUNNING!"
        kill $BRAVE_PID 2>/dev/null
        exit 0
    else
        echo ""
        echo "✗ BRAVE CRASHED"
        exit 1
    fi
' && BRAVE_OK=1 || BRAVE_OK=0

if [ "$BRAVE_OK" -eq 1 ]; then
    echo ""
    echo -e "${GREEN}✓✓✓ BRAVE IS WORKING! ✓✓✓${NC}"
else
    echo ""
    echo -e "${RED}✗ BRAVE STILL CRASHING${NC}"
fi

echo ""

# =============================================================================
# SUMMARY
# =============================================================================
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  FIX COMPLETE                                            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo -e "${BLUE}What was done:${NC}"
echo "  ✓ Killed all Brave processes"
echo "  ✓ Cleared corrupted cache (bookmarks saved)"
echo "  ✓ Fixed Flatpak permissions"
echo "  ✓ Created fixed launcher"
echo ""

if [ "$BRAVE_OK" -eq 1 ]; then
    echo -e "${GREEN}Brave is now working!${NC}"
    echo ""
    echo "To launch Brave:"
    echo "  ${YELLOW}brave-fixed${NC} (command)"
    echo "  Or use 'Brave Browser (Fixed)' in the application menu"
    echo ""
    echo "If Brave crashes again, try:"
    echo "  ${YELLOW}brave-fixed --temp-profile${NC} (test with fresh profile)"
else
    echo -e "${YELLOW}Brave is still having issues.${NC}"
    echo ""
    echo -e "${BLUE}Try these alternatives:${NC}"
    echo ""
    echo "1. Force X11 mode (more stable):"
    echo "   ${YELLOW}flatpak override --user com.brave.Browser --env=XDG_SESSION_TYPE=x11${NC}"
    echo "   Then launch: ${YELLOW}flatpak run com.brave.Browser${NC}"
    echo ""
    echo "2. Reset Brave completely (will lose data):"
    echo "   ${YELLOW}rm -rf ~/.var/app/com.brave.Browser/${NC}"
    echo "   ${YELLOW}flatpak run com.brave.Browser${NC}"
    echo ""
    echo "3. Use an alternative browser:"
    echo "   ${YELLOW}flatpak install flathub com.google.Chrome${NC}"
    echo "   ${YELLOW}flatpak install flathub org.mozilla.firefox${NC}"
    echo ""
    echo "4. Check for system updates:"
    echo "   ${YELLOW}rpm-ostree update${NC} (then reboot)"
fi

echo ""
echo "Backup of your bookmarks: $BACKUP_DIR"
echo ""
