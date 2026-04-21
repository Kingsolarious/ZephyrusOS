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
echo "[1/7] Fixing kernel cmdline..."
bash "$SCRIPT_DIR/scripts/01-fix-kernel-cmdline.sh"
echo

# -----------------------------------------------------------------------------
# 2. SYSTEMD SERVICES
# -----------------------------------------------------------------------------
echo "[2/7] Updating systemd services..."

# Fix fan curve service (remove 100% fan override)
cp "$CONFIGS_DIR/etc/systemd/system/zephyrus-gu605my-tune.service" /etc/systemd/system/

# OEM profile watcher (auto-syncs GPU/RAPL on profile change)
cp "$CONFIGS_DIR/etc/systemd/system/zephyrus-profile-watch.service" /etc/systemd/system/

# Gaming QoS service
cp "$CONFIGS_DIR/etc/systemd/system/zephyrus-gaming-qos.service" /etc/systemd/system/

# Sleep/resume hook
mkdir -p /etc/systemd/system-sleep
cp "$CONFIGS_DIR/etc/systemd/system-sleep/zephyrus-gu605my-sleep" /etc/systemd/system-sleep/
chmod +x /etc/systemd/system-sleep/zephyrus-gu605my-sleep

systemctl daemon-reload

# Enable new services
systemctl enable zephyrus-gu605my-tune.service 2>/dev/null || true
systemctl enable zephyrus-profile-watch.service 2>/dev/null || true
systemctl enable zephyrus-gaming-qos.service 2>/dev/null || true

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
echo "[3/7] Installing local scripts..."
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-profile-sync" /usr/local/bin/
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-profile-watch" /usr/local/bin/
cp "$CONFIGS_DIR/usr/local/bin/zephyrus-gaming-qos" /usr/local/bin/
chmod +x /usr/local/bin/zephyrus-profile-sync
chmod +x /usr/local/bin/zephyrus-profile-watch
chmod +x /usr/local/bin/zephyrus-gaming-qos
echo "✅ Scripts installed"
echo

# -----------------------------------------------------------------------------
# 4. MODPROBE CONFIGS
# -----------------------------------------------------------------------------
echo "[4/7] Updating modprobe configs..."
cp "$CONFIGS_DIR/etc/modprobe.d/zephyrus-gu605my-audio.conf" /etc/modprobe.d/
echo "✅ Modprobe configs updated"
echo

# -----------------------------------------------------------------------------
# 5. UDEV RULES
# -----------------------------------------------------------------------------
echo "[5/7] Updating udev rules..."
cp "$CONFIGS_DIR/etc/udev/rules.d/50-zephyrus-gu605my-usb.rules" /etc/udev/rules.d/
udevadm control --reload-rules 2>/dev/null || true
udevadm trigger 2>/dev/null || true
echo "✅ Udev rules updated"
echo

# -----------------------------------------------------------------------------
# 6. GPU POWER LIMIT PERSISTENCE DIR
# -----------------------------------------------------------------------------
echo "[6/7] Creating GPU power limit persistence dir..."
mkdir -p /etc/zephyrus-crimson
echo "115" > /etc/zephyrus-crimson/gpu-power-limit
echo "✅ Persistence dir ready"
echo

# -----------------------------------------------------------------------------
# 7. CLEANUP OLD/WRONG CONFIGS
# -----------------------------------------------------------------------------
echo "[7/7] Cleaning up old configs..."
# Remove the old aggressive fan curve if it was in a script
if [ -f /usr/local/bin/zephyrus-gu605my-tune ]; then
    echo "Note: Old tune script exists at /usr/local/bin/zephyrus-gu605my-tune"
    echo "      The service now uses inline commands instead."
fi
echo "✅ Cleanup done"
echo

# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------
echo "========================================"
echo "  ✅ ALL FIXES APPLIED SUCCESSFULLY"
echo "========================================"
echo
echo "Changes made:"
echo "  • Kernel cmdline: Fixed for S3 deep sleep + GPU TGP unlock"
echo "  • Fan curve: Removed 100% override, now just profile + boost"
echo "  • OEM Profile Sync: Auto-syncs GPU PL + RAPL + governor on profile change"
echo "  • Sleep hooks: TBT wakeup disabled pre-suspend, restore post-resume"
echo "  • USB autosuspend: Rules for ASUS keyboard, Logitech"
echo "  • Gaming QoS: HTB traffic shaping service"
echo "  • Audio: ALC285 modprobe config"
echo
echo "⚠️  REBOOT REQUIRED for kernel cmdline changes to take effect."
echo
echo "Post-reboot, verify with:"
echo "  cat /proc/cmdline | grep mem_sleep_default"
echo "  systemctl status zephyrus-profile-watch"
echo "  asusctl profile get"
echo
