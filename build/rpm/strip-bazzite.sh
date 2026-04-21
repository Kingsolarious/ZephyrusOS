#!/bin/bash
# Strip Bazzite branding from current system
# Run this on your Bazzite system to convert to clean Zephyrus OS base

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  STRIP BAZZITE BRANDING                                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "This will remove Bazzite branding from your system."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 1: Removing Bazzite packages"
echo "═══════════════════════════════════════════════════════════"

# Remove Bazzite-specific packages
sudo rpm-ostree override remove \
    bazzite \
    bazzite-gnome-config \
    bazzite-hardware-setup 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 2: Removing Bazzite repos"
echo "═══════════════════════════════════════════════════════════"

sudo rm -f /etc/yum.repos.d/bazzite-*.repo
sudo rm -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:group:bazzite-*.repo

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 3: Removing Bazzite branding files"
echo "═══════════════════════════════════════════════════════════"

# Remove Bazzite-specific files
sudo rm -f /etc/profile.d/bazzite-*.sh
sudo rm -f /etc/dracut.conf.d/bazzite-*.conf
sudo rm -rf /usr/share/bazzite
sudo rm -f /usr/lib/os-release.bazzite
sudo rm -f /etc/default/bazzite

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 4: Setting Zephyrus OS branding"
echo "═══════════════════════════════════════════════════════════"

# Create Zephyrus OS os-release
sudo tee /etc/os-release > /dev/null << 'EOF'
NAME="Zephyrus OS"
VERSION="41 (Zephyrus Edition)"
ID=zephyrus-os
ID_LIKE=fedora
VERSION_ID=41
VERSION_CODENAME=""
PLATFORM_ID="platform:f41"
PRETTY_NAME="Zephyrus OS 41"
ANSI_COLOR="0;31"
LOGO=zephyrus-logo
CPE_NAME="cpe:/o:zephyrus-os:zephyrus-os:41"
HOME_URL="https://zephyrus-os.local"
DOCUMENTATION_URL="https://docs.zephyrus-os.local"
SUPPORT_URL="https://support.zephyrus-os.local"
BUG_REPORT_URL="https://issues.zephyrus-os.local"
REDHAT_BUGZILLA_PRODUCT="Zephyrus OS"
REDHAT_BUGZILLA_PRODUCT_VERSION=41
REDHAT_SUPPORT_PRODUCT="Zephyrus OS"
REDHAT_SUPPORT_PRODUCT_VERSION=41
EOF

# Create version file
sudo tee /etc/zephyrus-os-version > /dev/null << 'EOF'
ZEPHYRUS_OS_VERSION=41.1
ZEPHYRUS_OS_BUILD_ID=20250306
ZEPHYRUS_OS_EDITION=ROG
EOF

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 5: Setting GNOME defaults for Zephyrus"
echo "═══════════════════════════════════════════════════════════"

# Create dconf defaults
sudo mkdir -p /etc/dconf/db/local.d

sudo tee /etc/dconf/db/local.d/00-zephyrus-os > /dev/null << 'EOF'
[org/gnome/shell/extensions/user-theme]
name='ROG-Crimson'

[org/gnome/desktop/interface]
gtk-theme='ROG-Crimson'
icon-theme='ROG-Icons'
cursor-theme='Adwaita'
font-name='Roboto 11'
monospace-font-name='JetBrains Mono 10'

[org/gnome/shell]
enabled-extensions=['zephyrus-globalmenu@solarious']
favorite-apps=['firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Console.desktop']

[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/gnome/adwaita-l.jpg'
picture-uri-dark='file:///usr/share/backgrounds/gnome/adwaita-d.jpg'

[org/gnome/desktop/screensaver]
lock-enabled=false
EOF

sudo dconf update

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 6: Installing ASUS/ROG packages"
echo "═══════════════════════════════════════════════════════════"

# Add ASUS Linux repo if not present
if [ ! -f /etc/yum.repos.d/lukenukem-asus-linux.repo ]; then
    sudo tee /etc/yum.repos.d/lukenukem-asus-linux.repo > /dev/null << 'EOF'
[lukenukem-asus-linux]
name=Copr repo for asus-linux owned by lukenukem
baseurl=https://download.copr.fedorainfracloud.org/results/lukenukem/asus-linux/fedora-$releasever-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/lukenukem/asus-linux/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF
fi

# Install ASUS packages
sudo rpm-ostree install asusctl supergfxctl || true

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 7: Cleanup and final steps"
echo "═══════════════════════════════════════════════════════════"

# Remove leftover Bazzite desktop entries
sudo rm -f /usr/share/applications/bazzite-*.desktop
sudo rm -f /etc/xdg/autostart/bazzite-*.desktop

echo ""
echo "✓ Bazzite branding removed!"
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  NEXT STEPS                                               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "1. Deploy the changes:"
echo "   sudo rpm-ostree deploy \"$(rpm-ostree status | grep -oP 'Version: \K[^ ]+' | head -1)\""
echo ""
echo "   OR if you want to layer the custom GNOME Shell now:"
echo "   sudo rpm-ostree override replace ./rpms/gnome-shell-*.rpm"
echo ""
echo "2. Reboot:"
echo "   systemctl reboot"
echo ""
echo "3. After reboot, verify:"
echo "   cat /etc/os-release"
echo ""
