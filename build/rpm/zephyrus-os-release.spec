Name:           zephyrus-os-release
Version:        41
Release:        1%{?dist}
Summary:        Zephyrus OS release files and repository information
License:        MIT
URL:            https://zephyrus-os.org

Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch

Provides:       fedora-release = %{version}
Provides:       fedora-release-common = %{version}
Provides:       fedora-release-silverblue = %{version}
Provides:       redhat-release = %{version}
Provides:       system-release = %{version}
Provides:       system-release(releasever) = %{version}

Conflicts:      fedora-release
Conflicts:      fedora-release-common
Conflicts:      generic-release
Conflicts:      bazzite

%description
This package provides the Zephyrus OS release files including:
- OS identification and release information
- Default repository configuration
- Zephyrus OS branding and logos
- Welcome messages and issue files

%prep
%autosetup

%build
# Nothing to build

%install
# Create directories
mkdir -p %{buildroot}/etc
mkdir -p %{buildroot}/usr/lib
mkdir -p %{buildroot}/usr/share/zephyrus-os
mkdir -p %{buildroot}/usr/share/doc/zephyrus-os-release
mkdir -p %{buildroot}/etc/yum.repos.d

# Install os-release files
cat > %{buildroot}/usr/lib/os-release << 'EOF'
NAME="Zephyrus OS"
VERSION="41 (ROG Edition)"
ID=zephyrus-os
ID_LIKE=fedora
VERSION_ID=41
VERSION_CODENAME="Crimson"
PLATFORM_ID="platform:zephyrus-os-41"
PRETTY_NAME="Zephyrus OS 41 (ROG Edition)"
ANSI_COLOR="0;31"
LOGO=zephyrus-os-logo
CPE_NAME="cpe:/o:zephyrus-os:zephyrus-os:41"
HOME_URL="https://zephyrus-os.org"
DOCUMENTATION_URL="https://docs.zephyrus-os.org"
SUPPORT_URL="https://support.zephyrus-os.org"
BUG_REPORT_URL="https://issues.zephyrus-os.org"
PRIVACY_POLICY_URL="https://zephyrus-os.org/privacy"
ZEPHYRUS_OS_RELEASE=41
ZEPHYRUS_OS_EDITION=ROG
ZEPHYRUS_OS_VARIANT=Crimson
EOF

ln -s ../usr/lib/os-release %{buildroot}/etc/os-release

# Create release files
echo "Zephyrus OS release 41 (ROG Edition)" > %{buildroot}/etc/zephyrus-os-release
echo "41" > %{buildroot}/etc/zephyrus-os-version
echo "ROG" > %{buildroot}/etc/zephyrus-os-variant
echo "Crimson" > %{buildroot}/etc/zephyrus-os-theme

# Create issue and motd
cat > %{buildroot}/etc/issue << 'EOF'

███████╗███████╗██████╗ ██╗  ██╗██╗   ██╗██████╗ ██╗   ██╗███████╗     ██████╗ ███████╗
╚══███╔╝██╔════╝██╔══██╗██║  ██║██║   ██║██╔══██╗██║   ██║██╔════╝    ██╔═══██╗██╔════╝
  ███╔╝ █████╗  ██████╔╝███████║██║   ██║██████╔╝██║   ██║███████╗    ██║   ██║███████╗
 ███╔╝  ██╔══╝  ██╔═══╝ ██╔══██║██║   ██║██╔══██╗██║   ██║╚════██║    ██║   ██║╚════██║
███████╗███████╗██║     ██║  ██║╚██████╔╝██║  ██║╚██████╔╝███████║    ╚██████╔╝███████║
╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚══════╝

Welcome to Zephyrus OS - The Ultimate ROG Linux Experience

\l

EOF

cat > %{buildroot}/etc/motd << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                    Welcome to Zephyrus OS                      ║
║                                                                ║
║     The Ultimate Linux Distribution for ASUS ROG Laptops       ║
║                                                                ║
║         Optimized • Customized • Gaming Ready                  ║
╚════════════════════════════════════════════════════════════════╝
EOF

# Create Zephyrus OS directories
mkdir -p %{buildroot}/usr/share/zephyrus-os
echo "ZEPHYRUS_OS_41_ROG_CRIMSON" > %{buildroot}/usr/share/zephyrus-os/version

# Install documentation
cat > %{buildroot}/usr/share/doc/zephyrus-os-release/README << 'EOF'
Zephyrus OS
===========

The ultimate Linux distribution for ASUS ROG laptops.

Features:
- Custom ROG Control Center
- Optimized kernel for ROG hardware
- Custom GNOME Shell without screen lock toggle
- Zephyrus Crimson theme
- Gaming performance optimizations

Version: 41 (ROG Edition)
Theme: Crimson
EOF

%files
%license LICENSE
%doc README
/usr/lib/os-release
/etc/os-release
/etc/zephyrus-os-release
/etc/zephyrus-os-version
/etc/zephyrus-os-variant
/etc/zephyrus-os-theme
/etc/issue
/etc/motd
/usr/share/zephyrus-os/

%changelog
* Thu Mar 06 2025 Zephyrus OS Builder <builder@zephyrus-os.org> - 41-1
- Initial Zephyrus OS release
- Based on Fedora Silverblue 41
- Custom ROG-focused distribution
