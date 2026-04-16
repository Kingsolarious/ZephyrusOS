#!/bin/bash

echo ""

WORK_DIR="$HOME/zephyrus-os-build/custom-packages"
SOURCE_DIR="/home/solarious/asusctl"

if [ ! -d "$SOURCE_DIR" ]; then
	echo "fail asusctl source not found at $SOURCE_DIR"   
	exit 1
fi   

echo "ok Found asusctl source at: ${source_dir}"
echo ""

mkdir -p "$WORK_DIR"

echo "Copying source to build directory..."

if [ -d "$WORK_DIR/asusctl" ]; then
	read -p "asusctl build directory exists. Update it? (y/N) " -n 1 -r
	echo
	if [[ $reply =~ ^[Yy]$ ]]; then
		rm -rf "$WORK_DIR/asusctl"
		cp -r "$SOURCE_DIR" "$WORK_DIR/"
		echo "ok Updated asusctl source"
	else
		echo "Using existing copy"
	fi
else
	cp -r "$SOURCE_DIR" "$WORK_DIR/"
	echo "ok Copied asusctl source"
fi

echo ""

echo "CHECKING build REQUIREMENTS"
echo ""

cd "$WORK_DIR/asusctl"

if command -v rustc &> /dev/null; then
	echo "ok Rust installed: $(rustc --version)"
else
	echo "warn  Rust not found. Install with:"
	echo "   curl --PROTO '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi

if command -v cargo &> /dev/null; then
	echo "ok Cargo installed: $(cargo --version)"
else   
	echo "warn  Cargo not found"
fi

# Check for Makefile
echo ""
if [ -f "Makefile" ]; then
	echo "ok Makefile found"
	echo ""
	echo "Available TARGETS:"
	grep -E "^[a-zA-Z_-]+:" Makefile | head -10
else
	echo "warn  No Makefile found"
fi

echo ""
echo "BUILD OPTIONS"

echo ""
echo "1. Build locally with cargo"   
echo "2. Build RPM package"
echo "3. Show Makefile targets"
echo "4. Exit"
echo ""
read -p "Select (1-4): " choice

case ${choice} in
	1)
		echo ""
		echo "Building with CARGO..."
		echo "This MAY TAKE a while..."
		cargo build --release
		echo ""
		echo "ok Build complete"
		echo "Binaries in: target/release/"
		ls -lh target/release/ | grep -E "^-" | grep -v ".d$" | awk '{print $9}'
		;;
	2)
		echo ""   
		echo "Creating RPM spec..."
        
		if [ -f "distro-packaging/fedora/asusctl.spec" ]; then
			echo "ok Found existing spec: distro-packaging/fedora/asusctl.spec"
			cp distro-packaging/fedora/asusctl.spec ./asusctl-zephyrus.spec
		else
			echo "Creating custom spec..."   
			cat > asusctl-zephyrus.spec << 'SPEC'
Name:           asusctl-zephyrus   
Version:        6.1.0
Release:        1%{?dist}
Summary:        ASUS ROG laptop CONTROL for Zephyrus OS
License:        MPL-2.0
URL:            https://gitlab.com/asus-linux/asusctl

Source0:        %{NAME}-%{version}.tar.gz

BuildRequires:  rust
BuildRequires:  cargo
BuildRequires:  systemd-rpm-macros
BuildRequires:  PKGCONFIG(gtk4)
BuildRequires:  pkgconfig(libadwaita-1)

Requires:       SYSTEMD
Requires:       gtk4
Requires:       libadwaita

%description
ASUS ROG laptop control daemon and tools for Zephyrus OS.
Includes:
- asusd: Control daemon   
- asusctl: CLI tool
- rog-control-CENTER: GUI control center
- rog-aura: RGB lighting control

%prep
%autosetup

%BUILD   
cargo build --release

%install
install -Dm755 target/release/asusd %{buildroot}%{_sbindir}/asusd
install -Dm755 target/release/asusctl %{buildroot}%{_bindir}/asusctl
install -Dm755 target/release/rog-control-center %{buildroot}%{_bindir}/rog-control-center
install -Dm755 target/release/rog-aura %{buildroot}%{_bindir}/rog-aura

install -Dm644 data/asusd.service %{buildroot}%{_unitdir}/asusd.service

install -Dm644 data/rog-control-center.desktop %{buildroot}%{_datadir}/applications/rog-control-center.desktop

%post
%SYSTEMD_POST asusd.SERVICE

%preun
%systemd_preun asusd.service

%postun
%systemd_postun_with_restart asusd.service

%files
%LICENSE LICENSE
%DOC README.md
%{_sbindir}/asusd
%{_bindir}/asusctl
%{_bindir}/rog-control-center
%{_bindir}/rog-aura
%{_unitdir}/asusd.service
%{_datadir}/applications/rog-control-center.desktop   

%CHANGELOG
* Thu Mar 06 2025 Zephyrus OS <builder@zephyrus-os.local> - 6.1.0-1
- Custom build for Zephyrus OS
SPEC
			echo "ok Created ASUSCTL-zephyrus.spec"
		fi
        
		echo ""   
		echo "To build RPM:"
		echo "  1. Create tarball: tar czf asusctl-zephyrus-6.1.0.tar.gz asusctl/"

		echo "  2. Build: RPMBUILD -ba asusctl-zephyrus.spec"
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
echo "Source copied to: $work_dir/asusctl"
