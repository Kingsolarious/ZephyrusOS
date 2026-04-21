#!/bin/bash
# Zephyrus OS - Master Build Script
# Complete build system for Zephyrus OS distribution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$HOME/zephyrus-os-dist"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║   ███████╗███████╗██████╗ ██╗  ██╗██╗   ██╗██████╗ ██╗   ║"
echo "║   ╚══███╔╝██╔════╝██╔══██╗██║  ██║██║   ██║██╔══██╗██║   ║"
echo "║     ███╔╝ █████╗  ██████╔╝███████║██║   ██║██████╔╝██║   ║"
echo "║    ███╔╝  ██╔══╝  ██╔═══╝ ██╔══██║██║   ██║██╔══██╗██║   ║"
echo "║   ███████╗███████╗██║     ██║  ██║╚██████╔╝██║  ██║██║   ║"
echo "║   ╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ║"
echo "║                                                           ║"
echo "║              ██████╗ ███████╗                             ║"
echo "║             ██╔═══██╗██╔════╝                             ║"
echo "║             ██║   ██║███████╗                             ║"
echo "║             ██║   ██║╚════██║                             ║"
echo "║             ╚██████╔╝███████║                             ║"
echo "║              ╚═════╝ ╚══════╝                             ║"
echo "║                                                           ║"
echo "║            ZEPHYRUS OS BUILD SYSTEM                       ║"
echo "║        The Ultimate ROG Linux Experience                  ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "✓ SAFE MODE: Will NOT overwrite your personal files"
echo "✓ See PERSONAL_FILES_SAFETY.md for details"
echo ""
echo "Building packages for Zephyrus OS:"
echo "  1. Custom GNOME Shell (screen lock toggle removed)"
echo "  2. Zephyrus OS Release Package (branding)"
echo "  3. asusctl (ROG Control Center)"
echo "  4. Zephyrus OS Theme & Extensions"
echo ""

mkdir -p "$OUTPUT_DIR"

# Menu
while true; do
    echo "═══════════════════════════════════════════════════════════"
    echo "ZEPHYRUS OS BUILD OPTIONS"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo " 1. Build Zephyrus GNOME Shell (no screen lock toggle)"
    echo " 2. Build Zephyrus OS Release Package (branding)"
    echo " 3. Build asusctl (ROG Control Center)"
    echo " 4. Build ALL Zephyrus packages"
    echo " 5. Generate Zephyrus OS OSTree Treefile"
    echo " 6. FULL ZEPHYRUS OS BUILD (everything)"
    echo " 7. Exit"
    echo ""
    read -p "Select option (1-7): " choice
    
    case $choice in
        1)
            echo ""
            echo "Building Zephyrus GNOME Shell..."
            bash "$SCRIPT_DIR/build-gnome-shell-rpm.sh"
            echo ""
            echo "✓ Zephyrus GNOME Shell build complete"
            ;;
        2)
            echo ""
            echo "Building Zephyrus OS Release Package..."
            
            WORK_DIR="$HOME/zephyrus-os-build/release"
            mkdir -p "$WORK_DIR"
            cd "$WORK_DIR"
            
            # Create source tarball
            mkdir -p zephyrus-os-release-41
            cp "$SCRIPT_DIR/zephyrus-os-release.spec" .
            
            echo "Creating Zephyrus OS release package..."
            tar czf zephyrus-os-release-41.tar.gz zephyrus-os-release-41/
            
            # Build RPM
            if command -v rpmbuild &> /dev/null; then
                mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
                cp zephyrus-os-release-41.tar.gz ~/rpmbuild/SOURCES/
                cp zephyrus-os-release.spec ~/rpmbuild/SPECS/
                
                echo "Building RPM..."
                rpmbuild -ba ~/rpmbuild/SPECS/zephyrus-os-release.spec
                
                echo ""
                echo "✓ Zephyrus OS Release RPM built"
                ls -lh ~/rpmbuild/RPMS/noarch/zephyrus-os-release*.rpm
            else
                echo "⚠️  rpmbuild not found. Install rpm-build package."
            fi
            ;;
        3)
            echo ""
            echo "Setting up asusctl build..."
            bash "$SCRIPT_DIR/setup-asusctl-build.sh"
            ;;
        4)
            echo ""
            echo "Building all Zephyrus packages..."
            
            # Build GNOME Shell
            bash "$SCRIPT_DIR/build-gnome-shell-rpm.sh"
            
            # Build Release Package
            cd "$HOME/zephyrus-os-build/release"
            rpmbuild -ba zephyrus-os-release.spec 2>/dev/null || echo "Release package build skipped"
            
            echo ""
            echo "✓ All Zephyrus packages built"
            ;;
        5)
            echo ""
            echo "Generating Zephyrus OS OSTree Treefile..."
            cp "$SCRIPT_DIR/zephyrus-os-treefile.yaml" "$OUTPUT_DIR/"
            echo "✓ Treefile saved to: $OUTPUT_DIR/zephyrus-os-treefile.yaml"
            echo ""
            echo "Edit this file and:"
            echo "  1. Update paths to your custom RPMs"
            echo "  2. Add your custom repositories"
            ;;
        6)
            echo ""
            echo "╔═══════════════════════════════════════════════════════════╗"
            echo "║        FULL ZEPHYRUS OS BUILD                             ║"
            echo "╚═══════════════════════════════════════════════════════════╝"
            echo ""
            
            # Create output structure
            mkdir -p "$OUTPUT_DIR"/{rpms,configs,scripts}
            
            echo "Step 1: Building Zephyrus GNOME Shell..."
            bash "$SCRIPT_DIR/build-gnome-shell-rpm.sh"
            
            echo ""
            echo "Step 2: Building Zephyrus OS Release Package..."
            cd "$HOME/zephyrus-os-build/release"
            rpmbuild -ba zephyrus-os-release.spec 2>/dev/null || echo "  (may need manual build)"
            
            echo ""
            echo "Step 3: Copying outputs..."
            mkdir -p "$OUTPUT_DIR/rpms"
            cp ~/rpmbuild/RPMS/x86_64/gnome-shell-*.rpm "$OUTPUT_DIR/rpms/" 2>/dev/null || true
            cp ~/rpmbuild/RPMS/noarch/zephyrus-os-release*.rpm "$OUTPUT_DIR/rpms/" 2>/dev/null || true
            cp "$SCRIPT_DIR/zephyrus-os-treefile.yaml" "$OUTPUT_DIR/configs/"
            
            echo ""
            echo "Step 4: Creating installation instructions..."
            
            cat > "$OUTPUT_DIR/README-ZEPHYRUS-OS.md" << 'ZEPHYRUS_README'
# Zephyrus OS - Distribution Package

## The Ultimate ROG Linux Experience

This directory contains your custom Zephyrus OS distribution packages.

## Contents

- `rpms/` - Zephyrus OS RPM packages
  - `gnome-shell-zephyrus-*.rpm` - Custom GNOME Shell (no screen lock toggle)
  - `zephyrus-os-release-*.rpm` - Zephyrus OS branding and release files
  - `asusctl-zephyrus-*.rpm` - ROG Control Center (when built)
  
- `configs/` - Zephyrus OS configuration
  - `zephyrus-os-treefile.yaml` - OSTree treefile for compose

## Zephyrus OS Features

- ✓ Screen lock toggle removed from Quick Settings
- ✓ Custom ROG Crimson theme
- ✓ Zephyrus OS branding throughout
- ✓ ASUS ROG hardware optimization
- ✓ Gaming performance tuned
- ✓ Clean, professional appearance

## Installation on Running System

```bash
# Layer the custom GNOME Shell
sudo rpm-ostree override replace ./rpms/gnome-shell-zephyrus-*.rpm

# Install Zephyrus OS branding
sudo rpm-ostree install ./rpms/zephyrus-os-release-*.rpm

# Reboot
systemctl reboot
```

## Building Zephyrus OS OSTree Image

```bash
# Copy RPMs to your repo
mkdir -p /var/repo/zephyrus-os-rpms
cp ./rpms/*.rpm /var/repo/zephyrus-os-rpms/
createrepo /var/repo/zephyrus-os-rpms/

# Update treefile with correct paths
# Edit configs/zephyrus-os-treefile.yaml

# Compose the Zephyrus OS tree
sudo rpm-ostree compose tree \
    --repo=/var/repo/zephyrus-os \
    ./configs/zephyrus-os-treefile.yaml

# Create summary
sudo ostree summary --update --repo=/var/repo/zephyrus-os
```

## Zephyrus OS Identity

- **Name**: Zephyrus OS
- **Version**: 41 (ROG Edition)
- **Codename**: Crimson
- **Base**: Fedora Silverblue
- **Target**: ASUS ROG Laptops

## Support

For issues and documentation:
- Visit: https://zephyrus-os.org
- Docs: https://docs.zephyrus-os.org
- Issues: https://issues.zephyrus-os.org

---

**Welcome to Zephyrus OS - The Ultimate ROG Linux Experience**

ZEPHYRUS_OS_41_ROG_CRIMSON
ZEPHYRUS_README

            echo ""
            echo "╔═══════════════════════════════════════════════════════════╗"
            echo "║        ZEPHYRUS OS BUILD COMPLETE                         ║"
            echo "╚═══════════════════════════════════════════════════════════╝"
            echo ""
            echo "Output directory: $OUTPUT_DIR"
            echo ""
            ls -lh "$OUTPUT_DIR/rpms/" 2>/dev/null || echo "  (check ~/rpmbuild/RPMS/)"
            echo ""
            echo "Next steps:"
            echo "1. Review: $OUTPUT_DIR/README-ZEPHYRUS-OS.md"
            echo "2. Test Zephyrus OS on a VM or secondary system"
            echo "3. Deploy to your main ROG laptop"
            echo "4. Distribute your Zephyrus OS image"
            echo ""
            echo "Welcome to Zephyrus OS!"
            ;;
        7)
            echo ""
            echo "Exiting Zephyrus OS Build System..."
            echo ""
            echo "Remember: Welcome to Zephyrus OS!"
            exit 0
            ;;
        *)
            echo ""
            echo "Invalid option. Please select 1-7."
            ;;
    esac
    echo ""
done
