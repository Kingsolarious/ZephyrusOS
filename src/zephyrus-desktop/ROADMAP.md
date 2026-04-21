# Zephyrus Desktop Environment - Development Roadmap

## Phase 1: Top Panel Overhaul (Weeks 1-3) ✅ STARTED
### Status: Core structure complete

**Components:**
- ✅ ZephyrusPanel class with full layout
- ✅ ROG logo button with system menu
- ✅ App menu (application name display)
- ✅ Global menu placeholders (File, Edit, View, etc.)
- ✅ Clock and system tray
- ✅ ROG status indicators

**TODO:**
- [ ] Connect global menu to actual apps
- [ ] Dynamic menu population from focused window
- [ ] Menu actions (what happens when you click)
- [ ] System tray integration (WiFi, battery, etc.)
- [ ] ROG hardware status (fan speed, temp, performance mode)

---

## Phase 2: File Manager - Zephyrus Files (Weeks 4-7)
### Status: Not started

**Features:**
- Two-pane layout (sidebar + main view)
- Column view (macOS Finder style)
- Icon view with large previews
- List view with details
- Tags and colors (like macOS)
- Quick Look preview (spacebar)
- Global search (Spotlight-style)
- ROG theme throughout

**Tech:**
- GTK4 + libadwaita
- Rust for backend
- Async file operations

---

## Phase 3: Terminal - Zephyrus Terminal (Weeks 8-9)
### Status: Not started

**Features:**
- Split panes (horizontal/vertical)
- Tabs with previews
- ROG color scheme (red on black)
- Hardware info display (CPU, GPU temps in status bar)
- Custom prompt with ROG logo
- Integrated file manager (open current dir)
- GPU-accelerated rendering

**Tech:**
- Based on GNOME Terminal or Alacritty
- Custom theme and config

---

## Phase 4: Global Menu System (Weeks 10-12)
### Status: Prototype exists

**Components:**
- GTK module (hooks into apps)
- Qt module (for Qt apps)
- D-Bus service (menu collection)
- Shell extension integration

**Apps to support:**
- GTK4 apps (Files, Terminal, etc.)
- Firefox
- VS Code
- LibreOffice
- All major apps

---

## Phase 5: Settings & Integration (Weeks 13-14)
### Status: Not started

**Zephyrus Settings App:**
- ROG Control Center integration
- Theme settings (Crimson, Dark, Light)
- Performance modes
- Keyboard RGB controls
- Display settings
- Network, sound, etc.

**Session Management:**
- Login screen (GDM theme)
- Lock screen
- Logout/shutdown dialogs

---

## Phase 6: Polish & Release (Weeks 15-16)
### Status: Not started

**Polish:**
- Animations and transitions
- Icon theme completion
- Documentation
- Installer
- OSTree integration

**Release:**
- Zephyrus OS 1.0
- ISO image
- Website
- Documentation

---

## Current Priority

**Right Now:**
1. Finish Phase 1 (Top Panel) - make it actually work
2. Connect menus to real apps
3. Get feedback on the layout

**Next:**
4. Start File Manager (Phase 2)

---

## Estimated Timeline

- **Total Project:** 16 weeks (4 months)
- **Working Desktop:** 8 weeks (2 months)
- **Full Release:** 16 weeks (4 months)

## What You Can Do Now

1. Install the panel:
   ```bash
   cd ~/Desktop/Zephyrus\ OS/zephyrus-desktop/panel
   ./install-panel.sh
   ```

2. Test it out and give feedback

3. Decide: continue with custom DE or switch to KDE?

---

## Decision Point

**Option A: Continue Building Custom DE**
- Pros: Full control, unique, exactly what you want
- Cons: 4 months work, maintenance burden

**Option B: Switch to KDE Plasma**
- Pros: Global menu works today, less work, still customizable
- Cons: Not fully custom

**My recommendation:** Try the panel I built, if you like it, continue. If not, switch to KDE.

What do you want to do?
