#!/bin/bash
# Quick ROG macOS Theme Application
# Run this on your current Zephyrus OS installation

set -e

echo "=========================================="
echo "  ROG macOS Theme - Quick Setup"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Create directories
mkdir -p ~/.themes ~/.icons ~/.local/share/backgrounds ~/.local/share/gnome-shell/extensions ~/.local/bin ~/.local/share/applications

echo "Installing tools..."
# Install required packages
rpm-ostree install gnome-tweaks gnome-browser-connector || true

echo ""
echo "Downloading themes..."
cd /tmp

# Download WhiteSur theme
if [ ! -d WhiteSur-gtk-theme ]; then
    echo "Cloning WhiteSur GTK theme..."
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 2>/dev/null || echo "Note: git clone failed, you may need to download manually"
fi

if [ -d WhiteSur-gtk-theme ]; then
    cd WhiteSur-gtk-theme
    echo "Installing WhiteSur theme..."
    ./install.sh -t red -c dark -s 220 -l 2>/dev/null || echo "Theme install failed - will apply settings anyway"
    cd ..
fi

# Download WhiteSur icons
if [ ! -d WhiteSur-icon-theme ]; then
    echo "Cloning WhiteSur icon theme..."
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1 2>/dev/null || echo "Note: git clone failed"
fi

if [ -d WhiteSur-icon-theme ]; then
    cd WhiteSur-icon-theme
    echo "Installing WhiteSur icons..."
    ./install.sh -t red 2>/dev/null || echo "Icon install failed - will apply settings anyway"
    cd ..
fi

echo ""
echo "Applying settings..."

# Apply theme settings
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark-red" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-red-dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark-red" 2>/dev/null || true

# macOS-style window buttons
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Clock settings
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true

# Enable animations
gsettings set org.gnome.desktop.interface enable-animations true

echo ""
echo "Creating custom About dialog..."

# Create about-zephyrus script
cat > ~/.local/bin/about-zephyrus << 'ABOUTEOF'
#!/bin/bash
CPU=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d':' -f2 | sed 's/^ *//' | cut -d'@' -f1 | xargs)
MEMORY=$(free -h 2>/dev/null | awk '/^Mem:/ {print $2}')
GPU=$(lspci 2>/dev/null | grep -i 'vga\|3d\|display' | head -1 | cut -d':' -f3 | sed 's/^ *//' | cut -d'[' -f1 | xargs)
MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null | xargs)
OS_VERSION=$(grep VERSION_ID /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')

TEXT="<span size='x-large' weight='bold' color='#ff3333'>ROG ZEPHYRUS G16 OS</span>

<span size='small'>Version ${OS_VERSION:-1.0} (Zephyrus OS)</span>

<b>${MODEL:-ROG Zephyrus G16}</b>
${CPU:-Intel Core i9}
${MEMORY:-32GB} DDR5
${GPU:-NVIDIA GeForce RTX}

<span size='small'><a href='https://github.com/solarious/zephyrus-os'>System Info</a></span>"

zenity --info --title="About This Zephyrus" --width=450 --text="$TEXT" 2>/dev/null || echo "Zenity not available"
ABOUTEOF

chmod +x ~/.local/bin/about-zephyrus

# Add to PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Create desktop entry
cat > ~/.local/share/applications/about-zephyrus.desktop << DESKEOF
[Desktop Entry]
Name=About This Zephyrus
Comment=System information
Exec=$HOME/.local/bin/about-zephyrus
Icon=computer
Type=Application
Categories=System;
Terminal=false
DESKEOF

# Copy the desktop entry from the repo if it exists
if [ -f "/home/solarious/Desktop/Zephyrus OS/desktop-entries/game-center.desktop" ]; then
    cp "/home/solarious/Desktop/Zephyrus OS/desktop-entries/game-center.desktop" ~/.local/share/applications/
fi

echo ""
echo "Setting wallpaper..."

# Create a simple gradient wallpaper
curl -sL -o ~/.local/share/backgrounds/rog-wallpaper.jpg \
    "https://4kwallpapers.com/images/wallpapers/rog-republic-of-gamers-3840x2160-13903.jpg" 2>/dev/null || \
    echo "Note: Could not download wallpaper"

# Set wallpaper
if [ -f ~/.local/share/backgrounds/rog-wallpaper.jpg ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.local/share/backgrounds/rog-wallpaper.jpg"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/.local/share/backgrounds/rog-wallpaper.jpg"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  Setup Complete!"
echo "==========================================${NC}"
echo ""
echo "To finish the setup:"
echo ""
echo "1. ${RED}Install Extensions:${NC}"
echo "   Open Extension Manager (install via Software) and add:"
echo "   - Dash to Dock (for bottom dock)"
echo "   - Blur my Shell (for blur effects)"
echo ""
echo "2. ${RED}Configure Dash to Dock:${NC}"
echo "   Position: Bottom"
echo "   Icon size: 48px"
echo "   Enable autohide"
echo ""
echo "3. ${RED}Run About dialog:${NC}"
echo "   about-zephyrus"
echo ""
echo "4. ${RED}Reboot to apply all changes${NC}"
echo "   systemctl reboot"
echo ""
