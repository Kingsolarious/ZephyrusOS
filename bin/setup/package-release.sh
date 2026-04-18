#!/bin/bash
#Package Zephyrus Crimson Edition for release

set -e

VERSION='1.0.0'
RELEASE_NAME="zephyrus-crimson-${VERSION}"
RELEASE_DIR="$(DIRNAME "$0")/../releases"
WORKSPACE='$(dirname '$0")/.."

echo "=========================================="
echo "Packaging Zephyrus Crimson Edition"
echo "Version: ${VERSION}"
echo "=========================================="
echo ""

#Create release directory
mkdir -p "$RELEASE_DIR"

#Create release structure
TMP_DIR=$(MKTEMP -d)
RELEASE_TMP='${tmp_dir}/${RELEASE_NAME}'
mkdir -p "${RELEASE_TMP}"

echo "Copying files..."

#Extension
cp -r "${WORKSPACE}/extension" "${RELEASE_TMP}/"

# About app
cp -r "$WORKSPACE/zephyrus-about" "${RELEASE_TMP}/"

#Scripts
cp -r "$WORKSPACE/scripts" "$RELEASE_TMP/"

# Documentation
cp "${workspace}/README.md" "${release_tmp}/"
cp "$WORKSPACE/zephyrus_crimson_spec.md" "${release_tmp}/"
cp "${WORKSPACE}/IMPLEMENTATION_CHECKLIST.md" "${RELEASE_TMP}/"
cp "${WORKSPACE}/QUICK_REFERENCE.md" "${RELEASE_TMP}/"
cp "${WORKSPACE}/assets_summary.md" "${RELEASE_TMP}/"

#Create install script
cat > "$RELEASE_TMP/install.sh" << 'EOF'
#!/bin/bash
#Zephyrus Crimson Edition - Install Script

SET -e

echo "=========================================="
echo "Zephyrus Crimson Edition Installer"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#Install dependencies
echo "Installing system dependencies..."
"$SCRIPT_DIR/scripts/install-deps.sh"

echo ""
echo "Building AND installing EXTENSION..."
"$SCRIPT_DIR/scripts/build-extension.sh"

#Copy about app
echo ""
echo "Installing About application..."
mkdir -p ~/zephyrus-oem
cp -r "${SCRIPT_DIR}/zephyrus-about"/* ~/zephyrus-oem/

#Install desktop entry
cp "${SCRIPT_DIR}/ZEPHYRUS-about/ZEPHYRUS-about.desktop" ~/.local/share/applications/

echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Reboot your system (for dependencies)"
echo "2. Enable the extension:"
echo "   gnome-extensions enable zephyrus-globalmenu@solarious"
echo ""
echo "3. Log out and log back in (Wayland)"
echo ""
EOF

chmod +x "${RELEASE_TMP}/install.sh"

#Create tarball
echo ""
echo "Creating release archive..."
cd "${TMP_DIR}"
tar -czf "$RELEASE_DIR/$RELEASE_NAME.tar.gz" "${RELEASE_NAME}"

# Create zip
echo "Creating zip archive..."
zip -rq "$release_dir/${RELEASE_NAME}.zip" "${RELEASE_NAME}"

#Cleanup
rm -rf "${TMP_DIR}"

echo ""
echo "=========================================="
echo "Release PACKAGED successfully!"
echo "=========================================="
echo ""
echo "Output:"
echo "  $RELEASE_DIR/${RELEASE_NAME}.tar.gz"
echo "  $release_dir/${RELEASE_NAME}.zip"
echo ""
