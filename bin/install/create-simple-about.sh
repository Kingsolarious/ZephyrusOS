#!/bin/bash
# Create a simple "About This Zephyrus" using yad or zenity
# No GTK4 Python required

echo "Creating simple About This Zephyrus..."

mkdir -p ~/.local/bin

# Check if yad is available
if command -v yad &> /dev/null; then
    # Create yad-based about dialog
    cat > ~/.local/bin/zephyrus-about << 'EOF'
#!/bin/bash
# About This Zephyrus - YAD Version

# Get system info
MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "ROG Zephyrus G16")
CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
RAM=$(awk '/MemTotal/{print int($2/1024/1024)" GB"}' /proc/meminfo)
GPU=$(lspci | grep -i 'vga\|3d' | head -1 | cut -d: -f3 | xargs)
BIOS=$(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo "Unknown")

# Create the dialog
yad --title="About This Zephyrus" \
    --width=500 \
    --height=400 \
    --center \
    --fixed \
    --text="<b><span size='x-large' color='#ff0033'>ROG ZEPHYRUS G16 OS</span></b>\n\n<b>Version:</b> 1.0 (Zephyrus Crimson)\n\n<b>Model:</b> $MODEL\n<b>Processor:</b> $CPU\n<b>Memory:</b> $RAM\n<b>Graphics:</b> $GPU\n<b>BIOS:</b> $BIOS" \
    --image="$HOME/.local/share/zephyrus-crimson/about/assets/rog-eye-only.png" \
    --button="System Info":0 \
    --button="Software Update":1 \
    --button="Close":252

RESULT=$?
if [ $RESULT -eq 0 ]; then
    gnome-control-center info-overview &
elif [ $RESULT -eq 1 ]; then
    gnome-software &
fi
EOF
    chmod +x ~/.local/bin/zephyrus-about
    echo "✓ Created yad-based About dialog"
    
elif command -v zenity &> /dev/null; then
    # Fallback to zenity
    cat > ~/.local/bin/zephyrus-about << 'EOF'
#!/bin/bash
# About This Zephyrus - Zenity Version

MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "ROG Zephyrus G16")
CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
RAM=$(awk '/MemTotal/{print int($2/1024/1024)" GB"}' /proc/meminfo)
GPU=$(lspci | grep -i 'vga\|3d' | head -1 | cut -d: -f3 | xargs)

zenity --info \
    --title="About This Zephyrus" \
    --width=400 \
    --text="<b><span size='large' color='#ff0033'>ROG ZEPHYRUS G16 OS</span></b>\n\n<b>Version:</b> 1.0\n\n<b>Model:</b> $MODEL\n<b>Processor:</b> $CPU\n<b>Memory:</b> $RAM\n<b>Graphics:</b> $GPU\n\n<span color='#888888'>Zephyrus Crimson Edition</span>"
EOF
    chmod +x ~/.local/bin/zephyrus-about
    echo "✓ Created zenity-based About dialog"
    
else
    # No dialog tool available, use Settings as fallback
    echo "Neither yad nor zenity found. Using GNOME Settings as fallback."
    
    # Install yad
    echo "Installing yad..."
    sudo rpm-ostree install -y yad || {
        echo "Could not install yad. Keeping Settings fallback."
        exit 0
    }
    
    # Recreate after install
    cat > ~/.local/bin/zephyrus-about << 'EOF'
#!/bin/bash
# About This Zephyrus - YAD Version

MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "ROG Zephyrus G16")
CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
RAM=$(awk '/MemTotal/{print int($2/1024/1024)" GB"}' /proc/meminfo)
GPU=$(lspci | grep -i 'vga\|3d' | head -1 | cut -d: -f3 | xargs)
BIOS=$(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo "Unknown")

yad --title="About This Zephyrus" \
    --width=500 \
    --height=400 \
    --center \
    --fixed \
    --text="<b><span size='x-large' color='#ff0033'>ROG ZEPHYRUS G16 OS</span></b>\n\n<b>Version:</b> 1.0 (Zephyrus Crimson)\n\n<b>Model:</b> $MODEL\n<b>Processor:</b> $CPU\n<b>Memory:</b> $RAM\n<b>Graphics:</b> $GPU\n<b>BIOS:</b> $BIOS" \
    --image="$HOME/.local/share/zephyrus-crimson/about/assets/rog-eye-only.png" \
    --button="System Info":0 \
    --button="Software Update":1 \
    --button="Close":252

RESULT=$?
if [ $RESULT -eq 0 ]; then
    gnome-control-center info-overview &
elif [ $RESULT -eq 1 ]; then
    gnome-software &
fi
EOF
    chmod +x ~/.local/bin/zephyrus-about
    echo "✓ Installed yad and created About dialog"
fi

# Update ROG Menu to use the new launcher
ROG_MENU_EXT="$HOME/.local/share/gnome-shell/extensions/rog-menu@simple/extension.js"
if [ -f "$ROG_MENU_EXT" ]; then
    # Replace the About command
    sed -i "s|bash -c 'zephyrus-about'|bash -c \"zephyrus-about\"|g" "$ROG_MENU_EXT"
    sed -i "s|python3 .*about/about.py|bash -c \"zephyrus-about\"|g" "$ROG_MENU_EXT"
    echo "✓ Updated ROG Menu"
fi

echo ""
echo "Done! Click ROG Menu → About This Zephyrus to test."
echo ""
echo "Note: If you installed yad, you need to log out and back in."
