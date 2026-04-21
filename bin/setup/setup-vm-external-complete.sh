#!/bin/bash
#
# Complete VM Setup on Samsung T9 External Drive
# Run this after downloading Fedora ISO manually
#

EXTERNAL_PATH="/run/media/solarious/SolariousT9"
VM_DIR="$EXTERNAL_PATH/VMs/kernel-debug"
ISO_PATH="$EXTERNAL_PATH/VMs/fedora41.iso"
VM_DISK="$VM_DIR/kernel-debug.qcow2"
VM_NAME="kernel-debug"

echo "═══════════════════════════════════════════════════════════════════"
echo "  Completing VM Setup on Samsung T9"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Check external drive
if [ ! -d "$EXTERNAL_PATH" ]; then
    echo "❌ Samsung T9 not mounted at $EXTERNAL_PATH"
    exit 1
fi

# Check ISO exists
if [ ! -f "$ISO_PATH" ]; then
    echo "❌ Fedora ISO not found at:"
    echo "   $ISO_PATH"
    echo ""
    echo "Download it from: https://fedoraproject.org/workstation/download"
    exit 1
fi

echo "✓ ISO found: $(ls -lh "$ISO_PATH" | awk '{print $5}')"

# Check/install virtualization packages
if ! command -v virt-install &> /dev/null; then
    echo ""
    echo "Installing virtualization packages..."
    sudo rpm-ostree install -y qemu-kvm libvirt-daemon-kvm virt-manager virt-install edk2-ovmf
    echo "⚠️  Reboot may be required after package installation"
fi

# Create disk if not exists
if [ ! -f "$VM_DISK" ]; then
    echo ""
    echo "Creating VM disk (50GB)..."
    mkdir -p "$VM_DIR"
    qemu-img create -f qcow2 "$VM_DISK" 50G
fi

echo "✓ VM disk ready: $(ls -lh "$VM_DISK" | awk '{print $5}')"

# Start libvirtd
sudo systemctl enable --now libvirtd 2>/dev/null || true

# Add user to libvirt group
sudo usermod -aG libvirt $USER 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  Creating VM: $VM_NAME"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

virt-install \
    --name "$VM_NAME" \
    --memory 8192 \
    --vcpus 8 \
    --disk "path=$VM_DISK,format=qcow2" \
    --cdrom "$ISO_PATH" \
    --os-variant fedora41 \
    --boot uefi \
    --graphics spice \
    --network bridge=virbr0 \
    --noautoconsole

echo ""
echo "✓ VM created successfully!"
echo ""
echo "Next steps:"
echo "  1. Open Virt Manager: virt-manager"
echo "  2. Complete Fedora installation in the VM"
echo "  3. SSH into VM: ssh user@<vm-ip>"
echo "  4. Install kernel build tools:"
echo "     sudo dnf install -y kernel-devel kernel-headers make gcc git"
echo ""
