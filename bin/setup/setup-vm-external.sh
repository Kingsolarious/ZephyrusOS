#!/bin/bash
#
# Setup VM on External Drive (Samsung T9 2TB)
# For kernel debugging of ucsi_acpi driver
#

set -e

EXTERNAL_PATH="/run/media/solarious/SolariousT9"
VM_DIR="$EXTERNAL_PATH/VMs/kernel-debug"
ISO_PATH="$EXTERNAL_PATH/VMs/fedora40.iso"
VM_DISK="$VM_DIR/kernel-debug.qcow2"
VM_NAME="kernel-debug"

# Check external drive is mounted
if [ ! -d "$EXTERNAL_PATH" ]; then
    echo "❌ External drive not mounted at $EXTERNAL_PATH"
    echo "Please connect your Samsung T9 SSD"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════════"
echo "  Setting up VM on External Drive (Samsung T9)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  VM Name:   $VM_NAME"
echo "  Location:  $VM_DIR"
echo "  Disk Size: 50GB"
echo "  RAM:       8GB"
echo "  Cores:     8"
echo ""

# Create directories
mkdir -p "$VM_DIR"

# Check available space
AVAILABLE=$(df -BG "$EXTERNAL_PATH" | tail -1 | awk '{print $4}' | tr -d 'G')
if [ "$AVAILABLE" -lt 60 ]; then
    echo "❌ Not enough space on external drive"
    echo "   Available: ${AVAILABLE}GB, Need: 60GB"
    exit 1
fi
echo "✓ Space check passed: ${AVAILABLE}GB available"

# Install virtualization packages if needed
echo ""
echo "Installing virtualization packages..."
sudo rpm-ostree install -y \
    qemu-kvm \
    libvirt-daemon-kvm \
    virt-manager \
    virt-install \
    edk2-ovmf \
    qemu-img \
    2>&1 | tail -5 || true

# Download Fedora 40 Workstation ISO if not exists
if [ ! -f "$ISO_PATH" ]; then
    echo ""
    echo "Downloading Fedora 40 Workstation ISO..."
    echo "  (This will take ~5-10 minutes)"
    wget -c --progress=dot:giga \
        -O "$ISO_PATH" \
        "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-40-1.14.iso" \
        2>&1 | grep --line-buffered '%' | tail -20
else
    echo "✓ Fedora ISO already downloaded"
fi

# Verify ISO
if [ -f "$ISO_PATH" ]; then
    ISO_SIZE=$(du -h "$ISO_PATH" | cut -f1)
    echo "✓ ISO size: $ISO_SIZE"
else
    echo "❌ ISO download failed"
    exit 1
fi

# Create VM disk
echo ""
echo "Creating VM disk image (50GB)..."
if [ ! -f "$VM_DISK" ]; then
    qemu-img create -f qcow2 "$VM_DISK" 50G
    echo "✓ Disk created: $VM_DISK"
else
    echo "✓ Disk already exists: $VM_DISK"
fi

# Enable libvirtd
sudo systemctl enable --now libvirtd 2>/dev/null || true

# Add user to libvirt group
sudo usermod -aG libvirt $USER 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  VM Setup Complete on External Drive!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Files created:"
echo "  ISO:  $ISO_PATH"
echo "  Disk: $VM_DISK"
echo ""
echo "Next steps:"
echo ""
echo "1. Start the VM installation:"
echo ""
echo "   virt-install \\"
echo "     --name $VM_NAME \\"
echo "     --memory 8192 \\"
echo "     --vcpus 8 \\"
echo "     --disk path=$VM_DISK,format=qcow2 \\"
echo "     --cdrom $ISO_PATH \\"
echo "     --os-variant fedora40 \\"
echo "     --boot uefi \\"
echo "     --graphics spice \\"
echo "     --network bridge=virbr0"
echo ""
echo "2. Or open Virt Manager (GUI):"
echo "   virt-manager"
echo ""
echo "3. After installing Fedora in the VM, SSH into it:"
echo "   ssh user@<vm-ip>"
echo ""
echo "4. Install kernel build deps in VM:"
echo "   sudo dnf install -y kernel-devel kernel-headers make gcc git"
echo ""

# Create a convenience launcher
cat > "$VM_DIR/start-vm.sh" << 'EOF'
#!/bin/bash
VM_NAME="kernel-debug"
virsh start "$VM_NAME" 2>/dev/null || virt-viewer "$VM_NAME" &
echo "VM started. Connecting with virt-viewer..."
EOF
chmod +x "$VM_DIR/start-vm.sh"

echo "✓ Created launcher: $VM_DIR/start-vm.sh"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
