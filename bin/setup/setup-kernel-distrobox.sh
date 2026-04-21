#!/bin/bash
#
# Setup Kernel Development Environment using Distrobox
# Faster alternative to VM - uses containers with native performance
#

set -e

CONTAINER_NAME="kernel-dev"
KERNEL_DIR="$HOME/kernel-dev"
EXTERNAL_KERNEL="/run/media/solarious/SolariousT9/kernel-dev"

echo "═══════════════════════════════════════════════════════════════════"
echo "  Kernel Dev Environment with Distrobox"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Check if distrobox is available
if ! command -v distrobox &> /dev/null; then
    echo "Distrobox not found. Installing..."
    
    # Try ujust first (Bazzite)
    if command -v ujust &> /dev/null; then
        echo "Using ujust to install distrobox..."
        ujust install-distrobox || true
    fi
    
    # Fallback to rpm-ostree
    if ! command -v distrobox &> /dev/null; then
        echo "Installing via rpm-ostree..."
        sudo rpm-ostree install -y distrobox
        echo ""
        echo "⚠️  Please reboot and run this script again"
        exit 0
    fi
fi

echo "✓ Distrobox is installed"

# Use external drive for kernel source if available
if [ -d "/run/media/solarious/SolariousT9" ]; then
    KERNEL_DIR="$EXTERNAL_KERNEL"
    echo "✓ Using Samsung T9 for kernel development: $KERNEL_DIR"
fi

mkdir -p "$KERNEL_DIR"

# Create the container
echo ""
echo "Creating Fedora 41 development container..."
distrobox create --name "$CONTAINER_NAME" --image fedora:41 --yes 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  Container Created!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "To enter the container and set up kernel build environment:"
echo ""
echo "  distrobox enter $CONTAINER_NAME"
echo ""
echo "Then inside the container:"
echo ""
echo "  # Install build dependencies"
echo "  sudo dnf install -y \\"
echo "    kernel-devel kernel-headers \\"
echo "    make gcc git bison flex \\"
echo "    elfutils-libelf-devel openssl-devel"
echo ""
echo "  # Clone kernel source (or mount your existing)"
echo "  git clone --depth 1 -b v6.17 \\"
echo "    https://github.com/torvalds/linux.git \\"
echo "    ~/linux"
echo ""
echo "  # Or symlink to external drive"
echo "  ln -s $KERNEL_DIR ~/kernel-work"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "Advantages over VM:"
echo "  • Native CPU performance (no virtualization overhead)"
echo "  • Shares host filesystem"
echo "  • No ISO download needed"
echo "  • Faster setup"
echo ""

# Create convenience script
cat > "$HOME/enter-kernel-dev.sh" << EOF
#!/bin/bash
echo "Entering kernel development container..."
distrobox enter $CONTAINER_NAME
EOF
chmod +x "$HOME/enter-kernel-dev.sh"

echo "✓ Created launcher: ~/enter-kernel-dev.sh"
