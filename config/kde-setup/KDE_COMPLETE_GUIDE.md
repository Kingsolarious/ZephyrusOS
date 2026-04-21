# Zephyrus OS on KDE Plasma - Complete Guide

## Why This Is The Right Choice

KDE Plasma gives you:
- ✅ **True Global Menu** - Works perfectly, native implementation
- ✅ **Glass Windows** - KWin compositor with full transparency
- ✅ **Factory Feel** - Everything integrated, no extensions
- ✅ **ROG Hardware Control** - Native KCM modules
- ✅ **Customize Everything** - No limitations

## Migration Process

### Step 1: Backup (5 minutes)
```bash
cd ~/Desktop/Zephyrus\ OS/kde-setup/scripts
./rebase-to-kde.sh
# Type: YES
```

### Step 2: Reboot
```bash
systemctl reboot
```
Your system will now boot into KDE Plasma.

### Step 3: First Boot Setup (10 minutes)
After KDE loads:
1. Configure display (if needed)
2. Connect to WiFi
3. Run Zephyrus setup:
```bash
cd ~/Desktop/Zephyrus\ OS/kde-setup/scripts
./install-kde-zephyrus.sh
```

### Step 4: Configure Panels (15 minutes)

#### Top Panel (macOS-style menu bar)
```
1. Right-click desktop → Add Panel → Empty Panel
2. Drag panel to top of screen
3. Set height to 40px
4. Add widgets (click "+" or right-click panel):

   Left side:
   • Application Launcher (or custom menu)
   • Global Menu
   
   Center (optional):
   • Window Title
   
   Right side:
   • System Tray
   • Digital Clock
```

#### Bottom Dock
```
1. Add another panel at bottom
2. Set height to 60px
3. Add widgets:
   • Icon-only Task Manager
   • Spacer (to center icons)
4. Configure task manager:
   • Show only icons
   • Large icons (48px)
   • Group: Do not group
```

### Step 5: Apply ROG Theme
```
System Settings →
  ├── Appearance →
  │   ├── Colors → Select "Zephyrus ROG"
  │   ├── Application Style → Breeze
  │   ├── Icons → Choose ROG icon theme
  │   └── Plasma Style → Breeze
  │
  ├── Workspace Behavior →
  │   ├── Desktop Effects →
  │   │   ├── Enable: Blur
  │   │   ├── Enable: Transparency
  │   │   └── Window Open/Close animations
  │   └── Screen Locking (configure as desired)
  │
  ├── Window Management →
  │   ├── Window Decorations → Breeze (with transparency)
  │   └── KWin Scripts → Enable blur effects
  │
  └── Startup and Shutdown →
      └── Autostart → Add Zephyrus apps
```

## The Result

You will have:

### Top Bar
```
[ROG Menu] [File] [Edit] [View] [Window] [Help]         [WiFi] [Battery] [Tue Apr 24 11:27 AM]
```

### Bottom Dock
```
         [📁] [🎮] [📂] [💻] [🟢]         [🗑️]
```

### Windows
- Glass/translucent backgrounds
- ROG crimson accents
- macOS-style traffic lights
- Shadows and blur effects

## Perfecting The Experience

### Enable True Glass Effect
```bash
# Install Kvantum for better Qt theming
sudo rpm-ostree install kvantum

# In System Settings:
# Appearance → Application Style → Kvantum
# Select "Zephyrus-ROG" theme
```

### ROG Control Center Integration
```bash
# Make sure asusctl is installed
sudo rpm-ostree install asusctl supergfxctl

# KDE will show ROG settings in System Settings
```

### Animations
```
System Settings → Workspace Behavior → Desktop Effects
  ✅ Enable all animations
  ✅ Magic Lamp (minimize effect)
  ✅ Present Windows (mission control)
```

## File Locations

After setup:
```
~/.config/                    # KDE config
├── plasma-org.kde.plasma.desktop-appletsrc  # Panel config
├── kwinrc                     # Window manager
├── kcmfonts                   # Fonts
└── color-schemes/             # Color schemes
    └── Zephyrus-ROG.colors

~/.local/share/
├── plasma/desktoptheme/       # Plasma themes
├── color-schemes/             # Color schemes
└── icons/                     # Icon themes
```

## Troubleshooting

### Global menu not showing?
```bash
# For GTK apps:
sudo rpm-ostree install appmenu-gtk-module

# Log out and back in
```

### Glass effect not working?
```
System Settings → Display and Monitor → Compositor
  ✅ Enable compositor on startup
  ✅ OpenGL 3.1
```

### Icons too small?
```
Right-click panel → Configure Panel
  → Height: 60px
  → Icon size: Large
```

## The Complete Vision

With KDE Plasma, you finally get:

✅ **Perfect Global Menu** - Every app shows File/Edit/View in top bar
✅ **Glass Windows** - True transparency and blur
✅ **ROG Dock** - Bottom dock with custom icons
✅ **Factory Integration** - Everything feels built-in
✅ **ROG Hardware** - Native control panels
✅ **macOS Feel** - But faster and more powerful

This is what a "next-gen Linux distro for ROG" should feel like.

## Next Steps After Setup

1. **Test everything** - Open apps, check global menu
2. **Fine-tune theme** - Adjust colors, transparency
3. **Create custom icons** - ROG-themed app icons
4. **Package as ISO** - For distribution

**Ready to switch to KDE?** Run the rebase script!
