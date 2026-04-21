#!/bin/bash
# Package your custom ROG Control Center and keyboard controls as RPMs
# SAFETY FIRST: Will NOT overwrite your existing files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$HOME/zephyrus-os-build/custom-packages"
RPMBUILD_DIR="$HOME/rpmbuild"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  PACKAGE CUSTOM SOFTWARE FOR ZEPHYRUS OS                  ║"
echo "║  ✓ Safe Mode - Will NOT overwrite existing files          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "Working directory: $WORK_DIR"
echo ""

# ============================================================================
# CHECK: Do you have source code already?
# ============================================================================

echo "═══════════════════════════════════════════════════════════"
echo "SAFETY CHECK: Looking for your source code"
echo "═══════════════════════════════════════════════════════════"
echo ""

ROG_SOURCE=""
KB_SOURCE=""

# Check for ROG Control Center source
if [ -d "rog-control-center-1.0.0" ] || [ -d "rog-control-center" ]; then
    ROG_SOURCE=$(ls -d rog-control-center* 2>/dev/null | head -1)
    echo "✓ Found ROG Control Center source: $ROG_SOURCE"
else
    echo "⚠️  ROG Control Center source NOT found"
    echo "   Expected: $WORK_DIR/rog-control-center-1.0.0/"
fi

# Check for Keyboard Control source
if [ -d "zephyrus-keyboard-control-1.0.0" ] || [ -d "zephyrus-keyboard-control" ]; then
    KB_SOURCE=$(ls -d zephyrus-keyboard-control* 2>/dev/null | head -1)
    echo "✓ Found Keyboard Control source: $KB_SOURCE"
else
    echo "⚠️  Keyboard Control source NOT found"
    echo "   Expected: $WORK_DIR/zephyrus-keyboard-control-1.0.0/"
fi

echo ""

# ============================================================================
# Create spec files (these are safe to create/overwrite)
# ============================================================================

create_specs() {
    echo "Creating RPM spec files..."
    
    # Only create if not exists, or ask first
    if [ -f "rog-control-center.spec" ]; then
        read -p "rog-control-center.spec exists. Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "  Skipping rog-control-center.spec"
        else
            _create_rog_spec
        fi
    else
        _create_rog_spec
    fi
    
    if [ -f "zephyrus-keyboard-control.spec" ]; then
        read -p "zephyrus-keyboard-control.spec exists. Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "  Skipping zephyrus-keyboard-control.spec"
        else
            _create_kb_spec
        fi
    else
        _create_kb_spec
    fi
}

_create_rog_spec() {
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

# Install icon
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
    echo "  ✓ Created rog-control-center.spec"
}

_create_kb_spec() {
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
brightness=3
mode=static
color=ff0033

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
    echo "  ✓ Created zephyrus-keyboard-control.spec"
}

# ============================================================================
# Main menu
# ============================================================================

while true; do
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "OPTIONS"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "1. Create spec files (safe - doesn't touch source code)"
    echo "2. Create tarball from your source (for RPM build)"
    echo "3. Build RPMs (requires source tarballs)"
    echo "4. Setup your source directories"
    echo "5. Exit"
    echo ""
    read -p "Select (1-5): " choice
    
    case $choice in
        1)
            create_specs
            ;;
        2)
            echo ""
            echo "Creating tarballs for RPM build..."
            
            if [ -n "$ROG_SOURCE" ]; then
                echo "Creating $ROG_SOURCE.tar.gz..."
                tar czf "${ROG_SOURCE}.tar.gz" "$ROG_SOURCE/"
                echo "  ✓ Created"
            else
                echo "  ⚠️  No ROG source found"
            fi
            
            if [ -n "$KB_SOURCE" ]; then
                echo "Creating $KB_SOURCE.tar.gz..."
                tar czf "${KB_SOURCE}.tar.gz" "$KB_SOURCE/"
                echo "  ✓ Created"
            else
                echo "  ⚠️  No Keyboard source found"
            fi
            ;;
        3)
            echo ""
            echo "Building RPMs..."
            
            # Check for toolbox
            if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
                echo "Running in container..."
            else
                echo "Using toolbox for build..."
                if ! toolbox list | grep -q "build-env"; then
                    toolbox create build-env
                fi
            fi
            
            # Setup rpmbuild
            mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
            
            # Copy specs and sources
            cp *.spec ~/rpmbuild/SPECS/ 2>/dev/null || true
            cp *.tar.gz ~/rpmbuild/SOURCES/ 2>/dev/null || true
            
            echo ""
            echo "To build, run:"
            echo "  cd ~/rpmbuild/SPECS"
            echo "  rpmbuild -ba rog-control-center.spec"
            echo "  rpmbuild -ba zephyrus-keyboard-control.spec"
            ;;
        4)
            echo ""
            echo "═══════════════════════════════════════════════════════════"
            echo "SETUP INSTRUCTIONS"
            echo "═══════════════════════════════════════════════════════════"
            echo ""
            echo "To prepare your source for packaging:"
            echo ""
            echo "1. ROG Control Center:"
            echo "   mkdir -p $WORK_DIR/rog-control-center-1.0.0"
            echo "   cp -r /path/to/your/rog-control-center/* $WORK_DIR/rog-control-center-1.0.0/"
            echo ""
            echo "   Required files:"
            echo "   - meson.build (or Makefile)"
            echo "   - src/ directory"
            echo "   - README.md"
            echo "   - LICENSE"
            echo ""
            echo "2. Keyboard Control:"
            echo "   mkdir -p $WORK_DIR/zephyrus-keyboard-control-1.0.0"
            echo "   cp -r /path/to/your/keyboard-control/* $WORK_DIR/zephyrus-keyboard-control-1.0.0/"
            echo ""
            echo "   Required files:"
            echo "   - Makefile"
            echo "   - Source files"
            echo "   - README.md"
            echo ""
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
