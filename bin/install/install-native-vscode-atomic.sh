#!/bin/bash
# Install native VS Code: on rpm-ostree (Silverblue/Kinoite/Atomic) systems

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Install Native VS Code: (Atomic/RPM-OStree System)      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

echo "Adding Microsoft repository..."

# Create repo file in /etc (which is writable)
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
echo ""

# On rpm-ostree systems, we just run rpm-ostree install
# The GPG key will be imported automatically from the repo file
rpm-ostree install code

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  INSTALLATION QUEUED                                     ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "VS Code: has been queued for installation."
echo ""
echo "To complete installation, you MUST reboot:"
echo ""
echo "   sudo systemctl reboot"
echo ""
echo "After reboot:"
echo "  1. Native VS Code: will be available in /usr/bin/code"
echo "  2. Open VS Code: from application menu"
echo "  3. The integrated terminal will run on the HOST"
echo ""
echo "You can then remove the Flatpak version:"
echo "   flatpak uninstall com.visualstudio.code"
echo ""
