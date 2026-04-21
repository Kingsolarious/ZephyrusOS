# Zephyrus OS - KDE Plasma Setup Guide

## ✅ What's Already Done

- [x] Rebased to KDE Plasma 6
- [x] Window buttons moved to LEFT side (macOS style)
- [x] About This Zephyrus app installed and working
- [x] ROG Wallpaper set
- [x] ROG-themed dock script installed (needs manual fix for GTK4)

## 🔧 Manual Setup Steps

### 1. Add Global Menu (macOS-style menu bar)

The global menu shows application menus in the top panel.

**Steps:**
1. Right-click on the **top panel** → **Enter Edit Mode**
2. Click **Add Widgets**
3. Search for **"Global Menu"** and add it
4. Drag it to the **left side** of the panel (after the application launcher)
5. Click **Done** to exit edit mode

### 2. Create a Dock Panel (Bottom)

KDE's native dock is better than our Python script for Plasma.

**Steps:**
1. Right-click on **desktop** → **Add Panel** → **Default Panel**
2. Right-click the **new bottom panel** → **Enter Edit Mode**
3. Remove unnecessary widgets:
   - Click **X** on the Clock (keep it on top panel)
   - Remove extra System Tray if present
4. Add **Icons Only Task Manager**:
   - Click **Add Widgets**
   - Find **"Icons Only Task Manager"**
   - Drag to the center of the bottom panel
5. **Configure the Task Manager:**
   - Right-click it → **Icons Only Task Manager Settings**
   - Check **"Group only when the task manager is full"**
   - Check **"Show only tasks from current screen"**
6. Click **Done**

### 3. Add Apps to the Dock

1. Open **Application Menu** (top left)
2. Find the app you want (e.g., Firefox, Files, Terminal)
3. **Right-click** → **Pin to Task Manager**

### 4. Apply Dark/ROG Theme

1. Open **System Settings** → **Appearance** → **Global Theme**
2. Select **"Breeze Dark"** or look for ROG themes
3. Click **Apply**

### 5. Configure Window Decorations

1. **System Settings** → **Appearance** → **Window Decorations**
2. Select a theme that looks good with left-side buttons
3. Check **"Use theme's default window border size"**

### 6. Set Accent Color (ROG Crimson)

1. **System Settings** → **Appearance** → **Colors**
2. Click **Edit** on your current theme
3. Set **Accent color** to: `#FF3333` (ROG Crimson)
4. Click **Apply**

## 🚀 Quick Commands

```bash
# Run About app
zephyrus-about

# Restart KDE Shell (if needed)
kquitapp5 plasmashell && kstart5 plasmashell

# Apply settings
qdbus org.kde.KWin /KWin reconfigure
```

## 🎮 ROG-Specific Features

### ASUS Linux Integration
```bash
# Check if asusctl is installed
asusctl --help

# Set performance mode
sudo asusctl profile performance

# Check GPU status
supergfxctl --status
```

### Keyboard Shortcuts

Set up ROG-specific shortcuts in **System Settings** → **Shortcuts**:
- **Fn+F5**: Performance mode toggle
- **ROG Key**: Launch Armoury Crate (or custom app)

## 📁 What's Installed

| Component | Location | Status |
|-----------|----------|--------|
| About App | `~/.local/bin/zephyrus-about` | ✅ Working |
| Dock Script | `~/.local/bin/zephyrus-dock` | ⚠️ Needs GTK4 fix |
| ROG Wallpaper | `~/Desktop/Zephyrus OS/Rog Logo2.png` | ✅ Set |
| Desktop Config | `~/.config/` | ✅ Configured |

## 🐛 Known Issues & Fixes

### Python GTK Apps Use Wrong Python
**Fix:** Scripts have been updated to use `/usr/bin/python3`

### Dock Doesn't Stay on Top
**Workaround:** Use KDE's native Icons Only Task Manager instead

### GTK4 Window Hints Don't Work
**Issue:** `set_type_hint`, `set_keep_above` not available in GTK4
**Fix:** Use KDE's native panel/dock instead

## 🎯 Next Steps

1. ✅ Complete the manual setup above
2. ✅ Customize your dock with favorite apps
3. ✅ Set up ROG keyboard shortcuts
4. ✅ Install additional software via Discover (app store)

## 📞 Need Help?

- **KDE User Guide:** https://userbase.kde.org/
- **Zephyrus Project:** Check `~/Desktop/Zephyrus OS/` for docs

---

**Enjoy your ROG-themed KDE Plasma! 🎮**
