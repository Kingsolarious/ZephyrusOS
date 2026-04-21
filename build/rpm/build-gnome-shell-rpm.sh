#!/bin/bash
# Build custom GNOME Shell RPM for Zephyrus OS
# This creates a distributable RPM with the screen lock toggle removed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$HOME/zephyrus-os-build"
RPMBUILD_DIR="$HOME/rpmbuild"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ZEPHYRUS OS - GNOME SHELL BUILDER                        ║"
echo "║  Custom GNOME Shell for Zephyrus OS                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "This will build a custom GNOME Shell RPM with:"
echo "  ✓ Screen lock toggle removed"
echo "  ✓ Screen recording toggle removed"
echo "  ✓ Zephyrus OS branding"
echo ""

# Check for Fedora/RHEL build tools
if ! command -v rpmbuild &> /dev/null; then
    echo "Installing RPM build tools..."
    sudo rpm-ostree install -y rpm-build rpmdevtools dnf-plugins-core || {
        echo "⚠️  rpm-ostree install failed, trying dnf..."
        sudo dnf install -y rpm-build rpmdevtools dnf-plugins-core
    }
fi

# Setup build directories
echo "Setting up build directories..."
mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
mkdir -p "$WORK_DIR"

# Get GNOME Shell version
GNOME_VERSION=$(gnome-shell --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
echo "Building for GNOME Shell $GNOME_VERSION"
echo ""

cd "$WORK_DIR"

# ============================================================================
# STEP 1: Download GNOME Shell Source RPM
# ============================================================================
echo "═══════════════════════════════════════════════════════════"
echo "STEP 1: Downloading GNOME Shell Source"
echo "═══════════════════════════════════════════════════════════"

if [ ! -f "gnome-shell-${GNOME_VERSION}*.src.rpm" ]; then
    echo "Downloading source RPM..."
    dnf download --source gnome-shell || {
        echo "Trying to find source package..."
        FEDORA_VERSION=$(rpm -E %fedora 2>/dev/null || echo "41")
        curl -L -O "https://kojipkgs.fedoraproject.org/packages/gnome-shell/${GNOME_VERSION}/1.fc${FEDORA_VERSION}/src/gnome-shell-${GNOME_VERSION}-1.fc${FEDORA_VERSION}.src.rpm" || {
            echo "❌ Could not download source RPM automatically"
            echo "   Please download manually and place in: $WORK_DIR"
            exit 1
        }
    }
fi

SRC_RPM=$(ls -t gnome-shell-*.src.rpm 2>/dev/null | head -1)
echo "Source RPM: $SRC_RPM"

# ============================================================================
# STEP 2: Extract Source RPM
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 2: Extracting Source RPM"
echo "═══════════════════════════════════════════════════════════"

rpm2cpio "$SRC_RPM" | cpio -idmv

# Move spec file
mv gnome-shell.spec "$RPMBUILD_DIR/SPECS/" 2>/dev/null || true

# Move sources
mv *.tar.* *.patch "$RPMBUILD_DIR/SOURCES/" 2>/dev/null || true

# ============================================================================
# STEP 3: Apply Zephyrus Patch
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 3: Applying Zephyrus OS Patch"
echo "═══════════════════════════════════════════════════════════"

# Copy our patch
cp "$SCRIPT_DIR/patches/zephyrus-remove-screen-lock-toggle.patch" "$RPMBUILD_DIR/SOURCES/"

# Modify the spec file to include our patch
SPEC_FILE="$RPMBUILD_DIR/SPECS/gnome-shell.spec"

# Check if already patched
if ! grep -q "zephyrus-remove-screen-lock-toggle.patch" "$SPEC_FILE"; then
    echo "Adding Zephyrus patch to spec file..."
    
    # Add Patch0 line after Source0
    sed -i '/^Source0:.*/a Patch0:         zephyrus-remove-screen-lock-toggle.patch' "$SPEC_FILE"
    
    # Add %patch0 macro in %prep section (after %autosetup or %setup)
    sed -i '/^%autosetup.*/a %patch0 -p1' "$SPEC_FILE"
    
    # Update release to indicate Zephyrus build
    sed -i "s/^Release:.*%{?dist}/Release:        1.zephyrus%{?dist}/" "$SPEC_FILE"
    
    echo "✓ Spec file patched"
else
    echo "✓ Spec file already patched"
fi

# ============================================================================
# STEP 4: Install Build Dependencies
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 4: Installing Build Dependencies"
echo "═══════════════════════════════════════════════════════════"

# In toolbox or on regular Fedora
if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
    echo "Running in container - installing deps..."
    sudo dnf builddep -y "$SPEC_FILE" || {
        echo "⚠️  Some dependencies might be missing, continuing..."
    }
else
    # On OSTree system, use toolbox
    echo "OSTree system detected - using toolbox..."
    if ! toolbox list | grep -q "zephyrus-build"; then
        toolbox create zephyrus-build
    fi
    
    echo "Installing build dependencies in toolbox..."
    toolbox run -c zephyrus-build sudo dnf builddep -y "$SPEC_FILE" || {
        echo "⚠️  Some dependencies might be missing"
    }
fi

# ============================================================================
# STEP 5: Build the RPM
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "STEP 5: Building RPM"
echo "═══════════════════════════════════════════════════════════"

# Build in toolbox if on OSTree
if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
    rpmbuild -ba "$SPEC_FILE" --define "_topdir $RPMBUILD_DIR"
else
    toolbox run -c zephyrus-build rpmbuild -ba "$SPEC_FILE" --define "_topdir $RPMBUILD_DIR"
fi

echo ""
echo "✓ Build complete!"
echo ""

# ============================================================================
# STEP 6: Show Results
# ============================================================================
echo "═══════════════════════════════════════════════════════════"
echo "BUILD RESULTS"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "RPMs built in: $RPMBUILD_DIR/RPMS/x86_64/"
echo ""
ls -lh "$RPMBUILD_DIR/RPMS/x86_64/"/*.rpm 2>/dev/null | grep gnome-shell || echo "  (check $RPMBUILD_DIR for output)"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "NEXT STEPS - Add to Your OSTree Compose"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Copy the RPM to your OSTree repo:"
echo "   cp $RPMBUILD_DIR/RPMS/x86_64/gnome-shell-*.rpm /path/to/your/ostree/repo/"
echo ""
echo "2. Add to your treefile (example):"
echo ""
cat << 'TREEFILE'
   # In your treefile.yaml:
   packages:
     # ... other packages ...
     - gnome-shell-49.4-1.zephyrus.fc41.x86_64  # Your custom build
   
   # OR use override:
   override-replace:
     - gnome-shell-49.4-1.zephyrus.fc41.x86_64
TREEFILE

echo ""
echo "3. Build your OSTree commit:"
echo "   rpm-ostree compose tree --repo=/path/to/repo your-treefile.yaml"
echo ""
echo "4. The custom GNOME Shell will be in your distro image!"
echo ""

# Create a package manifest for the user
cat > "$WORK_DIR/zephyrus-packages.txt" << EOF
ZEPHYRUS OS CUSTOM PACKAGES
============================

GNOME Shell Custom Build:
$RPMBUILD_DIR/RPMS/x86_64/gnome-shell-${GNOME_VERSION}*.rpm

This RPM contains:
- Screen lock toggle removed from Quick Settings
- Screen recording toggle removed
- Zephyrus OS custom branding

To install on a running system:
  sudo rpm-ostree override replace $RPMBUILD_DIR/RPMS/x86_64/gnome-shell-*.rpm

To include in your OSTree compose:
  Add the RPM to your treefile packages or override-replace section

EOF

echo "Package manifest saved to: $WORK_DIR/zephyrus-packages.txt"
echo ""
