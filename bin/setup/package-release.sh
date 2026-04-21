#!/bin/bash
# Package Zephyrus Crimson Edition for release

set -e

VERSION="1.0.0"
RELEASE_NAME="zephyrus-crimson-${VERSION}"
RELEASE_DIR="$(dirname "$0")/../releases"
WORKSPACE="$(dirname "$0")/.."

echo "=========================================="
echo "Packaging Zephyrus Crimson Edition"
echo "Version: ${VERSION}"
echo "=========================================="
echo ""

# Create release directory
mkdir -p "${RELEASE_DIR}"

# Create release structure
TMP_DIR=$(mktemp -d)
RELEASE_TMP="${TMP_DIR}/${RELEASE_NAME}"
mkdir -p "${RELEASE_TMP}"

echo "Copying files..."

# Extension
cp -r "${WORKSPACE}/extension" "${RELEASE_TMP}/"

# About app
cp -r "${WORKSPACE}/zephyrus-about" "${RELEASE_TMP}/"

# Scripts
cp -r "${WORKSPACE}/scripts" "${RELEASE_TMP}/"

# Documentation
cp "${WORKSPACE}/README.md" "${RELEASE_TMP}/"
cp "${WORKSPACE}/ZEPHYRUS_CRIMSON_SPEC.md" "${RELEASE_TMP}/"
cp "${WORKSPACE}/IMPLEMENTATION_CHECKLIST.md" "${RELEASE_TMP}/"
cp "${WORKSPACE}/QUICK_REFERENCE.md" "${RELEASE_TMP}/"
cp "${WORKSPACE}/ASSETS_SUMMARY.md" "${RELEASE_TMP}/"

# Create install script
cat > "${RELEASE_TMP}/install.sh" << 'EOF'
#!/bin/bash
# Zephyrus Crimson Edition - Install Script

set -e

echo "=========================================="
echo "Zephyrus Crimson Edition Installer"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install dependencies
echo "Installing system dependencies..."
"${SCRIPT_DIR}/scripts/install-deps.sh"

echo ""
echo "Building and installing extension..."
"${SCRIPT_DIR}/scripts/build-extension.sh"

# Copy about app
echo ""
echo "Installing About application..."
mkdir -p ~/zephyrus-oem
cp -r "${SCRIPT_DIR}/zephyrus-about"/* ~/zephyrus-oem/

# Install desktop entry
cp "${SCRIPT_DIR}/zephyrus-about/zephyrus-about.desktop" ~/.local/share/applications/

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

# Create tarball
echo ""
echo "Creating release archive..."
cd "${TMP_DIR}"
tar -czf "${RELEASE_DIR}/${RELEASE_NAME}.tar.gz" "${RELEASE_NAME}"

# Create zip
echo "Creating zip archive..."
zip -rq "${RELEASE_DIR}/${RELEASE_NAME}.zip" "${RELEASE_NAME}"

# Cleanup
rm -rf "${TMP_DIR}"

echo ""
echo "=========================================="
echo "Release packaged successfully!"
echo "=========================================="
echo ""
echo "Output:"
echo "  ${RELEASE_DIR}/${RELEASE_NAME}.tar.gz"
echo "  ${RELEASE_DIR}/${RELEASE_NAME}.zip"
echo ""
