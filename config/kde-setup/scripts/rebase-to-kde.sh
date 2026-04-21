#!/bin/bash
# Rebase from GNOME to KDE Plasma
# Run this on HOST (not in container!)

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ZEPHYRUS OS → KDE PLASMA REBASE                          ║"
echo "║                                                           ║"
echo "║  This will replace GNOME 49 with KDE Plasma 6             ║"
echo "║  Reboot required after completion                         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Verify we're on host, not container
if [ -n "$TOOLBOX_PATH" ] || [ -f "/run/.containerenv" ]; then
    echo "❌ ERROR: You're in a container (toolbox/docker)!"
    echo ""
    echo "You MUST run this on the host system."
    echo ""
    echo "Exit the container first:"
    echo "  exit"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Show current status
echo "Current system:"
echo "  Hostname: $(hostname)"
echo "  User: $USER"
echo ""

# Check current DE
if command -v gnome-shell &>/dev/null; then
    echo "✓ GNOME detected - will be replaced with KDE"
elif command -v plasmashell &>/dev/null; then
    echo "✓ KDE already installed!"
    echo "  Run install-kde-zephyrus.sh instead of rebasing."
    exit 0
else
    echo "? Desktop environment not detected"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "DETECTING OSTREE REMOTE"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Detect available remotes
if ostree remote list 2>/dev/null | grep -q "fedora-kinoite"; then
    REMOTE="fedora-kinoite"
    echo "✓ Found remote: fedora-kinoite"
    KDE_TARGET="kinoite"
elif ostree remote list 2>/dev/null | grep -q "bazzite"; then
    REMOTE="bazzite"
    echo "✓ Found remote: bazzite"
    KDE_TARGET="kde"
elif ostree remote list 2>/dev/null | grep -q "fedora"; then
    REMOTE="fedora"
    echo "✓ Found remote: fedora"
    KDE_TARGET="kde"
else
    # List all remotes
    echo "Available remotes:"
    ostree remote list 2>/dev/null || echo "Could not list remotes"
    
    echo ""
    echo "Trying common remotes..."
    
    # Try to determine from current deployment
    CURRENT_REF=$(rpm-ostree status --json 2>/dev/null | grep -o '"origin" : "[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$CURRENT_REF" ]; then
        REMOTE=$(echo "$CURRENT_REF" | cut -d':' -f1)
        echo "✓ Detected from current deployment: $REMOTE"
    else
        # Default fallback
        REMOTE="fedora"
        echo "⚠ Could not detect, defaulting to: $REMOTE"
    fi
    KDE_TARGET="kde"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "REBASE OPERATION"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "This will:"
echo "  ✓ Download KDE Plasma 6 packages"
echo "  ✓ Replace GNOME 49 with KDE"
echo "  ✓ Preserve your user data"
echo "  ✓ Require a reboot"
echo ""
echo "Remote: $REMOTE"
echo "Target: fedora/41/x86_64/$KDE_TARGET"
echo ""
echo "Estimated time: 10-20 minutes depending on internet speed"
echo ""

read -p "Continue with rebase? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Starting rebase to KDE Plasma..."
echo ""

# Perform rebase with detected remote
sudo rpm-ostree rebase "${REMOTE}:fedora/41/x86_64/${KDE_TARGET}"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "REBASE COMPLETE!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "✓ KDE Plasma has been staged for next boot"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "YOU MUST REBOOT NOW:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  sudo systemctl reboot"
echo ""
echo "After reboot:"
echo "  1. You'll see KDE Plasma desktop"
echo "  2. Run: cd ~/Desktop/Zephyrus\\ OS"
echo "  3. Run: ./kde-setup/scripts/install-kde-zephyrus.sh"
echo ""
echo "See KDE_ROG_MIGRATION_FINAL.md for complete instructions."
echo ""

# Offer to reboot
read -p "Reboot now? (y/N): " reboot_now
if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    sudo systemctl reboot
else
    echo ""
    echo "Remember to reboot before the changes take effect!"
    echo ""
fi
