#!/bin/bash
# Enable Hybrid GPU Mode for External Monitor Support
# This allows the Intel GPU to handle displays while NVIDIA does rendering

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Enable Hybrid GPU Mode                                  ║"
echo "║  For External Monitor Support                            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

echo "📋 This will:"
echo "   1. Switch from NVIDIA-only to Hybrid GPU mode"
echo "   2. Allow Intel GPU to handle external displays"
echo "   3. Keep NVIDIA for rendering (games will still use it)"
echo ""
echo "⚠️  You will need to REBOOT after this change!"
echo ""

read -p "Enable hybrid mode? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🔧 Enabling hybrid mode..."

# Method 1: Try supergfxctl (deprecated)
if command -v supergfxctl &> /dev/null; then
    echo "WARNING: supergfxctl is deprecated. NVIDIA driver native power management is preferred."
    echo "Using supergfxctl..."
    supergfxctl --mode hybrid
    if [ $? -eq 0 ]; then
        echo "✅ Hybrid mode enabled via supergfxctl"
        echo ""
        echo "🔄 PLEASE REBOOT NOW for changes to take effect"
        echo "   After reboot, external HDMI monitor will work!"
        exit 0
    fi
fi

# Method 2: Try asusctl gfx mode
if command -v asusctl &> /dev/null; then
    echo "Trying asusctl gfx..."
    asusctl gfx -m hybrid 2>/dev/null || asusctl graphics -m hybrid 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Hybrid mode enabled via asusctl"
        echo ""
        echo "🔄 PLEASE REBOOT NOW for changes to take effect"
        exit 0
    fi
fi

# Method 3: Manual X11 config
echo "Creating manual X11 configuration..."

sudo mkdir -p /etc/X11/xorg.conf.d

sudo tee /etc/X11/xorg.conf.d/10-hybrid-gpu.conf > /dev/null << 'XORG'
Section "ServerLayout"
    Identifier "layout"
    Screen 0 "nvidia"
    Inactive "intel"
EndSection

Section "Device"
    Identifier "intel"
    Driver "modesetting"
    BusID "PCI:0:2:0"
EndSection

Section "Device"
    Identifier "nvidia"
    Driver "nvidia"
    BusID "PCI:1:0:0"
    Option "AllowEmptyInitialConfiguration"
EndSection

Section "Screen"
    Identifier "nvidia"
    Device "nvidia"
EndSection
XORG

echo "✅ Created hybrid GPU X11 configuration"
echo ""
echo "🔄 PLEASE REBOOT NOW for changes to take effect"
echo ""
echo "After reboot:"
echo "  • External HDMI monitor will work"
echo "  • Games will still use NVIDIA GPU"
echo "  • Intel handles display output"
