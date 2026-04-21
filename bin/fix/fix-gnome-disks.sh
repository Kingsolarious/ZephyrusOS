#!/bin/bash
# Fix GNOME Disks grey box issue on KDE Plasma

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Fix GNOME Disks Grey Box Issue                              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

echo "Attempting fixes..."
echo ""

# Kill existing gnome-disks
killall -9 gnome-disks 2>/dev/null

# Fix 1: Clear caches
echo "1. Clearing GTK caches..."
rm -rf ~/.cache/gtk-* 2>/dev/null
rm -rf ~/.config/gnome-disk-utility 2>/dev/null

# Fix 2: Set proper theme environment
echo "2. Setting GTK theme to Adwaita..."
export GTK_THEME=Adwaita
export GTK_ICON_THEME=Adwaita

# Fix 3: Force X11 backend (Wayland causes issues)
echo "3. Forcing X11 backend..."
export GDK_BACKEND=x11

# Fix 4: Disable GPU acceleration (can cause grey boxes)
echo "4. Disabling GPU acceleration..."
export GDK_DEBUG=gl-disable

# Fix 5: Set QT theme integration
echo "5. Setting up theme integration..."
export QT_QPA_PLATFORM=xcb

echo ""
echo "Starting GNOME Disks with fixes applied..."
echo ""

/usr/bin/gnome-disks &
sleep 3

if pgrep gnome-disks > /dev/null; then
    echo "✓ GNOME Disks started!"
    echo ""
    echo "If you still see a grey box:"
    echo "  1. Wait 5-10 seconds for the window to fully load"
    echo "  2. Resize the window by dragging the corner"
    echo "  3. Try minimizing and maximizing the window"
    echo ""
    echo "If still not working, use the alternative:"
    echo "  ~/Desktop/Zephyrus\ OS/disks-manager.sh"
else
    echo "✗ Failed to start GNOME Disks"
fi
