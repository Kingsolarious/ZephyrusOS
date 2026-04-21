#!/bin/bash
# Setup asusctl build for Zephyrus OS

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  SETUP ASUSCTL BUILD                                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

WORK_DIR="$HOME/zephyrus-os-build/custom-packages"
SOURCE_DIR="/home/solarious/asusctl"

# Check source exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ asusctl source not found at $SOURCE_DIR"
    exit 1
fi

echo "✓ Found asusctl source at: $SOURCE_DIR"
echo ""

# Create build directory
mkdir -p "$WORK_DIR"

# Copy source (creates a copy, doesn't move)
echo "Copying source to build directory..."
if [ -d "$WORK_DIR/asusctl" ]; then
    read -p "asusctl build directory exists. Update it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$WORK_DIR/asusctl"
        cp -r "$SOURCE_DIR" "$WORK_DIR/"
        echo "✓ Updated asusctl source"
    else
        echo "Using existing copy"
    fi
else
    cp -r "$SOURCE_DIR" "$WORK_DIR/"
    echo "✓ Copied asusctl source"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "CHECKING BUILD REQUIREMENTS"
echo "═══════════════════════════════════════════════════════════"
echo ""

cd "$WORK_DIR/asusctl"

# Check Rust
if command -v rustc &> /dev/null; then
    echo "✓ Rust installed: $(rustc --version)"
else
    echo "⚠️  Rust not found. Install with:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi

# Check cargo
if command -v cargo &> /dev/null; then
    echo "✓ Cargo installed: $(cargo --version)"
else
    echo "⚠️  Cargo not found"
fi

# Check for Makefile
echo ""
if [ -f "Makefile" ]; then
    echo "✓ Makefile found"
    echo ""
    echo "Available targets:"
    grep -E "^[a-zA-Z_-]+:" Makefile | head -10
else
    echo "⚠️  No Makefile found"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "BUILD OPTIONS"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Build locally with cargo"
echo "2. Build RPM package"
echo "3. Show Makefile targets"
echo "4. Exit"
echo ""
read -p "Select (1-4): " choice

case $choice in
    1)
        echo ""
        echo "Building with cargo..."
        echo "This may take a while..."
        cargo build --release
        echo ""
        echo "✓ Build complete"
        echo "Binaries in: target/release/"
        ls -lh target/release/ | grep -E "^-" | grep -v ".d$" | awk '{print $9}'
        ;;
    2)
        echo ""
        echo "Creating RPM spec..."
        
        # Check for existing spec
        if [ -f "distro-packaging/fedora/asusctl.spec" ]; then
            echo "✓ Found existing spec: distro-packaging/fedora/asusctl.spec"
            cp distro-packaging/fedora/asusctl.spec ./asusctl-zephyrus.spec
        else
            echo "Creating custom spec..."
            cat > asusctl-zephyrus.spec << 'SPEC'
Name:           asusctl-zephyrus
Version:        6.1.0
Release:        1%{?dist}
Summary:        ASUS ROG laptop control for Zephyrus OS
License:        MPL-2.0
URL:            https://gitlab.com/asus-linux/asusctl

Source0:        %{name}-%{version}.tar.gz

BuildRequires:  rust
BuildRequires:  cargo
BuildRequires:  systemd-rpm-macros
BuildRequires:  pkgconfig(gtk4)
BuildRequires:  pkgconfig(libadwaita-1)

Requires:       systemd
Requires:       gtk4
Requires:       libadwaita

%description
ASUS ROG laptop control daemon and tools for Zephyrus OS.
Includes:
- asusd: Control daemon
- asusctl: CLI tool
- rog-control-center: GUI control center
- rog-aura: RGB lighting control

%prep
%autosetup

%build
cargo build --release

%install
install -Dm755 target/release/asusd %{buildroot}%{_sbindir}/asusd
install -Dm755 target/release/asusctl %{buildroot}%{_bindir}/asusctl
install -Dm755 target/release/rog-control-center %{buildroot}%{_bindir}/rog-control-center
install -Dm755 target/release/rog-aura %{buildroot}%{_bindir}/rog-aura

# Install systemd service
install -Dm644 data/asusd.service %{buildroot}%{_unitdir}/asusd.service

# Install desktop file
install -Dm644 data/rog-control-center.desktop %{buildroot}%{_datadir}/applications/rog-control-center.desktop

%post
%systemd_post asusd.service

%preun
%systemd_preun asusd.service

%postun
%systemd_postun_with_restart asusd.service

%files
%license LICENSE
%doc README.md
%{_sbindir}/asusd
%{_bindir}/asusctl
%{_bindir}/rog-control-center
%{_bindir}/rog-aura
%{_unitdir}/asusd.service
%{_datadir}/applications/rog-control-center.desktop

%changelog
* Thu Mar 06 2025 Zephyrus OS <builder@zephyrus-os.local> - 6.1.0-1
- Custom build for Zephyrus OS
SPEC
            echo "✓ Created asusctl-zephyrus.spec"
        fi
        
        echo ""
        echo "To build RPM:"
        echo "  1. Create tarball: tar czf asusctl-zephyrus-6.1.0.tar.gz asusctl/"
        echo "  2. Build: rpmbuild -ba asusctl-zephyrus.spec"
        ;;
    3)
        echo ""
        echo "Makefile targets:"
        grep -E "^[a-zA-Z_-]+:" Makefile
        ;;
    4)
        echo "Exiting..."
        ;;
    *)
        echo "Invalid option"
        ;;
esac

echo ""
echo "Setup complete!"
echo "Source copied to: $WORK_DIR/asusctl"
