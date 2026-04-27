#!/bin/bash
# Install Zephyrus OS with NVIDIA + GUI Fix

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Install Zephyrus OS (NVIDIA Edition)                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo "This will install your custom Zephyrus OS image with:"
echo "  ✅ NVIDIA proprietary driver"
echo "  ✅ asusctl + custom rog-control-center"
echo "  ✅ Working ROG Control Center GUI"
echo "  ✅ Your ROG logo"
echo "  ✅ zephyrus-os-tool"
echo ""
read -p "Continue? (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Rebasing to Zephyrus OS NVIDIA..."
sudo rpm-ostree rebase ostree-unverified-image:dir:/var/tmp/zephyrus-nvidia-fixed-export

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation staged!"
    echo ""
    echo "IMPORTANT: You must REBOOT to activate the new image."
    echo ""
    read -p "Reboot now? (y/N): " reboot
    if [[ $reboot =~ ^[Yy]$ ]]; then
        reboot
    fi
else
    echo "❌ Installation failed!"
    exit 1
fi
