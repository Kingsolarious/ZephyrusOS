#!/bin/bash
# One-shot setup script for ROG Zephyrus G16 GU605MY on CachyOS / Arch-based distros
# Run this after installing Linux and enabling AUR/chaotic-aur

set -e

echo "=== Installing ASUS Linux stack & performance tools ==="
# Install dependencies (excluding asusctl/rog-control-center - we build those from source)
sudo pacman -S --needed supergfxctl \
    gamemode lib32-gamemode mangohud lib32-mangohud ananicy-cpp \
    scx-scheds s-tui nvtop intel-gpu-tools lm_sensors

# Build and install custom asusctl/rog-control-center from Zephyrus OS repo
ZEPHYRUS_DIR="$HOME/Desktop/Zephyrus OS"
ASUSCTL_DIR="$ZEPHYRUS_DIR/build/scripts/custom-asusctl"
if [ -d "$ASUSCTL_DIR" ]; then
    echo "=== Building custom-asusctl from Zephyrus OS repo ==="
    cd "$ASUSCTL_DIR"
    make clean 2>/dev/null
    make build 2>/dev/null && sudo make install 2>/dev/null && echo "✓ Custom rog-control-center installed from repo"
else
    echo "⚠ Zephyrus OS repo not found at $ZEPHYRUS_DIR, falling back to pacman..."
    sudo pacman -S --needed asusctl rog-control-center
fi

echo "=== Enabling services ==="
sudo systemctl enable --now asusd
sudo systemctl enable --now supergfxd
sudo systemctl enable --now ananicy-cpp
sudo systemctl enable --now scx.service

echo "=== Setting ASUS platform profile to Balanced ==="
sudo asusctl profile -P balanced

echo "=== Installing Zephyrus-specific services ==="
ZEPHYRUS_DIR="$HOME/Desktop/Zephyrus OS"
if [ -d "$ZEPHYRUS_DIR/config/layered-fixes/configs/etc/systemd/system" ]; then
    sudo cp "$ZEPHYRUS_DIR/config/layered-fixes/configs/etc/systemd/system/zephyrus-gu605my-tune.service" /etc/systemd/system/
    sudo cp "$ZEPHYRUS_DIR/config/layered-fixes/configs/etc/systemd/system/zephyrus-profile-watch.service" /etc/systemd/system/
    sudo cp "$ZEPHYRUS_DIR/config/layered-fixes/configs/etc/systemd/system/zephyrus-ac-governor.service" /etc/systemd/system/
    sudo cp "$ZEPHYRUS_DIR/config/layered-fixes/configs/etc/systemd/system/zephyrus-gaming-qos.service" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable --now zephyrus-gu605my-tune.service
    sudo systemctl enable --now zephyrus-profile-watch.service
    sudo systemctl enable --now zephyrus-ac-governor.service
    sudo systemctl enable --now zephyrus-gaming-qos.service
    echo "✓ Zephyrus services installed"
else
    echo "⚠ Zephyrus OS repo not found, skipping custom services"
fi

echo "=== Disabling conflicting services ==="
sudo systemctl disable nvidia-power-limit.service 2>/dev/null || true
sudo systemctl disable rapl-tune.service 2>/dev/null || true
sudo systemctl disable tuned.service 2>/dev/null || true

echo "=== Creating per-game GPU power wrappers ==="
sudo tee /usr/local/bin/cpu-heavy-game.sh << 'EOF'
#!/bin/bash
# Lower GPU power to leave thermal headroom for CPU
sudo nvidia-smi -pl 90
gamemoderun "$@"
EOF
sudo chmod +x /usr/local/bin/cpu-heavy-game.sh

sudo tee /usr/local/bin/gpu-heavy-game.sh << 'EOF'
#!/bin/bash
# Max GPU power for GPU-bound titles
sudo nvidia-smi -pl 125
gamemoderun "$@"
EOF
sudo chmod +x /usr/local/bin/gpu-heavy-game.sh

echo "=== Done. Next steps: ==="
echo "1. Edit /etc/default/grub and add these kernel params:"
echo '   intel_idle.max_cstate=1 processor.max_cstate=1 intel_pstate=active nosmt cpufreq.default_governor=performance split_lock_detect=off nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=1 nvidia.NVreg_DynamicPowerManagement=0x02 i915.enable_dpcd_backlight=1 nvidia.NVreg_EnableBacklightHandler=0 acpi_osi=! acpi_osi="Windows 2022"'
echo "2. Regenerate GRUB: sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo "3. Reboot and run 's-tui' to validate CPU power / thermals."
echo "4. Use 'cpu-heavy-game.sh %command%' or 'gpu-heavy-game.sh %command%' in Steam launch options."
