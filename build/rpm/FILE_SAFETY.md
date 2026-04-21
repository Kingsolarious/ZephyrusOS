# File Safety Guide - Zephyrus OS Build System

## ⚠️ IMPORTANT: Your Files Are Safe

The build system is designed to **NEVER** overwrite your source code or tuned configurations.

## What Gets Created vs What Gets Preserved

### ✅ SAFE - These are CREATED (won't touch your files)

| Location | Purpose | Action |
|----------|---------|--------|
| `~/zephyrus-os-build/` | Build work directory | Created empty |
| `~/rpmbuild/` | RPM build directory | Created empty |
| `~/.config/gnome-shell/` | GNOME Shell CSS | Created, won't overwrite existing |
| `*.spec` files | RPM specifications | Created, prompts before overwrite |

### 🛡️ PROTECTED - These are NEVER touched

| Your Files | Location | Protection |
|------------|----------|------------|
| ROG Control Center source | Your actual source directory | **NEVER touched** |
| Keyboard control program | Your actual source directory | **NEVER touched** |
| Your tuned keyboard configs | `/etc/` or `~/.config/` | **NEVER touched** |
| Your existing themes | `~/.themes/` | **NEVER touched** |
| Your GNOME extensions | `~/.local/share/gnome-shell/extensions/` | **NEVER touched** |
| Your dconf settings | `~/.config/dconf/` | **NEVER touched** |

## How It Works

### 1. GNOME Shell Build

```
Downloads to: ~/zephyrus-os-build/
└── Downloads Fedora GNOME Shell source (safe, temporary)
└── Applies patches
└── Builds RPM to: ~/rpmbuild/RPMS/
```

**Your files**: Not touched at all.

### 2. Custom Software Packaging

```
Looks for: ~/zephyrus-os-build/custom-packages/
├── rog-control-center-1.0.0/     ← YOUR SOURCE (must copy here)
└── zephyrus-keyboard-control-1.0.0/  ← YOUR SOURCE (must copy here)
```

**Before copying your source:**
```bash
# Check if directories exist
ls ~/zephyrus-os-build/custom-packages/

# If NOT exists, create them and copy your source
mkdir -p ~/zephyrus-os-build/custom-packages/rog-control-center-1.0.0
cp -r /path/to/YOUR/rog-control-center/* ~/zephyrus-os-build/custom-packages/rog-control-center-1.0.0/
```

### 3. Runtime Patching (on your system)

**Creates backups automatically:**
```
/usr/share/gnome-shell/js/ui/status/system.js
├── system.js.backup.20250306210000  ← Auto-created backup
└── system.js                        ← Patched (backup exists)
```

**To restore:**
```bash
sudo cp /usr/share/gnome-shell/js/ui/status/system.js.backup.* \
        /usr/share/gnome-shell/js/ui/status/system.js
```

## Safety Commands

### Before Building - Backup Your Stuff

```bash
# Backup your source code (just in case)
rsync -av ~/Projects/rog-control-center ~/Backups/
rsync -av ~/Projects/keyboard-control ~/Backups/

# Backup your tuned configs
sudo tar czf ~/backups-zephyrus-configs.tar.gz \
    /etc/asusd/ \
    ~/.config/dconf/ \
    ~/.local/share/gnome-shell/extensions/
```

### Check What Will Be Modified

```bash
# Dry run - see what would change
./build-gnome-shell-rpm.sh --dry-run 2>/dev/null || echo "Review script first"

# Check existing backups
ls -la /usr/share/gnome-shell/js/ui/status/system.js.backup* 2>/dev/null || echo "No backups yet"
```

### If Something Goes Wrong

**Restore GNOME Shell:**
```bash
# From backup
sudo cp /usr/share/gnome-shell/js/ui/status/system.js.backup.* \
        /usr/share/gnome-shell/js/ui/status/system.js

# Or reset to default
sudo rpm-ostree reset gnome-shell
```

**Restore your settings:**
```bash
# Restore dconf
dconf load / < ~/backups/zephyrus-migration-dconf-backup.ini
```

## Build Script Safety Features

### 1. Prompt Before Overwrite

```bash
if [ -f "rog-control-center.spec" ]; then
    read -p "rog-control-center.spec exists. Overwrite? (y/N) " -n 1 -r
    # Only overwrites if you say 'y'
fi
```

### 2. Automatic Backups

```bash
# Backs up before patching
cp "$SYSTEM_JS" "${SYSTEM_JS}.backup.$(date +%Y%m%d%H%M%S)"
```

### 3. Check Before Create

```bash
if [ -d "$DIR" ]; then
    echo "Directory exists, skipping..."
else
    mkdir -p "$DIR"
fi
```

## Where to Put YOUR Source Code

### Recommended Structure

```
~/Projects/                     ← Keep your originals here (SAFE)
├── rog-control-center/         ← Your working source
│   ├── src/
│   ├── meson.build
│   └── README.md
└── zephyrus-keyboard/          ← Your working source
    ├── src/
    ├── Makefile
    └── README.md

~/zephyrus-os-build/            ← Build system (COPIES for packaging)
└── custom-packages/
    ├── rog-control-center-1.0.0/    ← COPY here for build
    └── zephyrus-keyboard-control-1.0.0/  ← COPY here for build
```

### Copy Script (Safe)

```bash
#!/bin/bash
# copy-source-for-build.sh - Safe copy for building

SOURCE_ROG="$HOME/Projects/rog-control-center"
SOURCE_KB="$HOME/Projects/zephyrus-keyboard"
BUILD_DIR="$HOME/zephyrus-os-build/custom-packages"

echo "Copying source to build directory..."

# ROG Control Center
if [ -d "$SOURCE_ROG" ]; then
    mkdir -p "$BUILD_DIR/rog-control-center-1.0.0"
    cp -r "$SOURCE_ROG"/* "$BUILD_DIR/rog-control-center-1.0.0/"
    echo "✓ ROG Control Center copied"
else
    echo "⚠️  Source not found: $SOURCE_ROG"
fi

# Keyboard Control
if [ -d "$SOURCE_KB" ]; then
    mkdir -p "$BUILD_DIR/zephyrus-keyboard-control-1.0.0"
    cp -r "$SOURCE_KB"/* "$BUILD_DIR/zephyrus-keyboard-control-1.0.0/"
    echo "✓ Keyboard Control copied"
else
    echo "⚠️  Source not found: $SOURCE_KB"
fi

echo ""
echo "Build directory ready: $BUILD_DIR"
```

## Quick Safety Checklist

Before running any build:

- [ ] Your source code is backed up (git or rsync)
- [ ] Your tuned configs are backed up
- [ ] You've reviewed what the script will do
- [ ] You know how to restore from backup

## Summary

| Your Concern | Answer |
|--------------|--------|
| Will it delete my source? | **NO** - Build uses copies |
| Will it overwrite my configs? | **NO** - Creates backups first |
| Will it break my system? | **Low risk** - Can reset with rpm-ostree |
| Can I undo changes? | **YES** - Backups created automatically |

**Your files are safe. The build system works with copies, not originals.**
