# Zephyrus OS - Quick Start Guide

```
ZEPHYRUS OS - The Ultimate ROG Linux Experience
```

## Build Zephyrus OS Now

### 1. Safety Check

```bash
cd ~/Desktop/Zephyrus\ OS/distro-build
./check-safety.sh
```

### 2. Build Everything

```bash
./build-zephyrus-os.sh
# Select: 6 (FULL ZEPHYRUS OS BUILD)
```

### 3. Install on Your System

```bash
# Install custom GNOME Shell (removes screen lock toggle)
sudo rpm-ostree override replace \
    ~/rpmbuild/RPMS/x86_64/gnome-shell-*.rpm

# Install Zephyrus OS branding
sudo rpm-ostree install \
    ~/rpmbuild/RPMS/noarch/zephyrus-os-release-*.rpm

# Reboot
systemctl reboot
```

## What You Get

After building, Zephyrus OS includes:

✓ **Zephyrus OS Branding**
  - OS name: "Zephyrus OS"
  - Version: "41 (ROG Edition)"
  - Theme: Crimson

✓ **Custom GNOME Shell**
  - Screen lock toggle: REMOVED
  - Screen recording toggle: REMOVED
  - Zephyrus styling

✓ **ROG Control Center** (asusctl)
  - Your custom control software
  - Keyboard RGB control
  - Fan curves
  - Performance modes

✓ **Zephyrus Crimson Theme**
  - Red-black ROG aesthetic
  - Custom icons
  - Custom wallpapers

## File Locations

| Component | Location |
|-----------|----------|
| Build scripts | `~/Desktop/Zephyrus OS/distro-build/` |
| RPM output | `~/rpmbuild/RPMS/` |
| Distribution | `~/zephyrus-os-dist/` |
| Your source copy | `~/zephyrus-os-build/` |

## Zephyrus OS Commands

```bash
# Check OS version
cat /etc/os-release
cat /etc/zephyrus-os-release

# Check GNOME Shell
rpm -q gnome-shell

# Check branding
ls /usr/share/zephyrus-os/
```

## Next Steps

1. ✅ Build Zephyrus OS
2. ✅ Install on test system
3. ✅ Verify screen lock toggle is gone
4. ✅ Verify ROG Control Center works
5. ✅ Create OSTree repo for distribution
6. ✅ Build ISO installer

## Support

**Zephyrus OS**
- Website: https://zephyrus-os.org
- Docs: https://docs.zephyrus-os.org

---

**Welcome to Zephyrus OS!**

`ZEPHYRUS_OS_41_ROG_CRIMSON`
