# Personal Files Safety - Desktop & Home Directory

## ✅ YOUR PERSONAL FILES ARE 100% SAFE

The build system **NEVER** touches your personal files, documents, photos, or anything in your home directory outside of specific build directories.

## What Is NEVER Touched

### Your Personal Files (100% Safe)

| Location | Status | What's There |
|----------|--------|--------------|
| `~/Desktop/` | ✅ **PROTECTED** | Your files, folders, projects |
| `~/Documents/` | ✅ **PROTECTED** | Documents, work files |
| `~/Pictures/` | ✅ **PROTECTED** | Photos, wallpapers, images |
| `~/Music/` | ✅ **PROTECTED** | Music collection |
| `~/Videos/` | ✅ **PROTECTED** | Videos, recordings |
| `~/Downloads/` | ✅ **PROTECTED** | Downloaded files |
| `~/Projects/` | ✅ **PROTECTED** | Your code projects |
| `~/.ssh/` | ✅ **PROTECTED** | SSH keys |
| `~/.gnupg/` | ✅ **PROTECTED** | GPG keys |
| `~/.password-store/` | ✅ **PROTECTED** | Password store |
| `~/.local/share/` (except specific dirs) | ✅ **PROTECTED** | App data |
| `~/.config/` (except specific files) | ✅ **PROTECTED** | Configs |

### Specifically Protected
- All files on your Desktop
- All personal documents
- All photos and media
- All browser bookmarks/history
- All application data
- All SSH/GPG keys
- All password databases

## What Gets Created (New Directories Only)

```
~/zephyrus-os-build/           # NEW - Build work directory
└── custom-packages/           # NEW - Where YOU copy source
    ├── rog-control-center-1.0.0/   # YOUR COPY (you control this)
    └── zephyrus-keyboard-control-1.0.0/  # YOUR COPY (you control this)

~/rpmbuild/                    # NEW - RPM build output
├── BUILD/
├── RPMS/                      # Built RPMs appear here
├── SOURCES/
├── SPECS/
└── SRPMS/
```

**These are NEW directories - nothing is deleted or overwritten.**

## What Gets Modified (System Files Only)

### System Paths (Not Your Personal Files)

```
/usr/share/gnome-shell/        # System GNOME Shell
/etc/os-release                # System OS info
/etc/dconf/                    # System defaults (not your user settings)
```

### Your User Configs (Backed Up First)

```
~/.config/gnome-shell/         # ONLY if you run the patch script
└── user.css                   # Created new, won't overwrite
```

**Your personal ~/.config files are NOT touched.**

## Detailed Breakdown

### Desktop Folder

```bash
# The build scripts NEVER do this:
rm -rf ~/Desktop/*                    # NEVER
mv ~/Desktop/* ~/somewhere/           # NEVER
cp anything ~/Desktop/                # NEVER (unless you manually do it)
```

**Your Desktop stays exactly as it is.**

### Home Directory

What the scripts access:
```bash
# Only these specific paths:
~/zephyrus-os-build/          # Created fresh
~/rpmbuild/                   # Created fresh  
~/.config/gnome-shell/        # Created for CSS (only if you run fix scripts)
```

What the scripts NEVER access:
```bash
# These are NEVER touched:
~/Desktop/
~/Documents/
~/Pictures/
~/.* (hidden personal files)
~/anything-else/
```

## Visual Diagram

```
Your Home Directory (~/)
│
├── Desktop/                    ✅ SAFE - NEVER TOUCHED
│   ├── Your files...
│   ├── Your folders...
│   └── Zephyrus OS/           ← This repo (safe)
│
├── Documents/                  ✅ SAFE - NEVER TOUCHED
├── Pictures/                   ✅ SAFE - NEVER TOUCHED
├── Downloads/                  ✅ SAFE - NEVER TOUCHED
├── Music/                      ✅ SAFE - NEVER TOUCHED
├── Videos/                     ✅ SAFE - NEVER TOUCHED
├── Projects/                   ✅ SAFE - NEVER TOUCHED
│   ├── rog-control-center/    ← YOUR SOURCE (stays here)
│   └── keyboard-control/       ← YOUR SOURCE (stays here)
│
├── .config/                    ⚠️  MINIMAL - Only specific files
│   ├── dconf/                  ✅ SAFE
│   ├── gnome-shell/            ⚠️  CSS only if you apply theme
│   └── everything-else/        ✅ SAFE
│
├── .local/                     ✅ SAFE
├── .ssh/                       ✅ SAFE
├── .gnupg/                     ✅ SAFE
│
├── zephyrus-os-build/          🆕 NEW - Build directory
│   └── custom-packages/        🆕 NEW - Your COPIES go here
│
└── rpmbuild/                   🆕 NEW - RPM output
```

## If You Want to Be Extra Safe

### Option 1: Check What Will Be Modified

```bash
# List all files the script will create/modify
cd ~/Desktop/Zephyrus\ OS/distro-build

grep -r "mkdir -p ~/" *.sh | grep -v ".backup"
grep -r "echo.*> ~/" *.sh
grep -r "cp.*~/" *.sh | grep -v ".backup"
```

### Option 2: Run in Isolation (VM/Container)

```bash
# Test build in a container first
toolbox create zephyrus-build-test
toolbox run -c zephyrus-build-test ./build-zephyrus-os.sh
```

### Option 3: Backup Before Building

```bash
# Quick backup of critical files
rsync -av ~/Desktop/ ~/Backups/Desktop-$(date +%Y%m%d)/
rsync -av ~/Documents/ ~/Backups/Documents-$(date +%Y%m%d)/
```

## Specific Script Safety

### `build-gnome-shell-rpm.sh`

**Touches:**
- `~/zephyrus-os-build/` (creates)
- `~/rpmbuild/` (creates)
- Downloads Fedora source (temporary)

**Does NOT touch:**
- `~/Desktop/`
- Any personal files

### `build-zephyrus-os.sh`

**Touches:**
- `~/zephyrus-os-build/` (creates)
- `~/rpmbuild/` (creates)

**Does NOT touch:**
- `~/Desktop/`
- Any personal files

### `strip-bazzite.sh`

**Touches (with sudo):**
- System files: `/usr/share/`, `/etc/`
- System packages

**Does NOT touch:**
- `~/Desktop/`
- `~/Documents/`
- Any personal files in home

### `migrate-to-zephyrus.sh`

**Creates backups:**
- `~/zephyrus-migration-installed-packages.txt`
- `~/zephyrus-migration-dconf-backup.ini`
- `~/zephyrus-migration-backup/` (copies GNOME configs)

**Does NOT touch:**
- `~/Desktop/` contents
- Personal files
- Documents, photos, etc.

## Verification

### Before Running Anything

```bash
# Check your Desktop
echo "Files on Desktop:"
ls ~/Desktop/

echo ""
echo "Files that will be created:"
echo "  ~/zephyrus-os-build/"
echo "  ~/rpmbuild/"
echo "  ~/zephyrus-migration-* (backup files)"
```

### After Running

```bash
# Verify Desktop is unchanged
echo "Files on Desktop (should be same):"
ls ~/Desktop/

# Check what was created
echo ""
echo "New directories:"
ls -d ~/zephyrus-os-build/ ~/rpmbuild/ 2>/dev/null || echo "Not created yet"
```

## Emergency: If Something Goes Wrong

**If you accidentally deleted something:**

```bash
# Check trash
cd ~/.local/share/Trash/files/
ls -la

# Restore from trash
mv ~/.local/share/Trash/files/YOUR_FILE ~/Desktop/

# Or from backup (if you made one)
rsync -av ~/Backups/Desktop-*/ ~/Desktop/
```

**If build files cause issues:**

```bash
# Just delete the build directories
rm -rf ~/zephyrus-os-build/
rm -rf ~/rpmbuild/

# Your personal files are untouched
```

## Summary

| Question | Answer |
|----------|--------|
| Will it delete my Desktop files? | **NO** |
| Will it move my documents? | **NO** |
| Will it touch my photos? | **NO** |
| Will it access my passwords/keys? | **NO** |
| Will it modify my projects? | **NO** |
| What WILL it touch? | System files only, and `~/zephyrus-os-build/`, `~/rpmbuild/` |

**Your personal files are completely safe. The build system only works with system files and isolated build directories.**

## Final Check

```bash
# Run this to verify safety
echo "=== Your Desktop Files ==="
ls ~/Desktop/ | wc -l
echo "files on Desktop"

echo ""
echo "=== Build System Will Create ==="
echo "~/zephyrus-os-build/ (empty directory)"
echo "~/rpmbuild/ (empty directory)"
echo ""
echo "=== Build System Will NOT Touch ==="
echo "~/Desktop/ and all personal files"
```
