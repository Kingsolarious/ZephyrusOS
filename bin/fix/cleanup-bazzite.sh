#!/bin/bash
# Bazzite/GNOME Cleanup Script
# Run this to remove abandoned files after KDE migration

set -e

cd "~/Desktop/Zephyrus OS" 2>/dev/null || cd "/home/solarious/Desktop/Zephyrus OS"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  BAZZITE/GNOME CLEANUP                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Count files before
echo "Counting files..."
BEFORE=$(find . -type f | wc -l)

# Remove GNOME extensions
echo "Removing GNOME extensions..."
rm -rf extension/ 2>/dev/null || true
rm -rf rog-extension/ 2>/dev/null || true
rm -rf rog-gdm/ 2>/dev/null || true
rm -rf rog-plymouth/ 2>/dev/null || true
rm -rf rog-theme/ 2>/dev/null || true

echo "Removing GNOME-specific scripts..."
rm -f simple-rognome-fix.sh 2>/dev/null || true
rm -f fix-gnome49-toggle.sh 2>/dev/null || true
rm -f gnome49-solutions.sh 2>/dev/null || true
rm -f EMERGENCY_DISABLE_EXTENSIONS.sh 2>/dev/null || true
rm -f KEEP_GNOME_FIX_DOCK.sh 2>/dev/null || true
rm -f rog-gnome-fix.sh 2>/dev/null || true
rm -f setup-arcmenu-rog.sh 2>/dev/null || true
rm -f setup-centered-rog.sh 2>/dev/null || true
rm -f setup-macos-rog.sh 2>/dev/null || true
rm -f setup-rog-zephyros.sh 2>/dev/null || true
rm -f complete-macos-rog-setup.sh 2>/dev/null || true
rm -f setup-complete-macos-rog.sh 2>/dev/null || true

echo "Removing old fix scripts..."
rm -f fix-on-host.sh 2>/dev/null || true
rm -f fix-after-cleanup.sh 2>/dev/null || true
rm -f fix-plymouth.sh 2>/dev/null || true
rm -f fix-extension-now.sh 2>/dev/null || true
rm -f fix-logo-and-activities.sh 2>/dev/null || true
rm -f fix-rog-icon.sh 2>/dev/null || true
rm -f fix-all-host.sh 2>/dev/null || true
rm -f fix-terminal-host.sh 2>/dev/null || true
rm -f fix-file-manager.sh 2>/dev/null || true
rm -f fix-file-manager-and-activities.sh 2>/dev/null || true
rm -f fix-terminal-icon.sh 2>/dev/null || true
rm -f fix-desktop-menu.sh 2>/dev/null || true
rm -f fix-desktop-icons.sh 2>/dev/null || true
rm -f fix-desktop-mode.sh 2>/dev/null || true

echo "Removing outdated migration docs..."
rm -f KDE_MIGRATION_STATUS.md 2>/dev/null || true
rm -f KDE_MIGRATION_COMPLETE.md 2>/dev/null || true
rm -f KDE_ROG_MIGRATION_FINAL.md 2>/dev/null || true
rm -f QUICKSTART_KDE.md 2>/dev/null || true
rm -f MIGRATE_TO_KDE_NOW.md 2>/dev/null || true
rm -f KDE_MIGRATION.md 2>/dev/null || true
rm -f BUILD_KDE_GUIDE.md 2>/dev/null || true
rm -f START_HERE_FINAL.md 2>/dev/null || true
rm -f START_HERE.md 2>/dev/null || true

echo "Removing old install scripts..."
rm -f INSTALL_NOW.md 2>/dev/null || true
rm -f install-complete.sh 2>/dev/null || true
rm -f install-fixed.sh 2>/dev/null || true
rm -f install-zephyrus-os.sh 2>/dev/null || true

echo "Removing old cleanup scripts..."
rm -f cleanup-project.sh 2>/dev/null || true
rm -f cleanup-extensions.sh 2>/dev/null || true
rm -f cleanup-desktop.sh 2>/dev/null || true

# Count files after
AFTER=$(find . -type f | wc -l)
REMOVED=$((BEFORE - AFTER))

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  CLEANUP COMPLETE!                                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Files removed: $REMOVED"
echo "Files remaining: $AFTER"
echo ""
echo "Your Zephyrus OS is now clean! 🎉"
echo ""
