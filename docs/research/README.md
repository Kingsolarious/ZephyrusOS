# Zephyrus OS - KDE Plasma Edition

**ROG-themed macOS-style Linux distribution for ASUS Zephyrus laptops**

![KDE Plasma 6](https://img.shields.io/badge/KDE-Plasma%206-blue)
![Based on Bazzite](https://img.shields.io/badge/Based%20On-Bazzite-orange)
![macOS Style](https://img.shields.io/badge/Style-macOS%20Like-silver)

## 🎮 Overview

Zephyrus OS transforms your ASUS ROG laptop into a sleek, macOS-inspired powerhouse running KDE Plasma 6 with full ROG hardware integration.

### Key Features

- 🍎 **macOS-style interface** with top menu bar and centered dock
- 🎨 **ROG Crimson theme** with custom color schemes
- ⚡ **Full hardware control** - Fan curves, GPU switching, LED effects
- 🖥️ **Global Menu** support for native macOS-like app menus
- 🎮 **Custom macOS Dock** with magnification and animations
- 🔧 **ASUS Linux integration** - asusctl, anime matrix (supergfxctl deprecated)

## 🚀 Quick Start

```bash
# Check system status
zephyrus-os-tool status

# Launch macOS-style dock
zephyrus-os-tool dock-restart

# About This Zephyrus
zephyrus-about

# ROG Control Center (hardware settings)
rog-control-center
```

## 📁 Project Structure

```
Zephyrus OS/
├── kde-setup/              # KDE configuration scripts
│   └── scripts/
│       ├── apply-macos-theme.sh
│       └── install-kde-zephyrus.sh
├── zephyrus-dock/          # Custom macOS dock (Python/PyQt6)
│   ├── macos-dock.py
│   └── README.md
├── zephyrus-about/         # About This Zephyrus app
├── zephyrus-desktop/       # Desktop utilities
├── icons/                  # ROG icon themes
├── theme/                  # GTK themes
└── docs/                   # Documentation
```

## 🛠️ Management Tools

### zephyrus-os-tool

Main management utility:

```bash
zephyrus-os-tool status        # Show system status
zephyrus-os-tool dock          # Toggle dock on/off
zephyrus-os-tool dock-restart  # Restart dock
zephyrus-os-tool performance   # Set performance mode
zephyrus-os-tool balanced      # Set balanced mode
zephyrus-os-tool quiet         # Set quiet mode
```

### zephyrus-slash

Control the Slash LED bar:

```bash
zephyrus-slash on              # Enable LED bar
zephyrus-slash off             # Disable LED bar
zephyrus-slash mode Spectrum   # Rainbow effect
zephyrus-slash mode Phantom    # Ghost effect
```

### asusctl

Command-line hardware control:

```bash
asusctl profile performance    # Performance mode
asusctl profile balanced       # Balanced mode
asusctl slash --enable         # Enable slash LED
asusctl fan-curve --help       # Fan control
```

## 🎨 Customization

### macOS Dock

Right-click the dock → **Settings** to configure:

- **Position**: bottom, left, right
- **Icon Size**: 32-128 pixels
- **Magnification**: 100-250%
- **Auto-hide**: Enable/disable

### KDE Theme

System Settings → Appearance:

- **Global Theme**: macOS-Dark (included)
- **Color Scheme**: ZephyrusCrimson (included)
- **Window Decorations**: Breeze with left-side buttons

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [MACOS_APPLE_LOOK_GUIDE.md](MACOS_APPLE_LOOK_GUIDE.md) | macOS setup guide |
| [KDE_ROG_COMPLETE.md](KDE_ROG_COMPLETE.md) | KDE configuration reference |
| [KDE_SETUP_GUIDE.md](KDE_SETUP_GUIDE.md) | Quick start guide |
| [ZEPHYRUS_CRIMSON_SPEC.md](ZEPHYRUS_CRIMSON_SPEC.md) | Technical specifications |

## 🖥️ Requirements

- ASUS ROG Zephyrus laptop (G14/G16/M16 series)
- Bazzite (Fedora Kinoite-based)
- KDE Plasma 6
- Wayland session

## 🐛 Known Issues

- **ROG Control Center dark mode**: Bug in Slint framework, `dark_mode: true` is ignored
- **Workaround**: Use `asusctl` CLI in dark terminal

## 🤝 Credits

- [ASUS Linux](https://asus-linux.org/) - Hardware support
- [Bazzite](https://bazzite.gg/) - Base distribution
- [KDE Plasma](https://kde.org/plasma-desktop) - Desktop environment

## 📜 License

This project is provided as-is for ROG laptop users. See LICENSE file for details.

---

**Enjoy your Zephyrus OS experience!** 🎮
