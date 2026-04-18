#!/bin/bash
# Rebase to Bazzite NVIDIA and restore customizations

echo ""


echo -e "This will:"
echo "  1. Rebase to ghcr.io/ublue-os/bazzite-nvidia:stable"
echo "  2. Keep your current customizations (asusctl, etc.)"
echo "  3. Your macOS theme and dock setup will remain"
echo ""

read -p "Continue? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo -e "Step 1: Rebase to Bazzite NVIDIA..."
echo ""

sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable

if [ $? -ne 0 ]; then
  echo ""
  echo -e "fail Rebase failed!"
  exit 1
fi

echo ""
echo -e "ok Rebase staged successfully!"
echo ""

# Create post-reboot setup script
cat > ~/Desktop/Zephyrus\ OS/post-nvidia-reboot.sh << 'POSTSCRIPT'
#!/bin/bash
# Post-reboot setup after NVIDIA rebase

echo ""

# Check if NVIDIA driver loaded
if [ -f /proc/driver/nvidia/version ]; then
  echo "ok NVIDIA driver loaded!"
  cat /proc/driver/nvidia/version | head -1
else
  echo "fail NVIDIA driver not loaded yet (may need another reboot)"
fi

echo ""
echo "Installing customizations..."

# Rebuild and install custom rog-control-center from in-repo source
ZEPHYRUS_DIR="$HOME/Desktop/Zephyrus OS"
ASUSCTL_DIR="$ZEPHYRUS_DIR/build/scripts/custom-asusctl"
if [ -d "$ASUSCTL_DIR" ]; then
  echo "Building custom-asusctl from Zephyrus OS repo..."
  cd "$ASUSCTL_DIR"
  make clean ||:
  make build 2>/dev/null && sudo make install 2>/dev/null && echo "ok Custom rog-control-center installed from repo"
else
  echo "warn Zephyrus OS repo not found at $ZEPHYRUS_DIR"
fi

# Check supergfxctl (deprecated — NVIDIA driver manages GPU power states)
if command -v supergfxctl &> /dev/null; then
  echo "warn supergfxctl is deprecated. NVIDIA driver native power management is preferred."
  echo "  Skipping supergfxd enable."
else
  echo "ℹ supergfxctl not installed (deprecated — not installing)"
fi

echo ""
echo ""
echo "External displays should now work!"
echo "Connect your monitor and run: kscreen-doctor --outputs"
POSTSCRIPT

chmod +x ~/Desktop/Zephyrus\ OS/post-nvidia-reboot.sh

echo -e "IMPORTANT: You must REBOOT to activate the new image"
echo ""
echo "After reboot, run:"
echo "  ~/Desktop/Zephyrus\\ OS/post-nvidia-reboot.sh"
echo ""

read -p "Reboot now? (y/N): " reboot
if [[ $reboot =~ ^[Yy]$ ]]; then
  reboot
fi
