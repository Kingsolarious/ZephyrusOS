#!/bin/bash
# Build and package the GNOME Shell extension

set -e

echo "=========================================="
echo "Building Zephyrus Global Menu Extension"
echo "=========================================="
echo ""

EXTENSION_DIR="$(dirname "$0")/../extension"
cd "$EXTENSION_DIR"

echo "Cleaning old builds..."
rm -f zephyrus-globalmenu@solarious.shell-extension.zip

# Check if gnome-extensions is available
if ! command -v gnome-extensions &> /dev/null; then
    echo "WARNING: gnome-extensions command not found"
    echo "Creating manual zip archive instead..."
    echo ""
    
    # Create zip manually
    zip -rq zephyrus-globalmenu@solarious.shell-extension.zip \
        metadata.json \
        extension.js \
        stylesheet.css \
        assets/
    
    echo "=========================================="
    echo "Extension packaged successfully!"
    echo "=========================================="
    echo ""
    echo "Output: zephyrus-globalmenu@solarious.shell-extension.zip"
    echo ""
    echo "To install on target system:"
    echo "  gnome-extensions install zephyrus-globalmenu@solarious.shell-extension.zip --force"
    echo "  gnome-extensions enable zephyrus-globalmenu@solarious"
    echo ""
    exit 0
fi

echo "Packing extension with gnome-extensions..."
gnome-extensions pack . \
    --force \
    --extra-source=assets/ \
    --extra-source=stylesheet.css

echo ""
echo "=========================================="
echo "Extension built successfully!"
echo "=========================================="
echo ""
echo "Output: zephyrus-globalmenu@solarious.shell-extension.zip"
echo ""
echo "To install:"
echo "  gnome-extensions install zephyrus-globalmenu@solarious.shell-extension.zip --force"
echo "  gnome-extensions enable zephyrus-globalmenu@solarious"
echo ""
