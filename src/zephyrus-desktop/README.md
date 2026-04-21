# Zephyrus Desktop Environment (ZDE)

## Vision
A complete macOS-inspired desktop environment built for ASUS ROG laptops, featuring:
- Custom top panel with global menu
- ROG-themed file manager (Zephyrus Files)
- Custom terminal (Zephyrus Terminal)
- Deep ROG hardware integration
- Clean, professional aesthetic

## Architecture

```
Zephyrus Desktop Environment
│
├── Core
│   ├── zephyrus-panel (Top bar with global menu)
│   ├── zephyrus-session (Session manager)
│   └── zephyrus-theme (Crimson theme engine)
│
├── Applications
│   ├── zephyrus-files (File manager)
│   ├── zephyrus-terminal (Terminal emulator)
│   ├── zephyrus-text (Text editor)
│   └── zephyrus-settings (System settings)
│
├── System Integration
│   ├── zephyrus-menu-service (Global menu API)
│   ├── zephyrus-rog-daemon (ROG hardware control)
│   └── zephyrus-power (Power management)
│
└── Shell Components
    ├── Panel/Top Bar
    ├── Dock
    └── Desktop
```

## Development Phases

### Phase 1: Top Panel Overhaul (2-3 weeks)
- ROG logo with full menu
- Global menu system
- System tray redesign
- Apple-style menu bar

### Phase 2: File Manager (3-4 weeks)
- Two-pane view (like Finder)
- ROG theme
- Quick preview
- Tags/categories

### Phase 3: Terminal (2 weeks)
- Custom theme
- ROG colors
- Split panes
- Hardware info display

### Phase 4: Integration (2 weeks)
- Session management
- Settings app
- ROG Control Center integration

**Total: 9-11 weeks for full system**

## Why Build This?

1. **No existing solution** fits the ROG aesthetic
2. **Full control** over the experience
3. **Showcase project** for Zephyrus OS
4. **Unique selling point** vs other distros

## Technology Stack

- **Language:** Rust (performance) + Python (prototyping)
- **GUI Toolkit:** GTK4 + libadwaita
- **Graphics:** Cairo/Pango for custom rendering
- **Shell:** Custom GNOME Shell or new Wayland compositor

## Status

🚧 **Phase 1: Top Panel Overhaul** - In Progress
