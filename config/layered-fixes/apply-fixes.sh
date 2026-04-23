#!/bin/bash
# Zephyrus GU605MY Layered Fixes
# Applies hardware fixes ON TOP of your existing Bazzite system.
# Safe to run multiple times. Preserves all existing customizations.
#
# Run with: sudo ./apply-fixes.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"

if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (sudo)"
    exit 1
fi

echo "========================================"
echo "  Zephyrus GU605MY Layered Fixes"
echo "========================================"
echo

# -----------------------------------------------------------------------------
# 1. KERNEL CMDLINE FIXES
# -----------------------------------------------------------------------------
echo "[1/10] Fixing kernel cmdline..."
bash "$SCRIPT_DIR/scripts/01-fix-kernel-cmdline.sh"
echo

# -----------------------------------------------------------------------------
# 2. SYSTEMD SERVICES
# -----------------------------------------------------------------------------
echo "[2/10] Updating systemd services..."

# Fix fan curve service (remove 100% fan override)
cp "$CONFIGS_DIR/etc/systemd/system/zephyrus-gu605my-tune.service" /etc/systemd/system/

# OEM profile watcher (auto-syncs GPU/RAPL/EPP on profile change)
cp "$CONFIGS_DIR/etc/systemd/system/zephyrus-profile-watch.service" /etc/systemd/system/

# Gaming QoS service
cp "$CONFIGS_DIR/etc/systemd/system/zephyrus-gaming-qos.service" /etc/systemd/system/

# AC governor (switches CPU governor + EPP on AC/battery events)
cp "$CONFIGS_DIR/etc/systemd/system/zephyrus-ac-governor.service" /etc/systemd/system/

# Sleep/resume hook
mkdir -p /etc/systemd/system-sleep
cp "$CONFIGS_DIR/etc/systemd/system-sleep/zephyrus-gu605my-sleep" /etc/systemd/system-sleep/
chmod +x /etc/systemd/system-sleep/zephyrus-gu605my-sleep

systemctl daemon-reload

# Enable new services
systemctl enable zephyrus-gu605my-tune.service 2>/dev/null || true
systemctl enable zephyrus-profile-watch.service 2>/dev/null || true
systemctl enable zephyrus-gaming-qos.service 2>/dev/null || true
systemctl enable zephyrus-ac-governor.service 2>/dev/null || true

# Disable conflicting services (tuned overrides our profile sync)
systemctl disable tuned.service 2>/dev/null || true
systemctl disable nvidia-power-limit.service 2>/dev/null || true
systemctl disable rapl-tune.service 2>/dev/null || true
systemctl disable zephyrus-gpu-profile-sync.service 2>/dev/null || true

echo "✅ Services updated"
echo

# -----------------------------------------------------------------------------
# 3. LOCAL BIN SCRIPTS
# -----------------------------------------------------------------------------
echo "[3/10] Installing local scripts..."
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-profile-sync" /usr/local/bin/
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-profile-watch" /usr/local/bin/
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-gaming-qos" /usr/local/bin/
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-ac-governor.sh" /usr/local/bin/
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-gamescope-launcher" /usr/local/bin/
chmod +x /usr/local/bin/zephyrus-profile-sync
chmod +x /usr/local/bin/zephyrus-profile-watch
chmod +x /usr/local/bin/zephyrus-gaming-qos
chmod +x /usr/local/bin/zephyrus-ac-governor.sh
chmod +x /usr/local/bin/zephyrus-gamescope-launcher
echo "✅ Scripts installed"
echo

# -----------------------------------------------------------------------------
# 4. MODPROBE CONFIGS
# -----------------------------------------------------------------------------
echo "[4/10] Updating modprobe configs..."
cp "$CONFIGS_DIR/etc/modprobe.d/zephyrus-gu605my-audio.conf" /etc/modprobe.d/
echo "✅ Modprobe configs updated"
echo

# -----------------------------------------------------------------------------
# 5. UDEV RULES
# -----------------------------------------------------------------------------
echo "[5/10] Updating udev rules..."
cp "$CONFIGS_DIR/etc/udev/rules.d/50-zephyrus-gu605my-usb.rules" /etc/udev/rules.d/
cp "$CONFIGS_DIR/etc/udev/rules.d/50-bluetooth-ax211.rules" /etc/udev/rules.d/
cp "$CONFIGS_DIR/etc/udev/rules.d/99-audio-pci-pm.rules" /etc/udev/rules.d/
udevadm control --reload-rules 2>/dev/null || true
udevadm trigger 2>/dev/null || true

# Update hwdb for keyboard scancodes
mkdir -p /etc/udev/hwdb.d
if [ -f "$CONFIGS_DIR/etc/udev/hwdb.d/90-asus-fnkeys.hwdb" ]; then
    cp "$CONFIGS_DIR/etc/udev/hwdb.d/90-asus-fnkeys.hwdb" /etc/udev/hwdb.d/
    systemd-hwdb update 2>/dev/null || true
fi
echo "✅ Udev rules updated"
echo

# -----------------------------------------------------------------------------
# 6. SYSCTL PERFORMANCE TUNING
# -----------------------------------------------------------------------------
echo "[6/10] Applying gaming sysctl tuning..."
if [ -f "$CONFIGS_DIR/etc/sysctl.d/99-gaming-performance.conf" ]; then
    cp "$CONFIGS_DIR/etc/sysctl.d/99-gaming-performance.conf" /etc/sysctl.d/
    sysctl --system 2>/dev/null | grep -E "gaming|dirty|tcp_fastopen" || true
fi
echo "✅ Sysctl tuning applied"
echo

# -----------------------------------------------------------------------------
# 7. GAMEMODE CONFIG
# -----------------------------------------------------------------------------
echo "[7/10] Installing gamemode config..."
if [ -f "$CONFIGS_DIR/etc/gamemode.ini" ]; then
    cp "$CONFIGS_DIR/etc/gamemode.ini" /etc/gamemode.ini
    echo "✅ Gamemode config installed"
else
    echo "⚠️  gamemode.ini not found"
fi
echo

# -----------------------------------------------------------------------------
# 8. PIPEWIRE LOW-LATENCY
# -----------------------------------------------------------------------------
echo "[8/10] Installing PipeWire low-latency config..."
if [ -f "$CONFIGS_DIR/usr/share/pipewire/pipewire.conf.d/10-zephyrus-lowlatency.conf" ]; then
    mkdir -p /usr/share/pipewire/pipewire.conf.d
    cp "$CONFIGS_DIR/usr/share/pipewire/pipewire.conf.d/10-zephyrus-lowlatency.conf" /usr/share/pipewire/pipewire.conf.d/
    echo "✅ PipeWire low-latency config installed"
    echo "   Restart PipeWire to apply: systemctl --user restart pipewire"
else
    echo "⚠️  PipeWire config not found"
fi
echo

# -----------------------------------------------------------------------------
# 9. GPU POWER LIMIT PERSISTENCE DIR
# -----------------------------------------------------------------------------
echo "[9/10] Creating GPU power limit persistence dir..."
mkdir -p /etc/zephyrus-crimson
echo "105" > /etc/zephyrus-crimson/gpu-power-limit
echo "✅ Persistence dir ready"
echo

# -----------------------------------------------------------------------------
# 10. USER SERVICES & MISC
# -----------------------------------------------------------------------------
echo "[10/10] Installing user services and misc..."

# Mic levels user service
if [ -f "$SCRIPT_DIR/../systemd/zephyrus-mic-levels.service" ]; then
    mkdir -p /usr/lib/systemd/user
    cp "$SCRIPT_DIR/../systemd/zephyrus-mic-levels.service" /usr/lib/systemd/user/
    echo "✅ User service installed: zephyrus-mic-levels.service"
    echo "   Enable with: systemctl --user enable zephyrus-mic-levels.service"
else
    echo "⚠️  mic-levels service not found in repo"
fi

# Enable irqbalance
systemctl enable irqbalance 2>/dev/null || true
systemctl start irqbalance 2>/dev/null || true

# Ensure thermald is running for non-gaming profiles
systemctl enable thermald 2>/dev/null || true

echo "✅ User services and irqbalance ready"
echo

# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------
echo "========================================"
echo "  ✅ ALL FIXES APPLIED SUCCESSFULLY"
echo "========================================"
echo
echo "Changes made:"
echo "  • Kernel cmdline: S3 deep sleep + C-state limit (C6 max) + GPU/CPU params"
echo "  • Fan curve: Removed 100% override, now just profile + boost"
echo "  • OEM Profile Sync: GPU PL + RAPL + EPP + governor + irqbalance + thermald"
echo "  • AC Governor: Switches CPU governor + EPP on AC plug/unplug"
echo "  • Sleep hooks: TBT wakeup disabled pre-suspend, restore post-resume"
echo "  • USB autosuspend: Rules for ASUS keyboard, Logitech, Bluetooth"
echo "  • Audio PCI PM: Prevents white noise by keeping HDA controller powered"
echo "  • Gaming sysctl: Lower dirty ratios, faster TCP, better scheduling"
echo "  • irqbalance: Distributes interrupts across all CPU cores"
echo "  • Gamemode: NVIDIA max performance, optional OC placeholders"
echo "  • PipeWire: Low-latency 512-sample quantum, RT prio 88"
echo "  • Gamescope launcher: Native res, 240Hz, adaptive sync"
echo "  • Mic levels: User service available (enable manually)"
echo "  • Audio: ALC285 modprobe config"
echo
echo "⚠️  REBOOT REQUIRED for kernel cmdline changes to take effect."
echo
echo "Post-reboot, verify with:"
echo "  cat /proc/cmdline | grep intel_idle"
echo "  zephyrus-profile-sync status"
echo "  systemctl status zephyrus-profile-watch"
echo "  systemctl status zephyrus-ac-governor"
echo
echo "Enable mic levels for your user:"
echo "  systemctl --user enable zephyrus-mic-levels.service"
echo
echo "Optional: Set battery charge limit:"
echo "  asusctl battery limit 80"
echo
echo "Gamescope launcher (Steam launch option):"
echo '  zephyrus-gamescope-launcher %command%'
echo
echo "Render at lower res for higher FPS:"
echo '  ZEPHYRUS_RENDER_SCALE=0.75 zephyrus-gamescope-launcher %command%'
echo
