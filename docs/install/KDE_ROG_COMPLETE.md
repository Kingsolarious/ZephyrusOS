# Zephyrus OS - KDE Plasma Complete Setup

## ✅ Setup Complete!

Your KDE Plasma desktop has been configured with ROG Zephyrus branding and macOS-style features.

## 🎨 What's Configured

### 1. Visual Theme
- **Color Scheme**: Zephyrus Crimson (Dark with ROG Red accents)
- **Window Controls**: Left-side buttons (macOS style)
- **Wallpaper**: ROG Zephyrus logo
- **Terminal**: Konsole with ROG color scheme

### 2. Panels
- **Top Panel**: Application Menu + System Tray + Clock
- **Bottom Panel**: Icon Task Manager (Dock)

### 3. Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| `Meta+Return` | Launch Terminal |
| `Meta+B` | Launch Browser |
| `Meta+D` | Show Desktop |
| `Meta+L` | Lock Screen |
| `Meta+Left/Right` | Tile Window |
| `Meta+Up` | Maximize Window |
| `Meta+Down` | Minimize Window |
| `Alt+Space` | Run Command (KRunner) |
| `Meta+Tab` | Expose (Window Overview) |

### 4. Applications
- **About This Zephyrus**: System information (`zephyrus-about`)
- **Zephyrus Settings**: System settings shortcut
- **Armoury Crate**: Performance profile switcher

## 🚀 Quick Commands

```bash
# Run About app
zephyrus-about

# Check ASUS hardware
asusctl --help

# Switch performance profile
sudo asusctl profile performance
sudo asusctl profile balanced
sudo asusctl profile quiet

# Check GPU status (deprecated — NVIDIA driver manages power states)
# supergfxctl --status

# Restart Plasma (if needed)
kquitapp6 plasmashell && plasmashell &
```

## 🎮 Gaming Features

### Performance Modes
- **Performance**: Maximum CPU/GPU performance
- **Balanced**: Automatic power management
- **Quiet**: Silent operation, reduced performance

### GPU Power Management
> **Note:** `supergfxctl` is deprecated. Disabling the dGPU via supergfxctl often leaves it powered-on but inaccessible, wasting battery. The NVIDIA driver's native power management (`nvidia.NVreg_DynamicPowerManagement=0x02`) is preferred.
>
> For MUX switch control, use `asusctl gfx` if available, or let the NVIDIA driver handle power states automatically.
>
> A community replacement tool that works *with* the NVIDIA driver is in development.

## 🔧 Customization

### Change Color Scheme
1. Open **System Settings**
2. Go to **Appearance** → **Colors**
3. Select **Zephyrus Crimson** or any other theme

### Customize Panels
1. Right-click panel → **Enter Edit Mode**
2. Add/Remove widgets
3. Drag to reposition
4. Click **Done**

### Add Apps to Dock
1. Open Application Menu
2. Right-click app → **Pin to Task Manager**

## 📁 File Locations

| Component | Location |
|-----------|----------|
| Color Scheme | `~/.local/share/color-schemes/ZephyrusCrimson.colors` |
| Plasma Theme | `~/.local/share/plasma/desktoptheme/ZephyrusCrimson/` |
| Konsole Profile | `~/.local/share/konsole/ZephyrusCrimson.profile` |
| Application Entries | `~/.local/share/applications/` |
| KDE Config | `~/.config/` |

## 🐛 Troubleshooting

### Panel Disappeared
```bash
# Reset panels to default
rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc
# Then re-run setup script
```

### Keyboard Shortcuts Not Working
```bash
# Reload shortcuts
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key ReloadConfig "true"
```

### Theme Not Applied
```bash
# Apply theme manually
lookandfeeltool --apply ZephyrusCrimson
```

## 📚 Documentation

- **KDE User Guide**: https://userbase.kde.org/
- **ASUS Linux**: https://asus-linux.org/
- **Bazzite Docs**: https://docs.bazzite.gg/

## 🎯 Next Steps

1. ✅ Explore the new layout
2. ✅ Customize your dock with favorite apps
3. ✅ Set up ROG keyboard shortcuts for Armoury Crate
4. ✅ Install games via Steam (pre-installed)
5. ✅ Enjoy your ROG-themed KDE Plasma!

---

**Welcome to Zephyrus OS on KDE Plasma!** 🎮
