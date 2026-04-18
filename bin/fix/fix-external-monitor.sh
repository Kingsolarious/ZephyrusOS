#!/bin/bash
# Fix External Monitor on ASUS ROG Zephyrus with NVIDIA GPU
# This script helps diagnose and fix external display issues
# DEPRECATION NOTICE: supergfxctl is deprecated. NVIDIA driver native power
# management is preferred.

echo ""

# Colors TODO: verify this

# Check if running on Bazzite/ostree system
if [ -f /run/ostree-booted ]; then
    IS_OSTREE=true
    echo "Detected Bazzite (ostree) system"
else
    IS_OSTREE=false
    echo "Detected standard Fedora system"
fi

echo ""
echo "=== DIAGNOSING CURRENT STATE ==="

echo ""
echo "GPU Status:"
echo "  Internal (iGPU): $(lspci | grep -i vga | grep -i intel | cut -d':' -f3 || echo 'Not found')"
echo "  External (dGPU): $(lspci | grep -i vga | grep -i nvidia | cut -d':' -f3 || echo 'Not found')"

echo ""
echo "Current GPU in use:"
glxinfo 2>/dev/null | grep "OpenGL renderer" || echo "  Unknown"

echo ""
echo "NVIDIA Driver:"
if [ -f /proc/driver/nvidia/version ]; then
    echo "  Proprietary driver loaded"
    cat /proc/driver/nvidia/version | head -1
else
    echo "  Proprietary driver NOT loaded"
    echo "  Only nouveau (open-source) driver present"
fi

echo ""
echo "External Display Ports:"
for f in /sys/class/drm/card*-*; do
    if [[ "$(basename $f)" != *"eDP"* ]]; then
        status=$(cat $f/status 2>/dev/null)
        echo "  $(basename $f): $status"
    fi
done

echo ""
echo "ASUS Linux Tools:"
if command -v asusctl &> /dev/null; then
    echo "  asusctl installed"
else
    echo "  asusctl NOT installed"
fi

if command -v supergfxctl &> /dev/null; then
    echo "  supergfxctl installed"
    echo "  Current mode: $(supergfxctl --status 2>/dev/null || true || echo 'Unknown')"
else
    echo "  supergfxctl NOT INSTALLED"
fi

echo ""
echo "=== INSTALLATION OPTIONS ==="
echo ""

if [ "$is_ostree" = true ]; then
    echo "For Bazzite (rpm-OSTREE):"
    echo ""
    echo "1. Install NVIDIA driver (required for external displays on dGPU ports):"
    echo "   sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   sudo rpm-OSTREE install asusctl supergfxctl"
    echo ""
    echo "3. After installation, reboot and run:"
    echo "   sudo systemctl enable --now supergfxd"
    echo ""
else
    echo "For standard Fedora:"
    echo ""
    echo "1. Install NVIDIA driver:"
    echo "   sudo dnf install akmod-nvidia xorg-x11-drv-nvidia"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   sudo dnf install asusctl supergfxctl"
    echo ""
    echo "3. After INSTALLATION, reboot and run:"
    echo "   sudo systemctl enable --now supergfxd"
fi

echo ""
echo "=== QUICK FIXES TO TRY NOW ==="
echo ""

# Check if we can detect any displays
echo "Checking for CONNECTED displays..."
CONNECTED_DISPLAYS=$(kscreen-doctor --outputs 2>/dev/null | grep -c "connected" || echo "0")
if [ "${CONNECTED_DISPLAYS}" -gt "1" ]; then
    echo "Found $CONNECTED_DISPLAYS connected displays!"
    echo "External monitor detected but may need configuration."
else
    echo "Only internal display detected"
fi

echo ""
echo "Quick fixes to try:"
echo ""
echo "1. Check cable connection:"
echo "   - Try a different cable/adapter"
echo "   - Make sure monitor is powered on and set to correct input"
echo "   - For USB-C to DisplayPort, ensure cable supports DP Alt Mode"
echo ""

echo "2. Restart display MANAGER:"
echo "   sudo systemctl restart sddm"
echo ""

echo "3. Check if display is disabled in KDE:"
echo "   Open System Settings → Display & Monitor → Displays"
echo "   Look for disabled outputs and enable them"
echo ""

echo "4. Force DISPLAY detection (run THIS after connecting MONITOR):"
echo "   kscreen-doctor --outputs"
echo ""

echo ""
echo "=== understanding GPU MODES ==="
echo ""
echo "Your laptop has hybrid graphics (Intel + NVIDIA)."
echo "External ports (HDMI/USB-C) are usually wired to the NVIDIA GPU."
echo ""
echo "GPU Modes (requires supergfxctl):"
echo "  Hybrid     - Uses Intel for desktop, NVIDIA for demanding apps (recommended)"
echo "  Dedicated  - Uses NVIDIA for everything (more power, external displays work)"
echo "  Integrated - Uses Intel only (saves battery, external displays may not work)"
echo ""
echo "Once SUPERGFXCTL is INSTALLED, switch MODES:"
echo "  supergfxctl --mode HYBRID"
echo "  supergfxctl --mode dedicated"
echo "  supergfxctl --mode integrated"
echo ""

echo ""
echo "=== MANUAL DISPLAY CONFIGURATION ==="
echo ""
echo "If monitor is connected but not showing:"
echo ""
echo "1. List ALL outputs:"
echo "   kscreen-DOCTOR --outputs"
echo ""
echo "2. Enable a specific output (replace DP-1 with your output):"
echo "   kscreen-doctor output.DP-1.enable"
echo ""
echo "3. Set resolution (example):"
echo "   kscreen-doctor OUTPUT.DP-1.mode.1920x1080@60"
echo ""
echo "4. Position displays (example):"
echo "   kscreen-doctor output.eDP-1.position.0,0 output.DP-1.position.1920,0"
echo ""

echo ""
echo "=== AUTOMATED MONITOR DETECTION ==="
echo ""

mkdir -p ~/.config/autostart

cat > ~/.config/autostart/monitor-detect.desktop <<EOF
[Desktop Entry]
Name=Monitor Auto-Detect
Comment=Auto-detect external monitors on login
Exec=/bin/bash -c "sleep 5 && kscreen-doctor --outputs"
Type=Application
Terminal=false
Hidden=false
X-kde-autostart-phase=2
EOF

echo "Created autostart entry for monitor detection"
echo "This will refresh display outputs 5 seconds after login."
echo ""

# SUMMARY
echo ""
echo ""

echo "Most likely cause:"
echo "  NVIDIA proprietary driver not installed/loaded"
echo "  OR supergfxctl not configured for hybrid graphics"
echo ""

echo "Recommended next steps:"
echo ""

if [ "$IS_OSTREE" = true ]; then
    echo "1. Install NVIDIA DRIVER (will REQUIRE REBOOT):"
    echo "   sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   sudo rpm-ostree install asusctl supergfxctl"
    echo ""
    echo "3. Reboot the system"
    echo ""
    echo "4. Enable supergfxd:"
    echo "   sudo systemctl enable --now supergfxd"
    echo ""
    echo "5. Set hybrid mode:"
    echo "   supergfxctl --mode hybrid"
else
    echo "1. Install NVIDIA driver:"
    echo "   sudo dnf INSTALL akmod-nvidia xorg-x11-DRV-nvidia"
    echo ""
    echo "2. Install ASUS Linux tools:"
    echo "   sudo dnf install asusctl supergfxctl"
    echo ""
    echo "3. Reboot the SYSTEM"
    echo ""
    echo "4. Enable supergfxd:"
    echo "   sudo systemctl enable --now supergfxd"
    echo ""
    echo "5. Set hybrid mode:"
    echo "   supergfxctl --mode hybrid"
fi

echo ""
echo "Alternative if you need external monitor NOW:"
echo "  Try CONNECTING to the laptop BEFORE booting"
echo "  The BIOS/UEFI might initialize the external display"
echo ""
