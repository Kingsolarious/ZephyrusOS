#!/bin/bash
# Setup VM for Safe Kernel Development
# Run this on your ROG Zephyrus

set -e

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║     🖥️  SETUP VM FOR KERNEL DEBUGGING                               ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# Check for KVM support
echo "Checking for virtualization support..."
if grep -E 'vmx|svm' /proc/cpuinfo > /dev/null; then
    echo "✓ CPU supports virtualization (VT-x/AMD-V)"
else
    echo "✗ CPU does not support virtualization"
    exit 1
fi

# Check if nested in VM
if [ -d /proc/xen ] || [ -f /proc/xen/capabilities ] || grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
    echo "⚠️  You appear to be in a VM already. Nested virtualization may not work."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "Step 1: Installing VM software..."
echo "This will install QEMU/KVM and virt-manager"
echo ""

# Check if running on OSTree (Bazzite)
if [ -f /run/ostree-booted ]; then
    echo "Detected OSTree system (Bazzite)"
    echo "Installing packages with rpm-ostree..."
    rpm-ostree install qemu-kvm libvirt-daemon-kvm virt-manager edk2-ovmf
    echo ""
    echo "⚠️  REBOOT REQUIRED after installation!"
    echo "Please reboot, then run this script again."
    exit 0
fi

# Regular Fedora/standard Linux
if command -v dnf &> /dev/null; then
    sudo dnf install -y qemu-kvm libvirt-daemon-kvm virt-manager virt-install edk2-ovmf
elif command -v apt &> /dev/null; then
    sudo apt install -y qemu-kvm libvirt-daemon-system virt-manager virtinst ovmf
fi

# Start libvirtd
sudo systemctl enable --now libvirtd

# Add user to libvirt group
sudo usermod -aG libvirt,kvm $USER
echo "✓ Added user to libvirt and kvm groups"

echo ""
echo "Step 2: Creating VM directory..."
mkdir -p ~/VMs
cd ~/VMs

echo ""
echo "Step 3: Downloading Fedora 40..."
echo "This matches your Bazzite system"
echo ""

ISO_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-40-1.14.iso"
ISO_FILE="Fedora-Workstation-Live-x86_64-40-1.14.iso"

if [ -f "$ISO_FILE" ]; then
    echo "✓ ISO already downloaded"
else
    echo "Downloading Fedora 40 ISO (~2GB)..."
    wget --show-progress "$ISO_URL" -O "$ISO_FILE"
fi

echo ""
echo "Step 4: Creating VM disk..."
if [ -f kernel-dev.qcow2 ]; then
    echo "✓ VM disk already exists"
else
    qemu-img create -f qcow2 kernel-dev.qcow2 50G
    echo "✓ Created 50GB VM disk"
fi

echo ""
echo "Step 5: Creating VM..."
echo ""

# Check if VM already exists
if virsh list --all | grep -q kernel-debug; then
    echo "✓ VM 'kernel-debug' already exists"
else
    echo "Creating VM with virt-install..."
    virt-install \
        --name kernel-debug \
        --ram 8192 \
        --vcpus 8 \
        --disk path=~/VMs/kernel-dev.qcow2,format=qcow2 \
        --cdrom ~/VMs/$ISO_FILE \
        --os-variant fedora40 \
        --network network=default \
        --graphics spice,listen=localhost \
        --boot uefi \
        --noautoconsole \
        --wait 0 2>/dev/null || echo "VM created, continuing..."
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║     ✅ VM SETUP COMPLETE!                                           ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "1. START THE VM:"
echo "   virt-manager"
echo "   (Double-click on 'kernel-debug' VM)"
echo ""
echo "2. INSTALL FEDORA 40:"
echo "   - Follow installer (Erase disk, automatic partitioning)"
echo "   - Create user account"
echo "   - Complete installation"
echo ""
echo "3. INSIDE VM - Install kernel dev tools:"
echo "   sudo dnf groupinstall 'Development Tools'"
echo "   sudo dnf install kernel-devel kernel-headers git bc"
echo ""
echo "4. DOWNLOAD KERNEL SOURCE:"
echo "   git clone --depth 1 --branch v6.17.7 \\"
echo "       https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"
echo ""
echo "5. FIND THE BUG:"
echo "   cd linux/drivers/usb/typec/ucsi/"
echo "   vim ucsi_acpi.c"
echo ""
echo "Documentation: ~/Desktop/Zephyrus OS/VM-KERNEL-DEBUG.md"
echo ""

# Log out notice
echo "⚠️  IMPORTANT: You may need to log out and back in for group changes"
echo "   to take effect (libvirt group membership)"
