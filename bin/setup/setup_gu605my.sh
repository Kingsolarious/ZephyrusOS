#!/bin/bash
# One-shot setup script for ROG Zephyrus G16 GU605MY on CachyOS / Arch-based distros
# Run this after installing Linux and enabling AUR/chaotic-aur

set -e

echo "=== Installing ASUS Linux stack & performance tools ==="
sudo pacman -S --needed asusctl supergfxctl rog-control-center \
    gamemode lib32-gamemode mangohud lib32-mangohud ananicy-cpp \
    scx-scheds s-tui nvtop intel-gpu-tools lm_sensors

echo "=== Enabling services ==="
sudo systemctl enable --now asusd
sudo systemctl enable --now supergfxd
sudo systemctl enable --now ananicy-cpp
sudo systemctl enable --now scx.service

echo "=== Setting ASUS platform profile to Performance ==="
sudo asusctl profile -P performance

echo "=== Setting max fan curves ==="
sudo asusctl fan-curve -m performance -D 30c:100,40c:100,50c:100,60c:100,70c:100,80c:100,90c:100,100c:100

echo "=== Creating NVIDIA power limit service (115W default) ==="
sudo tee /etc/systemd/system/nvidia-power-limit.service << 'EOF'
[Unit]
Description=NVIDIA GPU Power Limit
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pl 115
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now nvidia-power-limit.service

echo "=== Creating RAPL tuning service (CPU 75W/115W) ==="
sudo tee /etc/systemd/system/rapl-tune.service << 'EOF'
[Unit]
Description=Intel RAPL Tuning for Gaming
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo 75000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw && echo 115000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw && echo 28000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_time_window_us'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now rapl-tune.service

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
