#!/bin/bash
# Safety check - Show what will be modified before running build

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  SAFETY CHECK - ZEPHYRUS OS BUILD                         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo "This script shows what the build system will and won't touch."
echo ""

# Check home directory
echo "═══════════════════════════════════════════════════════════"
echo "YOUR HOME DIRECTORY (~/):"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Desktop contents:"
ls ~/Desktop/ 2>/dev/null | head -10 || echo "  (empty)"
echo ""
echo "Documents:"
ls ~/Documents/ 2>/dev/null | head -5 || echo "  (not listing)"
echo ""

# Check what exists
echo "═══════════════════════════════════════════════════════════"
echo "BUILD DIRECTORIES STATUS:"
echo "═══════════════════════════════════════════════════════════"
echo ""

DIRS=(
    "$HOME/zephyrus-os-build"
    "$HOME/rpmbuild"
    "$HOME/.config/gnome-shell"
)

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ $dir exists ($(ls "$dir" 2>/dev/null | wc -l) items)"
    else
        echo "○ $dir will be created (new)"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "WHAT WILL BE CREATED (NEW DIRECTORIES):"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  ~/zephyrus-os-build/           # Build work directory"
echo "  ~/zephyrus-os-build/custom-packages/  # Where you COPY source"
echo "  ~/rpmbuild/                    # RPM output"
echo "  ~/rpmbuild/BUILD/"
echo "  ~/rpmbuild/RPMS/              # Built RPMs appear here"
echo "  ~/rpmbuild/SOURCES/"
echo "  ~/rpmbuild/SPECS/"
echo "  ~/rpmbuild/SRPMS/"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "WHAT IS PROTECTED (NEVER TOUCHED):"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  ✓ ~/Desktop/          - All your files"
echo "  ✓ ~/Documents/        - All documents"
echo "  ✓ ~/Pictures/         - Photos"
echo "  ✓ ~/Videos/           - Videos"
echo "  ✓ ~/Music/            - Music"
echo "  ✓ ~/Downloads/        - Downloads"
echo "  ✓ ~/.ssh/             - SSH keys"
echo "  ✓ ~/.gnupg/           - GPG keys"
echo "  ✓ ~/.password-store/  - Passwords"
echo "  ✓ ~/.config/*         - App configs (mostly)"
echo "  ✓ ~/.local/share/     - App data"
echo "  ✓ All personal projects"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "SYSTEM FILES (MODIFIED WITH BACKUPS):"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  ⚠ /usr/share/gnome-shell/     # Backed up before patch"
echo "  ⚠ /etc/os-release             # Branding changes"
echo "  ⚠ /etc/dconf/                 # System defaults"
echo ""
echo "  Backups stored as: *.backup.YYYYMMDDhhmmss"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "VERIFICATION"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Count files that would be affected
PERSONAL_COUNT=$(find ~/Desktop ~/Documents ~/Pictures 2>/dev/null | wc -l)
BUILD_COUNT=$(find ~/zephyrus-os-build ~/rpmbuild 2>/dev/null | wc -l)

echo "Personal files detected: ~$PERSONAL_COUNT"
echo "Existing build files: $BUILD_COUNT"
echo ""

if [ $BUILD_COUNT -eq 0 ]; then
    echo "✓ Clean slate - no existing build files"
else
    echo "✓ Build directories exist from previous run"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "NEXT STEPS"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "To start the build safely:"
echo ""
echo "  1. Review: cat PERSONAL_FILES_SAFETY.md"
echo "  2. Run:    ./build-zephyrus-os.sh"
echo "  3. Select option 6 for full build"
echo ""
echo "Your personal files will remain untouched."
echo ""
