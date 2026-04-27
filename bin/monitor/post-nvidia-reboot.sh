#!/bin/bash
# Post-reboot setup after NVIDIA rebase
# DEPRECATION NOTICE: supergfxctl references in this script are deprecated.
# NVIDIA driver native power management is preferred.

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Post-Reboot NVIDIA Setup                                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if NVIDIA driver loaded
if [ -f /proc/driver/nvidia/version ]; then
    echo "✓ NVIDIA driver loaded!"
    cat /proc/driver/nvidia/version | head -1
else
    echo "✗ NVIDIA driver not loaded yet (may need another reboot)"
fi

echo ""
echo "Installing customizations..."

# Rebuild and install custom rog-control-center from in-repo source
ZEPHYRUS_DIR="$HOME/Desktop/Zephyrus OS"
ASUSCTL_DIR="$ZEPHYRUS_DIR/build/scripts/custom-asusctl"
if [ -d "$ASUSCTL_DIR" ]; then
    echo "Building custom-asusctl from Zephyrus OS repo..."
    cd "$ASUSCTL_DIR"
    make build 2>/dev/null && sudo make install 2>/dev/null && echo "✓ Custom rog-control-center installed from repo"
else
    echo "⚠ Zephyrus OS repo not found at $ZEPHYRUS_DIR"
fi

# Check supergfxctl
if command -v supergfxctl &> /dev/null; then
    echo ""
    echo "✓ supergfxctl available"
    sudo systemctl enable --now supergfxd 2>/dev/null
    sleep 2
    supergfxctl --mode hybrid 2>/dev/null
    echo "✓ GPU mode set to hybrid"
    echo ""
    echo "Current GPU status:"
    supergfxctl --status
else
    echo "Installing supergfxctl..."
    sudo rpm-ostree install supergfxctl
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  DONE!                                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "External displays should now work!"
echo "Connect your monitor and run: kscreen-doctor --outputs"
