#!/bin/bash
# Package your custom ROG Control Center and keyboard controls as RPMs
# This makes them distributable with your OS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$HOME/zephyrus-os-build/custom-packages"
RPMBUILD_DIR="$HOME/rpmbuild"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PACKAGE CUSTOM SOFTWARE FOR ZEPHYRUS OS                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# ============================================================================
# ROG CONTROL CENTER PACKAGE
# ============================================================================

echo "═══════════════════════════════════════════════════════════"
echo "PACKAGING: ROG Control Center"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create spec file for ROG Control Center
cat > rog-control-center.spec << 'ROG_SPEC'
Name:           rog-control-center
Version:        1.0.0
Release:        1%{?dist}
Summary:        ASUS ROG Control Center for Zephyrus OS
License:        GPLv2+
URL:            https://zephyrus-os.local

Source0:        %{name}-%{version}.tar.gz

BuildRequires:  meson
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  gtk4-devel
BuildRequires:  libadwaita-devel
BuildRequires:  asusctl-devel

Requires:       asusctl
Requires:       supergfxctl
Requires:       gtk4
Requires:       libadwaita

%description
Custom ROG Control Center for Zephyrus OS.
Provides control over ASUS ROG laptop features including:
- Keyboard RGB lighting
- Fan curves
- Performance modes
- AniMe Matrix display (if supported)

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install

# Install desktop entry
mkdir -p %{buildroot}%{_datadir}/applications
cat > %{buildroot}%{_datadir}/applications/rog-control-center.desktop << 'EOF'
[Desktop Entry]
Name=ROG Control Center
Comment=Control your ROG laptop
Exec=rog-control-center
Icon=rog-control-center
Type=Application
Categories=System;Settings;
EOF

# Install icon (placeholder - replace with actual icon)
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/scalable/apps
touch %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/rog-control-center.svg

%files
%license LICENSE
%doc README.md
%{_bindir}/rog-control-center
%{_datadir}/applications/rog-control-center.desktop
%{_datadir}/icons/hicolor/*/apps/rog-control-center.*

%changelog
* Thu Mar 06 2025 Zephyrus OS Builder <builder@zephyrus-os.local> - 1.0.0-1
- Initial package for Zephyrus OS
ROG_SPEC

echo "✓ Created rog-control-center.spec"

# Create tarball structure (adjust for your actual source)
mkdir -p rog-control-center-1.0.0
cat > rog-control-center-1.0.0/README.md << 'EOF'
# ROG Control Center

Custom control center for ASUS ROG laptops on Zephyrus OS.

## Building

meson setup build
meson compile -C build
sudo meson install -C build
EOF

touch rog-control-center-1.0.0/LICENSE
tar czf rog-control-center-1.0.0.tar.gz rog-control-center-1.0.0/

echo "✓ Created source tarball (placeholder - replace with actual source)"

# ============================================================================
# KEYBOARD BACKLIGHT CONTROL PACKAGE
# ============================================================================

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "PACKAGING: Keyboard Backlight Control"
echo "═══════════════════════════════════════════════════════════"
echo ""

cat > zephyrus-keyboard-control.spec << 'KEYBOARD_SPEC'
Name:           zephyrus-keyboard-control
Version:        1.0.0
Release:        1%{?dist}
Summary:        Zephyrus OS Keyboard Backlight and RGB Control
License:        GPLv2+
URL:            https://zephyrus-os.local

Source0:        %{name}-%{version}.tar.gz

BuildRequires:  systemd-rpm-macros
BuildRequires:  gcc
BuildRequires:  make

Requires:       asusctl
Requires:       systemd

%description
Keyboard backlight and RGB control daemon for Zephyrus OS.
Provides custom keyboard lighting profiles and brightness control.

%prep
%autosetup

%build
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

# Install systemd service
mkdir -p %{buildroot}%{_unitdir}
cat > %{buildroot}%{_unitdir}/zephyrus-keyboard.service << 'EOF'
[Unit]
Description=Zephyrus Keyboard Backlight Control
After=asusctl.service
Wants=asusctl.service

[Service]
Type=simple
ExecStart=/usr/bin/zephyrus-keyboard-daemon
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Install default config
mkdir -p %{buildroot}%{_sysconfdir}/zephyrus
cat > %{buildroot}%{_sysconfdir}/zephyrus/keyboard.conf << 'EOF'
# Zephyrus OS Keyboard Configuration
# Brightness levels (0-3)
brightness=3

# RGB Mode (static, breathe, cycle, etc)
mode=static

# RGB Color (RRGGBB)
color=ff0033

# Per-key customization (if supported)
[profile:default]
keys=all
color=ff0033
brightness=3
EOF

%post
%systemd_post zephyrus-keyboard.service

%preun
%systemd_preun zephyrus-keyboard.service

%postun
%systemd_postun_with_restart zephyrus-keyboard.service

%files
%license LICENSE
%doc README.md
%config(noreplace) %{_sysconfdir}/zephyrus/keyboard.conf
%{_bindir}/zephyrus-keyboard-daemon
%{_bindir}/zephyrus-keyboard-control
%{_unitdir}/zephyrus-keyboard.service

%changelog
* Thu Mar 06 2025 Zephyrus OS Builder <builder@zephyrus-os.local> - 1.0.0-1
- Initial package for Zephyrus OS
KEYBOARD_SPEC

echo "✓ Created zephyrus-keyboard-control.spec"

# Create tarball structure
mkdir -p zephyrus-keyboard-control-1.0.0
cat > zephyrus-keyboard-control-1.0.0/README.md << 'EOF'
# Zephyrus Keyboard Control

Keyboard backlight and RGB control for Zephyrus OS.

## Usage

zephyrus-keyboard-control --brightness 3
zephyrus-keyboard-control --color ff0033
zephyrus-keyboard-control --mode static

## Service

sudo systemctl enable --now zephyrus-keyboard.service
EOF

touch zephyrus-keyboard-control-1.0.0/LICENSE
cat > zephyrus-keyboard-control-1.0.0/Makefile << 'EOF'
PREFIX=/usr
BINDIR=$(PREFIX)/bin

all:
	@echo "Building keyboard control..."
	# Add your build commands here

touch zephyrus-keyboard-daemon zephyrus-keyboard-control

install:
	install -Dm755 zephyrus-keyboard-daemon $(DESTDIR)$(BINDIR)/zephyrus-keyboard-daemon
	install -Dm755 zephyrus-keyboard-control $(DESTDIR)$(BINDIR)/zephyrus-keyboard-control
EOF

tar czf zephyrus-keyboard-control-1.0.0.tar.gz zephyrus-keyboard-control-1.0.0/

echo "✓ Created source tarball (placeholder - replace with actual source)"

# ============================================================================
# BUILD INSTRUCTIONS
# ============================================================================

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "BUILD INSTRUCTIONS"
echo "═══════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'
To build these packages:

1. Replace placeholder sources with your actual code:
   - rog-control-center-1.0.0/  ← Your ROG Control Center source
   - zephyrus-keyboard-control-1.0.0/  ← Your keyboard control source

2. Build the RPMs:

   # In a toolbox or build container:
   toolbox create build-env
   toolbox run -c build-env
   
   # Install build dependencies
   sudo dnf install -y rpm-build rpmdevtools
   
   # Build packages
   rpmbuild -ba rog-control-center.spec
   rpmbuild -ba zephyrus-keyboard-control.spec

3. The RPMs will be in ~/rpmbuild/RPMS/x86_64/

4. Add to your OSTree compose by copying them to your repo and
   adding to the treefile.

INSTRUCTIONS

# Create a build script
cat > build-all.sh << 'SCRIPT'
#!/bin/bash
# Build all custom packages

set -e

# Check if in toolbox
if [ ! -f /run/.containerenv ] && [ ! -f /.dockerenv ]; then
    echo "Not in container - using toolbox..."
    if ! toolbox list | grep -q "build-env"; then
        toolbox create build-env
    fi
    toolbox run -c build-env ./build-all.sh
    exit 0
fi

# Install dependencies
sudo dnf install -y rpm-build rpmdevtools make gcc

# Setup rpmbuild
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Copy sources
cp *.tar.gz ~/rpmbuild/SOURCES/
cp *.spec ~/rpmbuild/SPECS/

# Build
cd ~/rpmbuild/SPECS
rpmbuild -ba rog-control-center.spec
rpmbuild -ba zephyrus-keyboard-control.spec

echo ""
echo "✓ Build complete!"
echo "RPMs in: ~/rpmbuild/RPMS/x86_64/"
ls -lh ~/rpmbuild/RPMS/x86_64/
SCRIPT

chmod +x build-all.sh

echo ""
echo "✓ Created build-all.sh"
echo ""
echo "Work directory: $WORK_DIR"
echo ""
echo "Next steps:"
echo "1. Replace placeholder source directories with your actual code"
echo "2. Run: ./build-all.sh"
echo "3. Copy resulting RPMs to your OSTree repo"
echo ""
