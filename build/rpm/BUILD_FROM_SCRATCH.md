# Build Zephyrus OS from Scratch (No Bazzite)

This guide walks you through building Zephyrus OS starting from pure Fedora Silverblue, completely removing Bazzite branding.

## Overview

Instead of rebasing from Bazzite, you'll:
1. Start with Fedora Silverblue 41
2. Build custom packages (GNOME Shell, ROG Control Center, etc.)
3. Create your own OSTree repo
4. Compose your own image
5. Rebase to your image

---

## Prerequisites

- A Fedora system (or VM) with ~50GB free space
- Strong internet connection
- Your custom software source code ready

---

## Step 1: Prepare Build Environment

```bash
# Install required tools
sudo rpm-ostree install -y \
    rpm-ostree \
    createrepo_c \
    ostree \
    git \
    rpm-build \
    rpmdevtools

# Create work directory
mkdir -p ~/zephyrus-build
cd ~/zephyrus-build
```

---

## Step 2: Get Fedora Silverblue Base

```bash
# Pull the base Fedora Silverblue
sudo ostree pull --repo=/var/srv/ostree/repo \
    fedora:fedora/41/x86_64/silverblue \
    2>/dev/null || \
    sudo ostree init --repo=/var/srv/ostree/repo --mode=archive-z2

# Or use a local mirror
```

---

## Step 3: Build Custom GNOME Shell

```bash
cd ~/zephyrus-build

# Get the build script
wget https://raw.githubusercontent.com/your-repo/zephyrus-os/main/distro-build/build-gnome-shell-rpm.sh

# Run the build
bash build-gnome-shell-rpm.sh

# Output will be in ~/rpmbuild/RPMS/x86_64/
```

---

## Step 4: Package Your Custom Software

### ROG Control Center

```bash
# Place your source code
mkdir -p ~/zephyrus-build/sources/rog-control-center-1.0.0
cp -r /path/to/your/rog-control-center/* ~/zephyrus-build/sources/rog-control-center-1.0.0/

# Build RPM
cd ~/zephyrus-build
cp distro-build/rog-control-center.spec .
rpmbuild -ba rog-control-center.spec
```

### Keyboard Control

```bash
# Place your source code
mkdir -p ~/zephyrus-build/sources/zephyrus-keyboard-control-1.0.0
cp -r /path/to/your/keyboard-control/* ~/zephyrus-build/sources/zephyrus-keyboard-control-1.0.0/

# Build RPM
cd ~/zephyrus-build
cp distro-build/zephyrus-keyboard-control.spec .
rpmbuild -ba zephyrus-keyboard-control.spec
```

---

## Step 5: Set Up Your OSTree Repository

```bash
# Create repo
sudo mkdir -p /var/repo/zephyrus-os
sudo ostree init --repo=/var/repo/zephyrus-os --mode=archive-z2

# Copy RPMs
sudo mkdir -p /var/repo/local-rpms
sudo cp ~/rpmbuild/RPMS/x86_64/*.rpm /var/repo/local-rpms/

# Create repo metadata
sudo createrepo /var/repo/local-rpms/

# Add local repo to config
sudo tee /etc/yum.repos.d/zephyrus-local.repo > /dev/null << 'EOF'
[zephyrus-local]
name=Zephyrus OS Local Packages
baseurl=file:///var/repo/local-rpms/
enabled=1
gpgcheck=0
EOF
```

---

## Step 6: Create Treefile

```bash
# Get the clean treefile
cp distro-build/zephyrus-os-clean.yaml ~/zephyrus-build/

# Edit to add your RPM paths
nano ~/zephyrus-build/zephyrus-os-clean.yaml

# Update the override-replace section:
# override-replace:
#   - /var/repo/local-rpms/gnome-shell-49.4-1.zephyrus.fc41.x86_64.rpm
#   - /var/repo/local-rpms/rog-control-center-1.0.0-1.fc41.x86_64.rpm
#   - /var/repo/local-rpms/zephyrus-keyboard-control-1.0.0-1.fc41.x86_64.rpm
```

---

## Step 7: Compose the Tree

```bash
cd ~/zephyrus-build

# Compose the OSTree commit
sudo rpm-ostree compose tree \
    --repo=/var/repo/zephyrus-os \
    --cachedir=/var/cache/rpm-ostree \
    ./zephyrus-os-clean.yaml

# Create summary
sudo ostree summary --update --repo=/var/repo/zephyrus-os
```

---

## Step 8: Serve the Repo (for testing)

```bash
# For local testing
sudo python3 -m http.server 80 --directory /var/repo &

# Or use a proper web server for distribution
```

---

## Step 9: Rebase Your System

On your ROG laptop:

```bash
# Add your repo as a remote
sudo ostree remote add --if-not-exists \
    zephyrus-os \
    http://your-server-ip/zephyrus-os \
    --no-gpg-verify

# Rebase to your OS
sudo rpm-ostree rebase zephyrus-os:zephyrus-os/41/x86_64/stable

# Reboot
systemctl reboot
```

---

## Step 10: Verify

After reboot:

```bash
# Check OS branding
cat /etc/os-release
# Should show: NAME="Zephyrus OS"

# Check GNOME Shell version
rpm -q gnome-shell
# Should show your custom version

# Check screen lock toggle is gone
# Open Quick Settings - should not have the toggle

# Check ROG Control Center
rog-control-center --version

# Check keyboard control
zephyrus-keyboard-control --help
```

---

## Creating an ISO (for distribution)

```bash
# Install lorax
sudo dnf install -y lorax

# Create boot ISO
sudo livemedia-creator \
    --make-iso \
    --iso-only \
    --iso-name=zephyrus-os-41.iso \
    --ks=zephyrus-os.ks \
    --repo=/var/repo/zephyrus-os \
    --volid=ZEPHYRUS-OS-41
```

---

## Automation Script

```bash
#!/bin/bash
# Full automated build

set -e

WORK_DIR="$HOME/zephyrus-build"
REPO_DIR="/var/repo/zephyrus-os"

echo "Building Zephyrus OS from scratch..."

# 1. Build GNOME Shell
cd "$WORK_DIR"
./build-gnome-shell-rpm.sh

# 2. Build custom packages
cd "$WORK_DIR/sources"
./build-all.sh

# 3. Update repo
sudo cp ~/rpmbuild/RPMS/x86_64/*.rpm /var/repo/local-rpms/
sudo createrepo /var/repo/local-rpms/

# 4. Compose tree
sudo rpm-ostree compose tree \
    --repo="$REPO_DIR" \
    --cachedir=/var/cache/rpm-ostree \
    ./zephyrus-os-clean.yaml

# 5. Update summary
sudo ostree summary --update --repo="$REPO_DIR"

echo "Build complete!"
echo "Repo: $REPO_DIR"
```

---

## Distributing Your OS

### Option 1: OSTree Remote

Host your OSTree repo on a server:

```bash
# Sync to web server
rsync -avz /var/repo/zephyrus-os/ root@your-server:/var/www/zephyrus-os/

# Users add remote and rebase
sudo ostree remote add zephyrus-os https://your-server/zephyrus-os
sudo rpm-ostree rebase zephyrus-os:zephyrus-os/41/x86_64/stable
```

### Option 2: ISO Installer

Create bootable ISO for fresh installs.

### Option 3: Container Image

```bash
# Export as container for podman/docker
sudo rpm-ostree export --container zephyrus-os:latest
```

---

## Your Custom Software

Make sure these are ready before building:

1. **ROG Control Center**
   - Source code with meson/cmake build system
   - Desktop entry file
   - Icon/theme assets

2. **Keyboard Backlight Control**
   - Daemon that runs as systemd service
   - Control CLI tool
   - Configuration file format

3. **Any other custom software**
   - Properly packaged as RPM or flatpak

---

## Next Steps

1. ✅ Test on VM first
2. ✅ Test on spare laptop
3. ✅ Test on your main ROG laptop
4. ✅ Set up automated builds
5. ✅ Create update server
6. ✅ Document for users
7. ✅ Distribute!

---

## Support

For issues with:
- **Build process**: Check rpm-ostree logs
- **Custom packages**: Verify spec files
- **Hardware support**: Check asusctl/supergfxctl compatibility
