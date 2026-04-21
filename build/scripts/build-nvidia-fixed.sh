#!/bin/bash
# Quick build script for Zephyrus OS with NVIDIA + GUI fix

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Build Zephyrus OS (NVIDIA + GUI Fix)                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

echo "Step 1: Checking icons..."
if [ ! -f "icons/rog-control-center.svg" ]; then
    echo "❌ Icon not found! Copy your ROG logo to icons/rog-control-center.svg"
    exit 1
fi
echo "  ✅ Icons ready"

echo ""
echo "Step 2: Building image (this takes 10-30 minutes)..."
podman build -f Containerfile.nvidia-fixed -t zephyrus-os-nvidia:latest . 2>&1 | tee /tmp/build.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "❌ Build failed! Check /tmp/build.log"
    exit 1
fi

echo ""
echo "Step 3: Exporting image..."
mkdir -p /var/tmp/zephyrus-nvidia-fixed-export
podman push zephyrus-os-nvidia:latest dir:/var/tmp/zephyrus-nvidia-fixed-export

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  BUILD COMPLETE!                                         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "To install, run:"
echo "  sudo rpm-ostree rebase ostree-unverified-image:dir:/var/tmp/zephyrus-nvidia-fixed-export"
echo ""
echo "Then: reboot"
