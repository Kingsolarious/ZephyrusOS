# Zephyrus Crimson Edition - Implementation Specification

## Project Overview

Transform Bazzite (GNOME 49) into a fully branded ASUS ROG Zephyrus Crimson Edition OS with macOS-style global menu behavior, OEM-level system branding, and complete visual identity replacement.

**Target Platform:** Bazzite (Fedora Silverblue-based) with GNOME 49  
**Hardware Target:** ASUS ROG Zephyrus G16 (2024)  
**Status:** Multi-module system architecture specification

---

## Module 1: Global Menu Bar Extension

### Objective
Replicate macOS global menu behavior with inline menu items, ROG branding, and system menu integration.

### Technical Requirements
- GNOME Shell 49 compatible extension
- GMenuModel DBus parsing for real GTK app menus
- Dynamic menu updates on window focus change
- Wayland-compatible implementation

### File Structure
```
~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/
├── metadata.json
├── extension.js
├── stylesheet.css
└── assets/
    └── rog-eye-symbolic.svg
```

### metadata.json
```json
{
  "uuid": "zephyrus-globalmenu@solarious",
  "name": "Zephyrus Global Menu",
  "description": "Inline macOS-style GTK global menu for GNOME 49 with ROG branding",
  "shell-version": ["49"],
  "version": 3,
  "stylesheet": "stylesheet.css"
}
```

### Core Functionality Requirements

#### 1.1 ROG System Menu Button
- Position: Leftmost element in global menu container
- Icon: White/light gray SVG (tinted via CSS)
- Click behavior: Opens system dropdown menu

**System Menu Items:**
| Label | Action |
|-------|--------|
| About This Zephyrus | Launch zephyrus-about GTK app |
| System Settings | `gnome-control-center` |
| --- | Separator |
| Lock | `loginctl lock-session` |
| Restart | `systemctl reboot` |
| Shut Down | `systemctl poweroff` |

#### 1.2 Dynamic App Menu Parsing
- Listen for `notify::focus-window` signal
- Query DBus for `org.gtk.Menus` interface
- Extract menu layout from `/org/gtk/menus/appmenu`
- Render top-level items inline (File, Edit, View, etc.)
- Each item opens its own submenu popup

#### 1.3 DBus Menu Integration
```javascript
// Required DBus call pattern
Gio.DBus.session.call(
    appId,                          // GTK application ID
    "/org/gtk/menus/appmenu",       // Menu object path
    "org.gtk.Menus",                // Interface
    "GetLayout",                    // Method
    new GLib.Variant("(u)", [0]),   // Arguments (root menu)
    null,                           // Reply type
    Gio.DBusCallFlags.NONE,
    -1,                             // Timeout
    null,                           // Cancellable
    callback
);
```

### Styling Requirements

#### Container
```css
.zephyrus-menu-container {
    spacing: 22px;
    padding-left: 14px;
    align-items: center;
}
```

#### ROG Logo
```css
.zephyrus-rog-button {
    background: transparent;
    padding: 6px 10px;
    border-radius: 8px;
}

.zephyrus-rog-button:hover {
    background-color: rgba(255, 0, 0, 0.15);
    box-shadow: 0 0 6px rgba(255, 0, 0, 0.5);
    transition: 150ms ease-in-out;
}
```

#### Menu Items
```css
.zephyrus-menu-button {
    background: transparent;
    border-radius: 0px;
    padding: 6px 8px;
}

.zephyrus-menu-label {
    color: #e6e6e6;
    font-weight: 500;
    letter-spacing: 0.4px;
}

.zephyrus-menu-button:hover .zephyrus-menu-label {
    color: #ffffff;
}

.zephyrus-menu-button:hover {
    border-bottom: 2px solid #ff1a1a;
    box-shadow: 0 3px 8px rgba(255, 0, 0, 0.4);
    transition: 160ms ease-in-out;
}
```

### Known Limitations
- GTK4 apps may not expose traditional menus
- Electron apps support varies
- Some modern apps (GTK4/libadwaita) use headerbars instead of menus

---

## Module 2: About This Zephyrus (GTK4 Application)

### Objective
Replace GNOME Settings "About" page with custom OEM hardware information panel.

### Technical Stack
- GTK 4.0
- Python 3 with PyGObject
- libadwaita for styling
- Hardware detection via sysfs and system calls

### File Structure
```
~/zephyrus-oem/
├── about.py
├── style.css
└── assets/
    └── rog-eye-large.svg
```

### Hardware Detection Matrix

| Data Point | Source Command/Path |
|------------|---------------------|
| CPU Model | `platform.processor()` |
| Memory | `psutil.virtual_memory().total` |
| GPU | `lspci \| grep VGA` |
| NVIDIA Driver | `nvidia-smi --query-gpu=driver_version --format=csv,noheader` |
| Display Resolution | `xrandr \| grep '*'` or Mutter API |
| Refresh Rate | Parse from xrandr output |
| Panel Model | `/sys/class/drm/card0-eDP-1/edid` (parse EDID) |
| Serial Number | `/sys/class/dmi/id/product_serial` |
| BIOS Version | `/sys/class/dmi/id/bios_version` |
| Kernel | `uname -r` |
| Battery Health | Parse from `upower` or sysfs |

### UI Layout Specification

```
+------------------------------------------+
|                                          |
|            [ROG EYE LOGO]                |
|              (80px, centered)            |
|                                          |
|        ROG Zephyrus G16 (2024)           |
|         Zephyrus Crimson Edition         |
|                                          |
|  --------------------------------------  |
|                                          |
|  CPU:            Intel Core i9-14900HX   |
|  Memory:         32 GB DDR5-5600         |
|  Graphics:       NVIDIA GeForce RTX 4090 |
|  NVIDIA Driver:  550.XX                  |
|  Display:        16" OLED 240Hz          |
|  Resolution:     2560x1600               |
|  Serial Number:  XXXXXXXX                |
|  BIOS:           315.XX                  |
|                                          |
+------------------------------------------+
```

### CSS Styling
```css
window {
    background-color: #0d0d0d;
    color: #ffffff;
}

label {
    font-size: 14px;
}

.title-1 {
    font-size: 24px;
    font-weight: 700;
}

separator {
    margin-top: 10px;
    margin-bottom: 10px;
    background-color: #2a0000;
}

/* Optional animated glow */
@keyframes pulse {
    0% { opacity: 0.8; }
    50% { opacity: 1; }
    100% { opacity: 0.8; }
}
```

### Integration Points
- Desktop entry: `zephyrus-about.desktop`
- Override GNOME Settings about panel
- Launch from global menu ROG button
- Bind to keyboard shortcut (optional)

---

## Module 3: ROG Crimson Theme

### Objective
Complete visual identity layer with red-black ASUS industrial aesthetic.

### Color Palette

| Purpose | Hex Value | Usage |
|---------|-----------|-------|
| Background Primary | `#0a0000` | Windows, panels |
| Background Secondary | `#140000` | Sidebars, cards |
| Accent Red | `#ff0033` | Primary accent |
| Accent Hover | `#ff1a4d` | Hover states |
| Glow Red | `rgba(255, 0, 0, 0.4)` | Shadows, glows |
| Text Primary | `#ffffff` | Primary text |
| Text Secondary | `#e6e6e6` | Secondary text |
| Border Red | `#2a0000` | Subtle borders |

### Theme Components

#### GTK4 Theme
- Location: `/usr/local/share/themes/Zephyrus-Crimson/gtk-4.0/`
- Files: `gtk.css`, `gtk-dark.css`
- Override libadwaita accent color

#### GNOME Shell Theme
- Location: `/usr/local/share/themes/Zephyrus-Crimson/gnome-shell/`
- Files: `gnome-shell.css`, `gnome-shell-theme.gresource`
- Override panel, menus, dialogs

#### Icon Theme (Optional)
- ROG-styled folder icons
- Red-accented system icons
- Crimson variant of Papirus or similar

### Key Overrides

#### Panel
```css
#panel {
    background-color: rgba(10, 0, 0, 0.95);
    box-shadow: 0 2px 8px rgba(255, 0, 0, 0.2);
}
```

#### Popover Menus
```css
.popup-menu-boxpointer {
    background-color: rgba(18, 18, 18, 0.98);
    border: 1px solid #2a0000;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(255, 0, 0, 0.15);
}

.popup-menu-item:hover {
    background-color: rgba(255, 0, 0, 0.12);
}
```

---

## Module 4: GDM Login Screen Theme

### Objective
Replace GNOME branding with Zephyrus Crimson identity on login screen.

### Technical Approach
- Override GDM shell theme via gresource
- Custom CSS for `#lockDialogGroup`
- ROG eye logo centered
- Crimson radial gradient background

### File Locations
```
/usr/local/share/gnome-shell/theme/
├── gnome-shell.css (modified)
├── gnome-shell-theme.gresource (compiled)
└── assets/
    ├── zephyrus-crimson-bg.jpg
    └── rog-eye.svg
```

### CSS Requirements
```css
#lockDialogGroup {
    background: radial-gradient(
        circle at center, 
        #0a0000 0%, 
        #140000 40%, 
        #000000 100%
    );
}

.login-logo {
    background-image: url("file:///usr/local/share/rog-branding/rog-eye.svg");
    background-size: contain;
    background-repeat: no-repeat;
    background-position: center;
    width: 128px;
    height: 128px;
}
```

### Configuration
- `/etc/gdm/custom.conf`: Enable Wayland, set theme path
- Update gresource binary with custom assets
- Ensure SELinux contexts are correct (Fedora)

---

## Module 5: Plymouth Boot Splash

### Objective
Animated Zephyrus Crimson boot animation replacing default Fedora/OSTree spinner.

### Theme Structure
```
/usr/share/plymouth/themes/zephyrus-crimson/
├── zephyrus-crimson.plymouth
├── zephyrus.script
└── assets/
    ├── rog-eye.png
    ├── rog-eye-glow.png
    └── background.png
```

### Theme File (zephyrus-crimson.plymouth)
```ini
[Plymouth Theme]
Name=Zephyrus Crimson
Description=ROG Zephyrus OEM Boot Animation
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/zephyrus-crimson
ScriptFile=/usr/share/plymouth/themes/zephyrus-crimson/zephyrus.script
```

### Animation Script Requirements
- Black background
- Red glow emerges from center
- ROG eye fades in with scale animation
- Subtle pulse during boot
- Smooth fade out transition to GDM

### Installation
```bash
sudo plymouth-set-default-theme zephyrus-crimson -R
dracut -f  # Regenerate initramfs
```

---

## Implementation Phases

### Phase 1: Global Menu Extension
1. Create extension directory structure
2. Implement metadata.json
3. Build extension.js with DBus menu parsing
4. Add ROG system menu
5. Create stylesheet.css with OEM styling
6. Test and debug on target system

### Phase 2: About Application
1. Create Python GTK4 application
2. Implement hardware detection functions
3. Design UI layout with ROG branding
4. Add CSS styling
5. Create desktop entry
6. Integrate with global menu

### Phase 3: Theme Layer
1. Create GTK4 theme with red accent
2. Build GNOME Shell theme
3. Package theme files
4. Install to system directories

### Phase 4: GDM Override
1. Extract and modify GDM theme
2. Add custom branding assets
3. Recompile gresource
4. Update GDM configuration
5. Test login screen

### Phase 5: Plymouth Theme
1. Create theme structure
2. Write animation script
3. Prepare assets
4. Install and test boot animation

---

## Dependencies

### Build Dependencies
```bash
# Extension development
sudo rpm-ostree install gnome-shell-devel gjs

# GTK/Python app
sudo rpm-ostree install python3-gtk4 python3-gobject libadwaita

# GDM theme
sudo rpm-ostree install gdm-tools

# Plymouth
sudo rpm-ostree install plymouth plymouth-devel

# Utilities
sudo rpm-ostree install psutil lm_sensors pciutils
```

### Python Packages
```bash
pip install --user psutil pygobject
```

---

## File References

| File | Purpose |
|------|---------|
| `extension/metadata.json` | Extension manifest |
| `extension/extension.js` | Main extension code |
| `extension/stylesheet.css` | Extension styling |
| `zephyrus-oem/about.py` | About application |
| `zephyrus-oem/style.css` | About app styling |
| `theme/gtk.css` | GTK4 theme |
| `theme/gnome-shell.css` | Shell theme |
| `gdm/gdm-theme.css` | Login screen theme |
| `plymouth/zephyrus.script` | Boot animation |

---

## Testing Checklist

- [ ] Extension loads without errors in GNOME 49
- [ ] Global menu updates on window focus change
- [ ] Menu items are clickable and functional
- [ ] ROG system menu opens and all items work
- [ ] About app detects all hardware correctly
- [ ] About app launches from global menu
- [ ] Theme applies to GTK4 applications
- [ ] Shell theme applies (panel, menus)
- [ ] GDM shows ROG branding
- [ ] Plymouth animation displays during boot
- [ ] All transitions are smooth
- [ ] No SELinux denials
- [ ] System remains bootable

---

## Rollback Plan

1. **Extension:** `gnome-extensions disable zephyrus-globalmenu@solarious`
2. **Theme:** Switch to default in Settings → Appearance
3. **GDM:** Restore from backup gresource
4. **Plymouth:** `sudo plymouth-set-default-theme spinner -R`

---

## Notes

- This is an OSTree-based system (Bazzite) - use `rpm-ostree` for system packages
- Changes to `/usr` may be overwritten on updates - prefer `/usr/local` or `/etc`
- GDM theme requires root access and careful gresource handling
- Plymouth theme requires initramfs regeneration
- Test each module independently before integration

---

**Document Version:** 1.0  
**Last Updated:** 2026-03-04  
**Target Release:** Zephyrus Crimson Edition v1.0
