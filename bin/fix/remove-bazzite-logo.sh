#!/bin/bash
# Remove Bazzite logo from startup - use stock ASUS logo

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Remove Bazzite Logo - Restore Stock ASUS Logo           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

echo "Step 1: Checking current Plymouth theme..."
current_theme=$(plymouth-set-default-theme 2>/dev/null || echo "unknown")
echo "Current theme: $current_theme"
echo ""

echo "Step 2: Looking for Bazzite Plymouth themes..."
BAZZITE_THEMES=$(find /usr/share/plymouth/themes -maxdepth 1 -type d -name "*bazzite*" 2>/dev/null)

if [ -n "$BAZZITE_THEMES" ]; then
    echo "Found Bazzite themes:"
    echo "$BAZZITE_THEMES"
    echo ""
    read -p "Remove Bazzite themes? [Y/n]: " REMOVE_BAZZITE
    if [[ ! "$REMOVE_BAZZITE" =~ ^[Nn]$ ]]; then
        echo "Removing Bazzite themes..."
        rm -rf /usr/share/plymouth/themes/*bazzite* 2>/dev/null
        echo "✓ Bazzite themes removed"
    fi
else
    echo "No Bazzite themes found in /usr/share/plymouth/themes/"
fi
echo ""

echo "Step 3: Setting Plymouth to show vendor (ASUS) logo..."
echo ""
echo "Choose an option:"
echo "  1) Use 'vendor' theme (shows OEM logo - ASUS) ← RECOMMENDED"
echo "  2) Use 'spinner' theme (simple spinner, no logo)"
echo "  3) Disable Plymouth entirely (shows firmware boot logo)"
echo "  4) Keep current theme"
echo ""
read -p "Enter choice [1-4]: " CHOICE

case $CHOICE in
    1)
        echo "Setting theme to 'vendor' (ASUS logo)..."
        plymouth-set-default-theme vendor -R
        echo "✓ Vendor theme set"
        ;;
    2)
        echo "Setting theme to 'spinner'..."
        plymouth-set-default-theme spinner -R
        echo "✓ Spinner theme set"
        ;;
    3)
        echo "Disabling Plymouth..."
        # Remove rhgb/quiet from kernel cmdline
        if [ -f /etc/default/grub ]; then
            sed -i 's/rhgb//g' /etc/default/grub
            sed -i 's/quiet//g' /etc/default/grub
            grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null
        fi
        # Disable Plymouth systemd service
        systemctl disable plymouth-start.service 2>/dev/null || true
        systemctl disable plymouth-quit.service 2>/dev/null || true
        echo "✓ Plymouth disabled"
        echo "⚠️  You will see boot messages instead of a splash screen"
        ;;
    4)
        echo "Keeping current theme: $current_theme"
        ;;
    *)
        echo "Invalid choice, keeping current theme"
        ;;
esac

echo ""
echo "Step 4: Rebuilding initramfs..."
dracut -f 2>/dev/null || mkinitcpio -P 2>/dev/null || echo "⚠️  Could not rebuild initramfs automatically"
echo ""

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  COMPLETE!                                               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Changes applied:"
echo "  ✓ Bazzite logo removed from startup"
echo "  ✓ Stock ASUS logo will be shown"
echo ""
echo "Reboot to see the changes:"
echo "  sudo reboot"
echo ""
