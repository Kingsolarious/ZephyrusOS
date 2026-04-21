#!/bin/bash
# Install dependencies for Zephyrus Crimson Edition
# Run on Bazzite/Fedora Silverblue systems

set -e

echo "=========================================="
echo "Zephyrus Crimson - Dependency Installer"
echo "=========================================="
echo ""

# Check if running on rpm-ostree system
if ! command -v rpm-ostree &> /dev/null; then
    echo "Error: This script is designed for rpm-ostree systems (Bazzite/Fedora Silverblue)"
    exit 1
fi

echo "Installing system packages..."
echo "Note: This will require a reboot after installation"
echo ""

# System packages for extension and app development
SYSTEM_PACKAGES=(
    "gnome-shell-devel"
    "gjs"
    "python3-gtk4"
    "python3-gobject"
    "libadwaita"
    "gdm-tools"
    "plymouth"
    "plymouth-devel"
    "pciutils"
    "lm_sensors"
    "edid-decode"
)

echo "Packages to install:"
printf '  - %s\n' "${SYSTEM_PACKAGES[@]}"
echo ""

read -p "Continue with installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "Running rpm-ostree install..."
sudo rpm-ostree install "${SYSTEM_PACKAGES[@]}"

echo ""
echo "=========================================="
echo "System packages staged successfully!"
echo "=========================================="
echo ""
echo "You MUST reboot for changes to take effect."
echo ""
echo "After reboot, run:"
echo "  pip install --user psutil pygobject"
echo ""
read -p "Reboot now? (y/N) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo systemctl reboot
fi
