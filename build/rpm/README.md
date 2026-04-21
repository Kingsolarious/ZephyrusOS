# Zephyrus OS - Distro Build System

```
███████╗███████╗██████╗ ██╗  ██╗██╗   ██╗██████╗ ██╗   ██╗███████╗     ██████╗ ███████╗
╚══███╔╝██╔════╝██╔══██╗██║  ██║██║   ██║██╔══██╗██║   ██║██╔════╝    ██╔═══██╗██╔════╝
  ███╔╝ █████╗  ██████╔╝███████║██║   ██║██████╔╝██║   ██║███████╗    ██║   ██║███████╗
 ███╔╝  ██╔══╝  ██╔═══╝ ██╔══██║██║   ██║██╔══██╗██║   ██║╚════██║    ██║   ██║╚════██║
███████╗███████╗██║     ██║  ██║╚██████╔╝██║  ██║╚██████╔╝███████║    ╚██████╔╝███████║
╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚══════╝

                    ZEPHYRUS OS - The Ultimate ROG Linux Experience
```

## Overview

Complete build system for creating **Zephyrus OS** - a custom Linux distribution based on Fedora Silverblue, optimized for ASUS ROG laptops, with all Bazzite branding removed.

## ⚠️ Safety First

**Your personal files are 100% safe.**

- ✅ Desktop files - **NEVER TOUCHED**
- ✅ Documents, photos, videos - **NEVER TOUCHED**  
- ✅ Personal projects - **NEVER TOUCHED**
- ✅ SSH keys, passwords - **NEVER TOUCHED**
- ✅ System files - Backed up before modification

See [PERSONAL_FILES_SAFETY.md](PERSONAL_FILES_SAFETY.md) for details.

## Zephyrus OS Features

- ✓ **Custom GNOME Shell** - Screen lock toggle removed from Quick Settings
- ✓ **Zephyrus OS Branding** - Complete system rebranding
- ✓ **ROG Control Center** - Custom ASUS laptop control
- ✓ **Zephyrus Crimson Theme** - Red-black ROG aesthetic
- ✓ **Gaming Optimized** - Performance tuned for gaming
- ✓ **No Bazzite** - Clean, professional distribution

## Quick Start

### Step 0: Safety Check

```bash
cd ~/Desktop/Zephyrus\ OS/distro-build
./check-safety.sh
```

### Build Zephyrus OS

```bash
# Start the build
./build-zephyrus-os.sh

# Select option 6 for full Zephyrus OS build
```

## Zephyrus OS Identity

| Property | Value |
|----------|-------|
| **Name** | Zephyrus OS |
| **Version** | 41 (ROG Edition) |
| **Codename** | Crimson |
| **Base** | Fedora Silverblue 41 |
| **Target** | ASUS ROG Laptops |
| **Theme** | Zephyrus Crimson (red-black) |

## File Structure

```
distrib-build/
├── build-zephyrus-os.sh           # Main Zephyrus OS builder
├── build-gnome-shell-rpm.sh       # Custom GNOME Shell builder
├── zephyrus-os-treefile.yaml      # Zephyrus OS OSTree manifest
├── zephyrus-os-release.spec       # Zephyrus OS branding package
├── patches/
│   └── zephyrus-gnome-shell-branding.patch
├── check-safety.sh                # Pre-build safety check
├── PERSONAL_FILES_SAFETY.md       # Personal files protection
├── FILE_SAFETY.md                 # Source code safety
├── BUILD_FROM_SCRATCH.md          # Complete build guide
└── README.md                      # This file
```

## What's Different from Bazzite

| Feature | Bazzite | Zephyrus OS |
|---------|---------|-------------|
| Branding | Bazzite/Gaming | **Zephyrus OS/ROG** |
| Screen Lock Toggle | Present | **Removed** |
| Control Center | Generic | **ROG Custom** |
| Theme | Generic | **Zephyrus Crimson** |
| Gaming Focus | Steam Deck | **ROG Laptops** |

## Build Components

### 1. Zephyrus GNOME Shell
Custom GNOME Shell with:
- Screen lock toggle removed from Quick Settings
- Screen recording toggle removed
- Zephyrus OS branding

### 2. Zephyrus OS Release Package
Complete system branding:
- os-release files
- /etc/issue with ASCII art
- /etc/motd welcome message
- Zephyrus OS directories

### 3. asusctl (ROG Control Center)
Your custom ASUS laptop control software

### 4. Zephyrus Theme & Extensions
- Crimson red-black theme
- Custom GNOME extensions
- ROG-inspired styling

## Distribution

### As OSTree Repo

```bash
# Users add Zephyrus OS
sudo ostree remote add zephyrus-os https://zephyrus-os.org/repo
sudo rpm-ostree rebase zephyrus-os:zephyrus-os/41/x86_64/stable
```

### As ISO Installer

```bash
# Create bootable Zephyrus OS ISO
sudo livemedia-creator --make-iso \
    --iso-name=zephyrus-os-41.iso
```

## Verification

After building, verify Zephyrus OS:

```bash
# Check OS branding
cat /etc/os-release
# Should show: NAME="Zephyrus OS"

# Check GNOME Shell
gnome-shell --version
# Should show: GNOME Shell 49.4 (Zephyrus)

# Check Quick Settings
# Open - screen lock toggle should be gone
```

## Safety Documentation

- [PERSONAL_FILES_SAFETY.md](PERSONAL_FILES_SAFETY.md) - Desktop/personal files protection
- [FILE_SAFETY.md](FILE_SAFETY.md) - Source code protection
- [BUILD_FROM_SCRATCH.md](BUILD_FROM_SCRATCH.md) - Complete build guide

## Support

For Zephyrus OS:
- Website: https://zephyrus-os.org
- Docs: https://docs.zephyrus-os.org
- Issues: https://issues.zephyrus-os.org

## License

Zephyrus OS components are released under MIT License.

---

**Welcome to Zephyrus OS - The Ultimate ROG Linux Experience**

`ZEPHYRUS_OS_41_ROG_CRIMSON`
