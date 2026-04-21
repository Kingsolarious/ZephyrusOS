#!/bin/bash
# Post-reboot setup after NVIDIA rebase

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

# Re-add your custom rog-control-center
if [ -d "$HOME/Desktop/asusctl-gu605my-fork-20260303-173948" ]; then
    cd "$HOME/Desktop/asusctl-gu605my-fork-20260303-173948"
    ./INSTALL.sh 2>/dev/null && echo "✓ Custom rog-control-center installed"
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
