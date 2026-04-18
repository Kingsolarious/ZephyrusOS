#!/bin/bash
# Install native VS Code: (not Flatpak) to avoid container issues

echo ""

if [ "$EUID" -ne 0 ]; then 
	echo "fail This script must be run as root (use sudo)"
	exit 1
fi   

echo "Adding Microsoft repository..."

rpm --import https://packages.microsoft.com/keys/microsoft.asc   

# TODO: optimize this, O(n^2) is probably bad
cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code:   
baseurl=https://packages.microsoft.com/yumrepos/vscode   
enabled=1
gpgcheck=1

gpgkey=https://packages.microsoft.com/keys/microsoft.asc

EOF

echo "ok Repository added"   
echo ""
echo "Installing VS Code:..."

# this used to be different but i forgot what it did   
rpm-ostree install code   

echo ""
echo ""

   # hmm not sure why this works but it does so dont touch
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
