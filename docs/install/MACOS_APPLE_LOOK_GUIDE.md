# macOS Apple Look - Zephyrus OS KDE

Your KDE Plasma desktop now has an authentic **macOS-style Apple look** with a top menu bar and bottom dock!

## 🍎 What You See Now

### Top Menu Bar (like macOS menu bar)
```
┌─────────────────────────────────────────────────────────────┐
│ 🍎 File  Edit  View  Window  Help       🔊 🔋  Sat 9:40 PM  │
└─────────────────────────────────────────────────────────────┘
```
- **Left**: Application Menu (🍎 icon) + Global Menu
- **Center**: Panel spacer (empty)
- **Right**: System tray + Digital clock (macOS format)

### Bottom Dock (like macOS dock)
```
┌──────────────────────────────────────────┐
│  🗂️  🌐  💻  📄  📝          🗑️          │
│ Files Web Term Edit Text        Trash    │
└──────────────────────────────────────────┘
```
- **Centered** large icons (64px)
- **Apps**: Files, Browser, Terminal, Editor
- **Right**: Trash

### Window Controls (macOS style)
```
┌───┬───┬───┬────────────────────────────────┐
│ 🟡│ 🟡│ 🟢│         Window Title           │
│Close│Min│Max│                                │
└───┴───┴───┴────────────────────────────────┘
```
- Buttons on **LEFT** side
- Red/Yellow/Green dots (ROG crimson style)

## 🎨 Theme Details

| Feature | Setting |
|---------|---------|
| **Color Scheme** | macOS-Dark with ROG Crimson accents |
| **Window Decor** | Breeze with left-side buttons |
| **Icons** | Breeze (can install macOS icon pack) |
| **Fonts** | Noto Sans |
| **Effects** | Blur enabled, transparency on |

## 🚀 Quick Commands

```bash
# Add app to dock
zephyrus-add-dock-icon firefox.desktop
zephyrus-add-dock-icon steam.desktop

# Check system status
zephyrus-os-tool status

# Open About app
zephyrus-about

# Switch performance modes
zephyrus-os-tool performance  # or balanced/quiet
```

## 🛠️ Customization

### Change Icon Size in Dock
1. Right-click dock → **Configure Icon Tasks**
2. Set **Icon Size**: 48 (small) → 64 (medium) → 80 (large)

### Add More Apps to Dock
```bash
# Find desktop files
ls /usr/share/applications/*.desktop | grep -i appname

# Add to dock
zephyrus-add-dock-icon org.kde.konsole.desktop
zephyrus-add-dock-icon firefox.desktop
zephyrus-add-dock-icon org.kde.dolphin.desktop
```

### Change Color Scheme
1. **System Settings** → **Appearance** → **Colors**
2. Choose:
   - **macOS-Dark** (current - with ROG crimson)
   - **macOS** (light theme)
   - **ZephyrusCrimson** (full ROG dark)

### Install macOS Icon Pack (Optional)
```bash
# Download from KDE Store or:
# https://store.kde.org/browse?cat=132&ord=latest

# Extract to:
~/.local/share/icons/

# Then set in System Settings → Icons
```

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Meta` | Open Application Menu |
| `Meta+Return` | Launch Terminal |
| `Meta+B` | Launch Browser |
| `Meta+D` | Show Desktop |
| `Meta+L` | Lock Screen |
| `Meta+Space` | Run Command (like Spotlight) |
| `Meta+Tab` | Window Overview (Exposé) |
| `Meta+Left/Right` | Tile Window |
| `Meta+Up` | Maximize Window |
| `Meta+Down` | Minimize Window |

## 🎮 ROG Integration

Your ROG-specific features still work:

```bash
# Check ROG status
asusctl --help

# Performance modes
sudo asusctl profile performance  # Gaming
sudo asusctl profile balanced     # Normal
sudo asusctl profile quiet        # Silent

# About This Zephyrus
zephyrus-about
```

## 🐛 Troubleshooting

### Dock Not Centered
```bash
# Restart Plasma
killall plasmashell && plasmashell &
```

### Global Menu Not Working
1. Make sure app supports global menu (GTK apps need appmenu-gtk-module)
2. Restart the app after enabling global menu

### Icons Too Small/Big
```bash
# Edit dock settings
~/.local/bin/zephyrus-macos-dock
```

### Want Original KDE Layout Back
```bash
# Reset panels
rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc
# Then restart Plasma
```

## 📸 Screenshot Tips

To capture your new macOS-style desktop:
```bash
# Full screen
spectacle -f

# Active window
spectacle -a

# Select area
spectacle -r
```

## 🎯 Next Steps

1. ✅ **Add your favorite apps** to the dock
2. ✅ **Customize icon size** to your preference
3. ✅ **Install a macOS icon theme** (optional)
4. ✅ **Set up ROG keyboard shortcuts** for gaming
5. ✅ **Enjoy the factory experience!**

---

**Your Zephyrus OS now looks like a high-end Apple machine with ROG gaming power!** 🍎🎮
