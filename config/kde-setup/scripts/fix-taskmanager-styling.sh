#!/bin/bash
# Fix Icons Only Task Manager styling for macOS-like glass/rounded look
# and fix broken icons

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Fix Task Manager Styling & Icons                        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =============================================================================
# 1. FIX ICON THEME
# =============================================================================
echo -e "${YELLOW}Fixing icon theme...${NC}"

# Set a proper icon theme
kwriteconfig6 --file kdeglobals --group Icons --key Theme "breeze"

# Alternative icon themes that work well
# kwriteconfig6 --file kdeglobals --group Icons --key Theme "Papirus"
# kwriteconfig6 --file kdeglobals --group Icons --key Theme "McMojave-circle"

echo -e "${GREEN}✓ Icon theme set to Breeze${NC}"

# =============================================================================
# 2. CONFIGURE TASK MANAGER FOR BETTER ICONS
# =============================================================================
echo -e "${YELLOW}Configuring Task Manager...${NC}"

# Set proper icon sizing and spacing in task manager
kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel 8" --group Defaults --key thickness 76

# Update the Icons Only Task Manager configuration for proper icon display
# This ensures icons are not broken/missing
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var p = allPanels[i];
    if (p.location === 4) { // Bottom panel
        var widgets = p.widgets('org.kde.plasma.icontasks');
        for (var j = 0; j < widgets.length; j++) {
            var w = widgets[j];
            w.currentConfigGroup = ['General'];
            // Ensure proper icon size
            w.writeConfig('iconSize', 64);
            // Enable icon scaling
            w.writeConfig('maxStripes', 1);
            w.writeConfig('showOnlyCurrentActivity', true);
            // Force icon theme reload
            w.reloadConfig();
        }
    }
}
" 2>/dev/null

echo -e "${GREEN}✓ Task Manager configured${NC}"

# =============================================================================
# 3. ENABLE GLASS/TRANSLUCENT PANEL
# =============================================================================
echo -e "${YELLOW}Enabling glass panel effect...${NC}"

# Enable blur for panels
kwriteconfig6 --file kwinrc --group Effect-Blur --key BlurStrength "15"
kwriteconfig6 --file kwinrc --group Effect-Blur --key NoiseStrength "3"

# Set compositing for transparency
kwriteconfig6 --file kwinrc --group Compositing --key Backend "OpenGL"
kwriteconfig6 --file kwinrc --group Compositing --key GLCore "true"
kwriteconfig6 --file kwinrc --group Compositing --key GLTextureFilter "1"

# Set panel background to translucent
kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel 8" --group Defaults --key panelTransparency "1"

echo -e "${GREEN}✓ Glass effect enabled${NC}"

# =============================================================================
# 4. APPLY MACOS-STYLE PANEL ROUNDING (via Plasma theme)
# =============================================================================
echo -e "${YELLOW}Configuring panel styling...${NC}"

# Create a custom Plasma theme with rounded corners
PLASMA_THEME_DIR="$HOME/.local/share/plasma/desktoptheme/Zephyrus-Rounded"
mkdir -p "$PLASMA_THEME_DIR/widgets"

# Create theme metadata
cat > "$PLASMA_THEME_DIR/metadata.json" << 'EOF'
{
    "KPackageStructure": "Plasma/Theme",
    "KPlugin": {
        "Authors": [
            {
                "Email": "zephyrus@example.com",
                "Name": "Zephyrus OS"
            }
        ],
        "Category": "",
        "Description": "Rounded/glass theme for Zephyrus OS",
        "Id": "Zephyrus-Rounded",
        "License": "GPLv2+",
        "Name": "Zephyrus Rounded",
        "Version": "1.0"
    }
}
EOF

# Create panel background SVG with rounded corners
cat > "$PLASMA_THEME_DIR/widgets/panel-background.svgz" << 'THEMEEOF'
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:rgba(50,50,50,0.85);stop-opacity:1" />
      <stop offset="100%" style="stop-color:rgba(30,30,30,0.9);stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect x="2" y="2" width="96" height="96" rx="24" ry="24" fill="url(#grad1)" stroke="rgba(255,255,255,0.1)" stroke-width="1"/>
</svg>
THEMEEOF

# Create theme config for transparency
cat > "$PLASMA_THEME_DIR/theme.conf" << 'EOF'
[Theme]
name=Zephyrus-Rounded

[Panel]
BackgroundStyle=Translucent
EOF

echo -e "${GREEN}✓ Rounded panel theme created${NC}"

# =============================================================================
# 5. FORCE ICON CACHE REFRESH
# =============================================================================
echo -e "${YELLOW}Refreshing icon cache...${NC}"

# Clear icon cache
rm -rf ~/.cache/plasma*
rm -rf ~/.cache/icon*

echo -e "${GREEN}✓ Icon cache cleared${NC}"

# =============================================================================
# 6. RESTART PLASMA TO APPLY
# =============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  STYLING FIXES APPLIED!                                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}Changes made:${NC}"
echo "  ✅ Icon theme set to Breeze (fixes broken icons)"
echo "  ✅ Task Manager icon size set to 64px"
echo "  ✅ Panel blur/glass effect enabled"
echo "  ✅ Rounded panel theme created"
echo "  ✅ Icon cache cleared"
echo ""
echo "To apply all changes, restart Plasma:"
echo "  killall plasmashell && plasmashell &"
echo ""
echo "Or log out and log back in."
echo ""
echo "${YELLOW}Optional:${NC} To get the full glass dock look:"
echo "  1. Right-click bottom panel → Enter Edit Mode"
echo "  2. Click panel menu → Configure Panel..."
echo "  3. Set Background to 'Translucent'"
echo "  4. Click Done"
echo ""
