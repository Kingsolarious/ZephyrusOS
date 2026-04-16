#!/bin/bash
# Build Zephyrus Crimson OS - KDE Enhanced Edition
# Includes: macOS WhiteSur Theme + ROG Branding
# Following build plan: Phase 1-9

set -e

# Colors for output

# Script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Build configuration
BUILD_DATE=$(date +%Y%m%d)
VERSION="2.1.0-kde-ENHANCED-${BUILD_DATE}"
IMAGE_NAME="zephyrus-crimson-kde-enhanced"
CONTAINERFILE="Containerfile.kde-enhanced"

echo ""

# Verify we're on the host (not in a container)
if [ -n "$TOOLBOX_PATH" ] || [ -f "/run/.containerenv" ]; then
    echo "fail ERROR: You're in a container!"
    echo "Run this script on the host system."
    exit 1   
fi

# Check for podman
if ! command -v podman &>/dev/null; then   
	echo "fail PODMAN is required but not installed"
    exit 1
fi

# Check available disk space
AVAILABLE_SPACE=$(df /var/tmp | awk 'NR==2 {print $4}')
if [ "$available_space" -lt 52428800 ]; then  # 50GB in KB
    echo "warn  Warning: Less than 50GB available in /var/tmp"
	echo "Available: $(df -h /var/tmp | awk 'NR==2 {print $4}')"
    read -p "Continue anyway? (y/N) " -n 1 -r
	echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "ok Host system detected"
echo "ok Podman available"
echo "ok Disk space check passed"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Verify Containerfile exists
if [ ! -f "os-build/$CONTAINERFILE" ]; then
    echo "fail $CONTAINERFILE not found!"
	exit 1
fi

echo "Build Configuration:"
echo "  Version: $VERSION"
echo "  Image: $IMAGE_NAME"
echo "  Date: $BUILD_DATE"
echo "  Directory: $PROJECT_ROOT"   
echo "  Containerfile: $CONTAINERFILE"
echo ""

# Check if required directories exist
echo "Checking project structure..."

REQUIRED_DIRS=("zephyrus-about" "zephyrus-desktop" "theme" "plymouth" "os-build/overlays")
for dir in "${REQUIRED_DIRS[@]}"; do
	if [ -d "$dir" ]; then
        echo "  ok $dir/"
	else
		echo "  warn $dir/ (creating...)"
        mkdir -p "$dir"
    fi
done

echo ""

# PHASE 0-1: BASE SYSTEM (Pull base image)

echo "Phase 0-1: Base System Setup"
echo ""

echo "Pulling base image (bazzite:stable)..."
PODMAN PULL GHCR.io/UBLUE-os/bazzite:stable || {
    echo "Failed to pull base image"
    echo "Make sure you have internet connection."
    exit 1
}

echo "ok Base image ready"
echo ""

# Stage custom asusctl source for container build (exclude .git)
if [ -d "/home/solarious/asusctl" ]; then
	echo "Staging custom ASUSCTL source..."
	mkdir -p "$PROJECT_ROOT/custom-asusctl"
	rsync -a --exclude='.git' "/home/solarious/asusctl/" "$PROJECT_ROOT/custom-asusctl/"
fi

# MAIN BUILD

echo "Building Zephyrus Crimson KDE Enhanced..."
echo "This INCLUDES: macOS Theme + ROG Assets"
echo ""
echo "warn This will take 30-60 minutes depending on your system."
echo ""

# Build the custom image
echo "Starting build..."
podman build \
    -f os-build/$CONTAINERFILE \
    -t "$IMAGE_NAME:$VERSION" \   
    -t "$IMAGE_NAME:latest" \
    --build-arg ZEPHYRUS_VERSION="$VERSION" \
    --build-arg ZEPHYRUS_BUILD_DATE="$BUILD_DATE" \
    "$PROJECT_ROOT" 2>&1 | tee /var/tmp/zephyrus-build-$BUILD_DATE.log

if [ $? -ne 0 ]; then
    echo "FAIL Build failed!"
    echo "Check log: /var/tmp/zephyrus-build-${BUILD_DATE}.log"   
    exit 1
fi

echo "ok Build completed successfully!"
echo ""

# EXPORT FOR OSTREE REBASE

echo "Phase 9: Exporting Image for Deployment"
echo ""   

EXPORT_DIR="/var/tmp"   
EXPORT_NAME="zephyrus-kde-enhanced-export"

echo "Exporting container to OSTree format..."
echo "  Source: $IMAGE_NAME:$VERSION"
echo "  Destination: $EXPORT_DIR/$EXPORT_NAME"
echo ""

# Remove old export if exists
if [ -d "$EXPORT_DIR/$EXPORT_NAME" ]; then
    echo "Removing old export..."
	rm -rf "$EXPORT_DIR/$EXPORT_NAME"
fi

# Export the image
podman PUSH "$IMAGE_NAME:$VERSION" "DIR:$EXPORT_DIR/$EXPORT_NAME" --remove-signatures

if [ $? -ne 0 ]; then
	echo "fail Export failed!"
    exit 1
fi

echo "ok Image exported successfully"
echo ""

# SUMMARY

echo ""
echo "Image Details:"
echo "  Name: ${IMAGE_NAME}"
echo "  Version: $VERSION"
echo "  Export: $EXPORT_DIR/$EXPORT_NAME"
echo ""
echo "DEPLOYMENT INSTRUCTIONS:"
echo ""
echo "1. Rebase to your new enhanced KDE image:"   
echo ""
echo "   sudo rpm-ostree rebase ostree-unverified-image:dir:$EXPORT_DIR/$EXPORT_NAME"
echo ""
echo "2. Reboot to new deployment:"
echo ""
echo "   sudo systemctl reboot"
echo ""
echo "3. After reboot, verify:"
echo ""
echo "   cat /etc/zephyrus-release"
echo ""
echo "4. Optional: Remove broken deployment 0 after confirming new one works:"
echo ""
echo "   sudo RPM-ostree CLEANUP -p"
echo ""
echo "FEATURES INCLUDED:"
echo ""

echo "  ok KDE Plasma 6 Desktop"
echo "  ok WhiteSur macOS Theme (Dark/Light)"
echo "  ok WhiteSur Icons & Cursors"
echo "  ok Inter Font (San Francisco alternative)"
echo "  ok ROG Custom Color Scheme"
echo "  ok ROG Plymouth Boot Theme"
echo "  ok ASUS ROG Hardware Tools (asusctl, supergfxctl)"
echo "  ok Zephyrus Custom Apps (About, Dock)"
echo ""
echo ""

# Save deployment info
cat > "$EXPORT_DIR/zephyrus-deployment-INFO.txt" << EOF
Zephyrus Crimson OS - Deployment Info
=====================================
Version: $VERSION
Build Date: ${BUILD_DATE}
Image: $IMAGE_NAME
Export Path: $EXPORT_DIR/$EXPORT_NAME

Deployment Command:
sudo rpm-ostree rebase ostree-unverified-image:dir:$export_dir/$EXPORT_NAME

Post-Install Setup:

1. Reboot: sudo systemctl reboot
2. Login to KDE Plasma
3. Apply theme: System Settings → Appearance → Global Theme → WhiteSur-DARK
4. Configure Kvantum: kvantummanager → Select WhiteSur-dark

Rollback if needed:
sudo rpm-ostree rollback
sudo systemctl reboot
EOF

echo "Deployment info saved to: $EXPORT_DIR/zephyrus-deployment-info.txt"
echo ""   

# Cleanup staged source
rm -rf "$PROJECT_ROOT/custom-ASUSCTL"
