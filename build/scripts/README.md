# Zephyrus Crimson OS - Build System

Complete build system for creating a custom Bazzite-based Linux distribution with full ASUS ROG Zephyrus branding.

## Overview

This build system creates a bootable OS image that includes:
- Custom GNOME Shell extension (Global Menu)
- GTK4 About application with hardware detection
- Complete ROG-themed GTK/Shell theme
- Custom GDM login screen
- Custom Plymouth boot animation
- System-wide branding and defaults

## Architecture

```
os-build/
├── Containerfile          # Main OS image definition
├── build.sh               # Main build script
├── build-iso.sh           # ISO creation script
├── install.sh             # System installer
├── overlays/              # System configuration files
│   ├── etc/              # System configs
│   ├── system/           # systemd services
│   ├── gdm/              # GDM configuration
│   └── usr/              # Executable scripts
├── build/                # Build working directory
├── cache/                # Build cache
└── output/               # Built images and ISOs
```

## Quick Start

### Prerequisites

- Podman or Docker
- bootc-image-builder (for ISO creation)
- 20GB+ free disk space

### Build OS Image

```bash
cd os-build

# Build the OS image
./build.sh

# Build with specific version
./build.sh --version 1.1.0

# Build and push to registry
./build.sh --push

# Clean build
./build.sh --clean
```

### Build Installation ISO

```bash
# Build ISO from image
./build-iso.sh

# Or build everything
./build.sh --iso
```

## Build Options

| Option | Description |
|--------|-------------|
| `--clean` | Clean build directory first |
| `--iso` | Build installation ISO |
| `--push` | Push to container registry |
| `--no-push` | Skip pushing (default) |
| `--version X.Y.Z` | Set version tag |
| `--base IMAGE` | Use different base image |
| `--tag TAG` | Use different base tag |

## Installation

### Method 1: Online Install (bootc switch)

On a running Bazzite system:

```bash
# Download installer
curl -fsSL https://raw.githubusercontent.com/solarious/zephyrus-crimson/main/os-build/install.sh | bash

# Or manually:
sudo bootc switch ghcr.io/solarious/zephyrus-crimson:1.0.0
sudo systemctl reboot
```

### Method 2: ISO Install

1. Flash ISO to USB:
```bash
sudo dd if=output/zephyrus-crimson-1.0.0.iso of=/dev/sdX bs=4M status=progress
```

2. Boot from USB
3. Follow installation prompts

### Method 3: Local Container

```bash
# Load local image
podman load -i output/zephyrus-crimson-1.0.0.tar.gz

# Install from local
sudo bootc switch --transport containers-storage zephyrus-crimson:1.0.0
```

## Containerfile Structure

The `Containerfile` defines the OS image:

1. **Base Image**: Starts from Bazzite GNOME
2. **Packages**: Installs GNOME dev tools, Python GTK4, Plymouth
3. **Extension**: Copies and installs GNOME extension
4. **About App**: Installs GTK4 About application
5. **Themes**: Copies GTK/Shell themes
6. **GDM**: Configures login screen
7. **Plymouth**: Sets up boot animation
8. **System**: Applies system defaults

## System Overlays

Files in `overlays/` are copied to the system:

```
overlays/
├── etc/
│   ├── zephyrus-crimson/config.conf    # System config
│   ├── dconf/db/local.d/              # GNOME defaults
│   └── gdm/custom.conf                # GDM config
├── system/
│   └── zephyrus-crimson-setup.service # Setup service
└── usr/libexec/
    └── zephyrus-crimson-setup         # Setup script
```

## Customization

### Changing Base Image

Edit `Containerfile`:
```dockerfile
ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite-gnome
ARG BASE_TAG=stable
```

### Adding Packages

Add to the `rpm-ostree install` line in `Containerfile`.

### Custom Theme

Modify files in:
- `theme/gtk-4.0/gtk.css` - GTK4 theme
- `theme/gnome-shell/gnome-shell.css` - Shell theme

### Custom Assets

Replace files in:
- `gdm/assets/` - Login screen
- `plymouth/assets/` - Boot animation

## Registry Publishing

### GitHub Container Registry

```bash
# Login
echo $GITHUB_TOKEN | podman login ghcr.io -u USERNAME --password-stdin

# Build and push
./build.sh --push

# Result: ghcr.io/solarious/zephyrus-crimson:1.0.0
```

### Docker Hub

```bash
# Set registry
export REGISTRY=docker.io/yourusername

# Build and push
./build.sh --push
```

## Development Workflow

### 1. Test Changes Locally

```bash
# Build
./build.sh --no-push --clean

# Load and test
podman run -it zephyrus-crimson:latest /bin/bash
```

### 2. Test on Real Hardware

```bash
# Build local image
./build.sh --no-push

# Export
podman save zephyrus-crimson:latest | gzip > test.tar.gz

# On test machine:
podman load -i test.tar.gz
sudo bootc switch --transport containers-storage zephyrus-crimson:latest
```

### 3. Release

```bash
# Build release
./build.sh --version 1.0.0 --push --iso

# Create release notes
cat > output/release-notes.md << EOF
# Zephyrus Crimson OS v1.0.0

## Changes
- Feature 1
- Feature 2

## Installation
\`\`\`bash
sudo bootc switch ghcr.io/solarious/zephyrus-crimson:1.0.0
\`\`\`
EOF
```

## Troubleshooting

### Build Fails

```bash
# Clean and retry
./build.sh --clean

# Check disk space
df -h

# Verbose build
podman build --progress=plain -f Containerfile .
```

### Boot Issues

```bash
# Check bootc status
sudo bootc status

# Rollback if needed
sudo rpm-ostree rollback
sudo systemctl reboot
```

### Extension Not Loading

```bash
# Check logs
journalctl -xe | grep gnome-shell

# Verify installation
ls /usr/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/

# Manual enable
gnome-extensions enable zephyrus-globalmenu@solarious
```

## File Structure Reference

| Path | Purpose |
|------|---------|
| `os-build/Containerfile` | OS image definition |
| `os-build/build.sh` | Main build script |
| `os-build/install.sh` | System installer |
| `extension/` | GNOME extension source |
| `zephyrus-about/` | About app source |
| `theme/` | Theme files |
| `gdm/assets/` | Login screen assets |
| `plymouth/` | Boot splash theme |
| `os-build/output/` | Build outputs |

## Advanced Topics

### Multi-Architecture Builds

```bash
# Build for AMD64 and ARM64
podman build --platform linux/amd64,linux/arm64 -f Containerfile .
```

### Delta Updates

bootc supports delta updates between versions:

```bash
# Update to new version
sudo bootc switch ghcr.io/solarious/zephyrus-crimson:1.1.0
```

### Custom Kernel

Add to Containerfile:
```dockerfile
RUN rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:user:repo \
    kernel kernel-core kernel-modules
```

## License

This build system is part of Zephyrus Crimson OS.
ASUS and ROG are trademarks of ASUSTek Computer Inc.

## Resources

- [bootc Documentation](https://containers.github.io/bootc/)
- [Bazzite Documentation](https://docs.bazzite.gg/)
- [Universal Blue](https://universal-blue.org/)
