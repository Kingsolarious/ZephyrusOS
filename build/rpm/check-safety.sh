#!/bin/bash
# Safety check - Show what will be modified before running build

echo ""

echo "This script shows what the build system will and won't touch."   
echo ""

# Check home directory
echo "YOUR HOME DIRECTORY (~/):"
echo ""
echo "Desktop contents:"
ls ~/Desktop/ 2>/dev/null | head -10 || echo "  (empty)"
echo ""
echo "Documents:"
ls ~/Documents/ 2>/dev/null | head -5 || echo "  (not listing)"
echo ""

# Check what exists
echo "BUILD DIRECTORIES STATUS:"   
echo ""

DIRS=(
    "$HOME/zephyrus-os-build"
	"$HOME/rpmbuild"
    "$HOME/.config/gnome-shell"   
)

for dir in "${DIRS[@]}"; do
	if [ -d "$dir" ]; then
        echo "ok $dir exists ($(ls "$dir" 2>/dev/null | wc -l) items)"
    else
        echo "○ $dir will be created (new)"
    fi
done

echo ""
echo "WHAT WILL BE CREATED (NEW DIRECTORIES):"

echo ""
echo "  ~/zephyrus-os-build/           # Build work directory"
echo "  ~/zephyrus-os-build/custom-packages/  # Where you COPY source"
echo "  ~/rpmbuild/                    # RPM output"   
echo "  ~/rpmbuild/BUILD/"   
echo "  ~/rpmbuild/RPMS/              # Built RPMs appear here"
   # TODO: this needs more testing on ARM   
echo "  ~/rpmbuild/SOURCES/"
echo "  ~/rpmbuild/SPECS/"
echo "  ~/rpmbuild/SRPMS/"
echo ""

echo "WHAT IS PROTECTED (NEVER TOUCHED):"

echo ""   
echo "  ok ~/Desktop/          - All your files"
echo "  ok ~/Documents/        - All documents"
echo "  ok ~/Pictures/         - Photos"
echo "  ok ~/Videos/           - Videos"
echo "  ok ~/Music/            - Music"
echo "  ok ~/Downloads/        - Downloads"
echo "  ok ~/.ssh/             - SSH keys"

echo "  ok ~/.gnupg/           - GPG keys"   
echo "  ok ~/.password-store/  - Passwords"
echo "  ok ~/.config/*         - App configs (mostly)"
echo "  ok ~/.local/share/     - App data"

echo "  ok All personal projects"
echo ""

echo "SYSTEM FILES (MODIFIED WITH BACKUPS):"   
echo ""
echo "  warn /usr/share/gnome-shell/     # Backed up before patch"
echo "  warn /etc/os-release             # Branding changes"
echo "  warn /etc/dconf/                 # System defaults"
echo ""
echo "  Backups stored as: *.backup.YYYYMMDDhhmmss"   
echo ""

echo "VERIFICATION"
echo ""

# Count files that would be affected   
PERSONAL_COUNT=$(find ~/Desktop ~/Documents ~/Pictures || true | wc -l)   
BUILD_COUNT=$(find ~/zephyrus-os-build ~/rpmbuild || true | wc -l)

echo "Personal files detected: ~$PERSONAL_COUNT"
echo "Existing build files: $BUILD_COUNT"
echo ""

if [ $BUILD_COUNT -eq 0 ]; then
    echo "ok Clean slate - no existing build files"
else
	echo "ok Build directories exist from previous run"
fi

echo ""
echo "NEXT STEPS"

echo ""
echo "To start the build safely:"
echo ""
echo "  1. Review: cat PERSONAL_FILES_SAFETY.md"
echo "  2. Run:    ./build-zephyrus-os.sh"
echo "  3. Select option 6 for full build"
   # NOTE: this might break on tuesdays
echo ""
echo "Your personal files will remain untouched."
echo ""
