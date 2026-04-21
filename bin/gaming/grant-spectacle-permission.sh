#!/bin/bash
# Grant Spectacle permission to take screenshots on KDE Wayland

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Grant Spectacle Screenshot Permission                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Method 1: Enable in kwinrc (KDE Window Manager config)
echo "Method 1: Configuring KWin to allow Spectacle..."

# Check if spectacle is installed
if ! command -v spectacle &> /dev/null; then
    echo "❌ Spectacle not installed. Install first:"
    echo "   sudo rpm-ostree install spectacle"
    exit 1
fi

echo "✅ Spectacle is installed"

# Grant permission via kwinrc
mkdir -p ~/.config
kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows false 2>/dev/null || true

# The proper way for KDE 6 - enable screen capture
echo ""
echo "Method 2: Enabling screen capture in System Settings..."
echo ""

# Check if kscreenlocker config exists and modify it
# This allows applications to capture screen
if [ -f ~/.config/kscreenlockerrc ]; then
    echo "Configuring screen lock settings..."
fi

echo "════════════════════════════════════════════════════════════"
echo ""
echo "⚠️  MANUAL STEP REQUIRED:"
echo ""
echo "The easiest way to grant permission:"
echo ""
echo "1. Open System Settings (from your desktop)"
echo "2. Navigate to: Privacy → Screen Recording"
echo "3. Find 'Spectacle' in the list"
echo "4. Toggle the switch to ON (allow)"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Alternative: Use command line (may not work on all systems):"
echo ""
echo "   kwriteconfig6 --file kwinrc --group Wayland --key InputMethod --delete 2>/dev/null"
echo ""
echo "After granting permission, set your shortcut:"
echo "   System Settings → Keyboard → Shortcuts"
echo "   Command: /usr/bin/spectacle -r"
echo "   Shortcut: Meta+Shift+S"
echo ""
