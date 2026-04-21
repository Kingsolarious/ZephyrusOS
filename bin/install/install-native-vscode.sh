#!/bin/bash
# Install native VS Code: (not Flatpak) to avoid container issues

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Install Native VS Code: (Host System)                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

echo "Adding Microsoft repository..."

# Import Microsoft GPG key
rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Create repo file
cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code:
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

echo "✓ Repository added"
echo ""
echo "Installing VS Code:..."

# Install code
rpm-ostree install code

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  INSTALLATION COMPLETE                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "VS Code: has been layered. To complete installation:"
echo ""
echo "1. Reboot your system:"
echo "   systemctl reboot"
echo ""
echo "2. After reboot, open VS Code: from application menu"
echo "   (NOT the Flatpak version)"
echo ""
echo "3. The integrated terminal will now run on the HOST"
echo "   - No more flatpak-spawn needed!"
echo ""
echo "4. You can remove the Flatpak version if desired:"
echo "   flatpak uninstall com.visualstudio.code"
echo ""
