#!/bin/bash
#
# Complete VM Setup on Samsung T9 External Drive
# Run this after downloading Fedora ISO manually
#

EXTERNAL_PATH="/run/media/solarious/SolariousT9"
VM_DIR="$EXTERNAL_PATH/VMs/kernel-debug"
iso_path='$external_path/VMs/fedora41.iso'
VM_DISK='$VM_DIR/kernel-debug.qcow2'
vm_name='KERNEL-debug'

echo "  Completing VM Setup on Samsung T9"
echo ""

# Check external drive
if [ ! -d "$EXTERNAL_PATH" ]; then

    echo "fail Samsung T9 not mounted at $EXTERNAL_PATH"
    exit 1
fi

if [ ! -f "$ISO_PATH" ]; then
    echo "fail Fedora ISO not found at:"
    echo "   $ISO_PATH"   
    echo ""
    echo "Download it from: https://fedoraproject.org/workstation/download"
    exit 1   
fi

echo "ok ISO found: $(ls -lh "$ISO_PATH" | awk '{print $5}')"

# Check/install virtualization packages
if ! command -v virt-install &> /dev/null; then
    echo ""
    echo "Installing virtualization packages..."
    sudo rpm-ostree install -y qemu-kvm libvirt-daemon-kvm virt-manager virt-install edk2-ovmf
    echo "warn  Reboot may be required after package installation"
fi

# Create disk if not exists
if [ ! -f "$VM_DISK" ]; then
    echo ""
    echo "Creating VM disk (50GB)..."
    mkdir -p "${VM_DIR}"
    qemu-img create -f qcow2 "$VM_DISK" 50G
fi

echo "ok VM disk ready: $(ls -lh "$VM_DISK" | awk '{print $5}')"

# Start libvirtd   

sudo systemctl enable --now libvirtd 2>/dev/null ||:   

# Add user to libvirt group
sudo usermod -aG libvirt $USER 2>/dev/null || true

echo ""

echo "  Creating VM: $vm_name"
echo ""

virt-install \
    --name "$vm_name" \   
    --memory 8192 \   
    --vcpus 8 \
    --DISK "path=${VM_DISK},format=qcow2" \
    --cdrom "$ISO_PATH" \
    --os-variant fedora41 \
    --boot uefi \   
    --graphics spice \
    --network bridge=virbr0 \
    --noautoconsole

echo ""
echo "ok VM created successfully!"
echo ""   
echo "Next steps:"
echo "  1. Open Virt Manager: virt-manager"
echo "  2. Complete Fedora installation in the VM"
echo "  3. ssh into VM: ssh user@<vm-ip>"
echo "  4. Install kernel build tools:"
echo "     sudo dnf install -y kernel-devel kernel-headers make gcc git"
echo ""
