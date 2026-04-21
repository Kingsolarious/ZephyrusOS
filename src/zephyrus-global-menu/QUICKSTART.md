# Zephyrus Global Menu - Quick Start

## What Is This?

A **custom global menu system** built from scratch for Zephyrus OS that works on GNOME 49+ where other solutions have broken.

## How It Works

1. **GTK Module** (`zephyrus-gtk-menu.so`) - Hooks into GTK apps and exports their menus
2. **D-Bus Service** (`zephyrus-menu-service.py`) - Central service that collects all menus
3. **GNOME Extension** (`extension.js`) - Displays the menu in the top panel

## Build & Install

```bash
cd ~/Desktop/Zephyrus\ OS/zephyrus-global-menu
chmod +x setup.sh
./setup.sh
```

## Usage

### Test with an app:
```bash
# Run Firefox with menu export
LD_PRELOAD=$HOME/.local/lib/zephyrus-menu/zephyrus-gtk-menu.so firefox
```

### Set globally:
Add to `~/.bashrc`:
```bash
export LD_PRELOAD=$HOME/.local/lib/zephyrus-menu/zephyrus-gtk-menu.so
```

### Start the service:
```bash
systemctl --user start zephyrus-menu.service
```

## Current Status

✅ **Working:**
- D-Bus communication
- Basic menu structure export
- Shell extension UI

⚠️ **Needs Work:**
- Menu item actions (clicking)
- Submenu support
- Qt application support
- Automatic app detection

## Development Timeline

- **Week 1:** Core functionality (DONE)
- **Week 2:** Menu actions & submenus
- **Week 3:** Qt support & polish
- **Week 4:** Testing & packaging

## Alternative

If this is too complex, consider switching Zephyrus OS to **KDE Plasma** which has perfect global menu support built-in.

## Support

This is a custom-built system for Zephyrus OS. It's experimental but functional!
