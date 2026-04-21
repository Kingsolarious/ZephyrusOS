#!/bin/bash
# Install Zephyrus Dock - Hardcoded ROG dock

set -e

DOCK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/share/zephyrus-desktop"
BIN_DIR="$HOME/.local/bin"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Install Zephyrus Dock                                    ║"
echo "║  Hardcoded ROG-themed dock - No extensions!               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Create directories
mkdir -p "$INSTALL_DIR/dock"
mkdir -p "$INSTALL_DIR/icons/dock"
mkdir -p "$BIN_DIR"
mkdir -p "$HOME/.config/systemd/user"

# Copy dock application
cp "$DOCK_DIR/zephyrus-dock.py" "$INSTALL_DIR/dock/"
chmod +x "$INSTALL_DIR/dock/zephyrus-dock.py"

# Create launcher
cat > "$BIN_DIR/zephyrus-dock" << 'EOF'
#!/bin/bash
python3 ~/.local/share/zephyrus-desktop/dock/zephyrus-dock.py "$@"
EOF
chmod +x "$BIN_DIR/zephyrus-dock"

# Create systemd service for autostart
cat > "$HOME/.config/systemd/user/zephyrus-dock.service" << 'EOF'
[Unit]
Description=Zephyrus Dock
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/zephyrus-dock
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF

# Create placeholder icons (user should replace with real ROG icons)
mkdir -p "$INSTALL_DIR/icons/dock"

# Create simple SVG placeholders
cat > "$INSTALL_DIR/icons/dock/rog-files.svg" << 'EOF'
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="folderGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#3a1015"/>
      <stop offset="100%" style="stop-color:#1a0508"/>
    </linearGradient>
  </defs>
  <!-- Folder shape -->
  <rect x="4" y="20" width="56" height="40" rx="4" fill="url(#folderGrad)" stroke="#ff0033" stroke-width="2"/>
  <path d="M4 24 L12 12 L28 12 L32 20" fill="url(#folderGrad)" stroke="#ff0033" stroke-width="2"/>
  <!-- ROG Eye simplified -->
  <path d="M20 40 Q32 32 44 40 Q38 46 32 44 Q26 46 20 40" fill="#ff0033"/>
  <path d="M24 38 L32 35 L40 38" stroke="#ff0033" stroke-width="2" fill="none"/>
</svg>
EOF

cat > "$INSTALL_DIR/icons/dock/rog-gamepad.svg" << 'EOF'
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="padGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#ff0033"/>
      <stop offset="100%" style="stop-color:#aa0022"/>
    </linearGradient>
  </defs>
  <!-- Gamepad body -->
  <rect x="8" y="20" width="48" height="32" rx="16" fill="url(#padGrad)" stroke="#cc0022" stroke-width="2"/>
  <!-- D-pad -->
  <rect x="18" y="32" width="4" height="12" fill="#333"/>
  <rect x="14" y="36" width="12" height="4" fill="#333"/>
  <!-- Buttons -->
  <circle cx="44" cy="34" r="3" fill="#333"/>
  <circle cx="48" cy="38" r="3" fill="#333"/>
  <circle cx="40" cy="38" r="3" fill="#333"/>
  <circle cx="44" cy="42" r="3" fill="#333"/>
  <!-- Center X -->
  <text x="32" y="40" font-size="12" text-anchor="middle" fill="white" font-weight="bold">+</text>
</svg>
EOF

cat > "$INSTALL_DIR/icons/dock/rog-folder.svg" << 'EOF'
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="folderGrad2" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#4a4a4a"/>
      <stop offset="100%" style="stop-color:#2a2a2a"/>
    </linearGradient>
  </defs>
  <rect x="4" y="20" width="56" height="40" rx="4" fill="url(#folderGrad2)" stroke="#ff0033" stroke-width="2"/>
  <path d="M4 24 L12 12 L28 12 L32 20" fill="url(#folderGrad2)" stroke="#ff0033" stroke-width="2"/>
  <!-- ROG Wing -->
  <path d="M18 42 L32 36 L46 42 L32 48 Z" fill="#ff0033"/>
</svg>
EOF

cat > "$INSTALL_DIR/icons/dock/rog-terminal.svg" << 'EOF'
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="termGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#1a1a1a"/>
      <stop offset="100%" style="stop-color:#0a0a0a"/>
    </linearGradient>
  </defs>
  <rect x="4" y="8" width="56" height="48" rx="8" fill="url(#termGrad)" stroke="#ff0033" stroke-width="3"/>
  <!-- Terminal prompt -->
  <text x="12" y="30" font-family="monospace" font-size="16" fill="#ff0033" font-weight="bold">&gt;_</text>
  <!-- Cursor -->
  <rect x="44" y="18" width="8" height="3" fill="#ff0033"/>
</svg>
EOF

echo "✓ Zephyrus Dock installed!"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "TO START THE DOCK:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Method 1: Run manually"
echo "  zephyrus-dock"
echo ""
echo "Method 2: Auto-start on login"
echo "  systemctl --user daemon-reload"
echo "  systemctl --user enable zephyrus-dock.service"
echo "  systemctl --user start zephyrus-dock.service"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "DOCK FEATURES:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  • Crimson gradient background with glow"
echo "  • ROG-themed icons (customizable)"
echo "  • Hover animations (lift up)"
echo "  • No extensions required"
echo "  • Auto-start with system"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "CUSTOMIZE ICONS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Replace icons in:"
echo "  ~/.local/share/zephyrus-desktop/icons/dock/"
echo ""
echo "Icon files:"
echo "  • rog-files.svg"
echo "  • rog-gamepad.svg"
echo "  • rog-folder.svg"
echo "  • rog-terminal.svg"
echo ""
echo "Create your own ROG-themed SVG icons!"
echo ""
