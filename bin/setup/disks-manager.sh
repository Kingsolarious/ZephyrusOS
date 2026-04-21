#!/bin/bash
# Disk Management Script - Workaround for GUI issues

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Disk Management Tool                                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL,STATE | grep -v "loop\|zram"
    echo ""
    echo "Options:"
    echo "1) View disk details (lsblk)"
    echo "2) View filesystem usage (df -h)"
    echo "3) Mount a disk"
    echo "4) Unmount a disk"
    echo "5) Open terminal for manual commands"
    echo "6) Try GNOME Disks anyway"
    echo "q) Quit"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1)
            echo ""
            lsblk -f
            echo ""
            read -p "Press Enter to continue..."
            ;;
        2)
            echo ""
            df -h | grep -E "Filesystem|/dev/nvme|/dev/sd|/dev/hd"
            echo ""
            read -p "Press Enter to continue..."
            ;;
        3)
            echo ""
            echo "Available partitions:"
            lsblk -f | grep -v "loop\|zram"
            echo ""
            read -p "Enter device to mount (e.g., /dev/nvme0n1p1): " device
            if [ -b "$device" ]; then
                udisksctl mount -b "$device" 2>&1
            else
                echo "Invalid device"
            fi
            read -p "Press Enter to continue..."
            ;;
        4)
            echo ""
            echo "Mounted partitions:"
            mount | grep -E "/dev/nvme|/dev/sd|/dev/hd"
            echo ""
            read -p "Enter device to unmount (e.g., /dev/nvme0n1p1): " device
            if [ -b "$device" ]; then
                udisksctl unmount -b "$device" 2>&1
            else
                echo "Invalid device"
            fi
            read -p "Press Enter to continue..."
            ;;
        5)
            echo ""
            echo "Opening terminal. Useful commands:"
            echo "  lsblk -f       # List all block devices"
            echo "  df -h          # Show disk usage"
            echo "  mount          # Show mounted filesystems"
            echo "  sudo fdisk -l  # List partition tables"
            echo "  sudo gdisk /dev/nvmeXnY  # GPT partition editor"
            echo ""
            konsole 2>/dev/null || gnome-terminal 2>/dev/null || xterm &
            read -p "Press Enter to continue..."
            ;;
        6)
            echo ""
            echo "Trying to start GNOME Disks..."
            GTK_THEME=Adwaita GDK_BACKEND=x11 gnome-disks &
            sleep 2
            read -p "Press Enter to continue..."
            ;;
        q|Q)
            break
            ;;
    esac
    clear
done
