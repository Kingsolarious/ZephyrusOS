# ROG Zephyrus G16 GU605MY — Internal Keyboard Deep Dive

**Date:** 2026-04-16  
**Model:** ASUS ROG Zephyrus G16 GU605MY  
**Keyboard Layout:** US English (centered, no numpad)  
**Keyboard Type:** Backlit Chiclet Keyboard — **1-Zone RGB**

---

## Executive Summary

The GU605MY uses a **single-zone RGB keyboard** controlled by the **ASUS ITE 8910 embedded controller** (`USB VID:PID 0B05:19B6`). It does **not** have per-key RGB, 4-zone RGB, or dedicated macro keys. All keys share one color at a time.

**Good news for Linux:** this exact controller (`0b05:19b6`) is supported by the open-source Linux tool `rogauracore`, and basic brightness/color control works through `asusctl` / `rog-control-center`.

---

## 1. Physical Keyboard Layout

### Key Layout Details (confirmed via Armoury Crate assets + web specs)

| Feature | Detail |
|---------|--------|
| **Layout** | Standard US QWERTY, centered on chassis |
| **Numpad** | **No** — compact 16-inch layout |
| **Arrow keys** | Half-sized inverted-T in the bottom-right |
| **Media keys** | **4 media keys** above the left side of the keyboard deck (flush with chassis) |
| **ROG key** | Dedicated Armoury Crate launch key |
| **Macro keys (M1–M5)** | **None** on this model — the G16 does not have the left-side macro column found on ROG Strix SCAR/Flow models |
| **Key travel** | ~1.7 mm |
| **Keycap style** | Square chiclet with a small tactile dash on each cap |
| **Backlight** | White/RGB LEDs with central placement under each key |

### Why the "4keys" / "5keys" images exist in Armoury Crate
Armoury Crate's `AC_CustomHotkey` module contains UI assets for `asus_ac_hotkey_4keys_illustration_bg` and `asus_ac_hotkey_5keys_illustration_bg`. These are for **other ASUS laptop models** (e.g., ROG Strix SCAR, Flow) that physically have 4 or 5 macro keys on the left side of the deck. The GU605MY uses the standard `asus_ac_hotkey_illustration_bg` asset.

---

## 2. RGB Lighting Hardware

### Controller Chip
- **USB Device:** `ASUS ITE Device(8910)`
- **VID:PID:** `0B05:19B6`
- **HID Collections:** Multiple (`COL01` through `COL0B`) exposing keyboard input, consumer control, and lighting control interfaces
- **Secondary ASUS EC:** `0B05:193B` (also ITE 8910, related to slash lighting / embedded controller)

### Lighting Type
- **Official spec:** **1-Zone RGB** (the entire keyboard shares one color simultaneously)
- **NKeyType log value:** `4` — this is an internal ASUS classification, but the actual hardware is **1-zone**
- **Armoury Crate detection string:** `WDL_NB_KB_4ZONE_RGB_LIGHTING/GU605MY=Checked` — again, this is ASUS's internal software flagging, but hardware reviews and the official ASUS product page confirm **1-zone RGB**

### Supported Lighting Effects (Windows / Armoury Crate)
The following effects are exposed in Armoury Crate's `Aura.ini` and `Plugin_Status.ini` for this device:

1. **Static** — solid color
2. **Breathing** — fade in/out
3. **Strobing** — rapid flash
4. **Color Cycle** — rotate through spectrum
5. **Rainbow** — rainbow wave
6. **Comet** — trailing light effect
7. **Flash and Dash** — streaking flashes
8. **Star** — twinkling starfield
9. **Rain** — downward falling lights
10. **Reactive** — keys light up on press (all keys same color)
11. **Laser** — horizontal beam sweep
12. **Ripple** — ripple outward from keypress
13. **Music** / **Audio Analyzer** — reacts to system audio
14. **Smart** / **Temperature** — changes color based on CPU temp
15. **Blade** — directional sweep
16. **Starry Night** — slow twinkle
17. **AURA SYNC** — syncs with other ASUS RGB devices
18. **Customize** — user-defined static color
19. **ASUS 30th** — special anniversary effect
20. **Dark** — backlight off
21. **Adaptive Color** / **Screen Extension** — samples colors from screen
22. **Animation Mode** / **System Mode** — Slash lighting integration

> **Note:** Because this is a 1-zone keyboard, effects like Reactive and Ripple are limited — the entire keyboard changes color together rather than individual keys responding.

### Brightness Levels
The keyboard supports **4 brightness levels** (0 = off, 1–3 = increasing brightness). This is controlled via the `asus::kbd_backlight` WMI interface on Linux.

---

## 3. Key Binding & Macro Programming

### Armoury Crate Capabilities
Armoury Crate provides a **"Custom Hotkey"** and **"Macro"** module, but on the GU605MY these features are **limited** because there are no dedicated macro keys.

#### What you *can* do on Windows:
- **Remap the 4 media keys** (if Armoury Crate exposes them for this model)
- **Record macros** and assign them to existing keys via software overlay (not hardware-level)
- **ROG Key remap** — change what the Armoury Crate key does
- **Fn key combinations** — some models allow remapping Fn+F12, Fn+Space, etc.
- **Windows key disable** — toggle Win key lock

#### What you *cannot* do:
- **Hardware-level macro keys** — there are no physical M1–M5 keys to bind
- **Per-key remapping of the entire layout** — Armoury Crate does not support full key rebinding for this chiclet keyboard

### Macro Files Status
Probe of `C:\Users\kings\AppData\Local\Packages\B9ECED6F.ArmouryCrate_qmba6cd70vzyy\LocalState\MacroFiles` showed **only an empty `Temp` folder**, meaning no custom macros are currently saved.

---

## 4. Linux Compatibility & How to Control It

### 4.1 Basic Control: `asusctl` / `rog-control-center`
The ASUS Linux stack supports this laptop well for basic keyboard backlight control.

```bash
# Install on CachyOS / Arch:
sudo pacman -S asusctl rog-control-center

# Set keyboard backlight brightness (0-3):
asusctl -k 0   # off
asusctl -k 1   # low
asusctl -k 2   # medium
asusctl -k 3   # high

# Set static color:
asusctl led-mode static -c ff0000   # red
asusctl led-mode static -c 00ff00   # green
asusctl led-mode static -c 0000ff   # blue

# Other modes supported by asusctl:
asusctl led-mode breathing
asusctl led-mode rainbow
```

> **Important:** On some kernels, you need to ensure `asus-nb-wmi` is loaded:
> ```bash
> sudo modprobe asus-nb-wmi
> ```
> Add it to `/etc/mkinitcpio.conf` or your initramfs modules if it doesn't load automatically.

### 4.2 Advanced Control: `rogauracore`
Because the GU605MY uses the **`0b05:19b6`** controller, it is explicitly supported by `rogauracore` (the open-source reverse-engineered ROG Aura Core tool).

```bash
# Install on Arch:
yay -S rogauracore

# Initialize the keyboard controller (do this first if it's unresponsive):
sudo rogauracore initialize_keyboard

# Set brightness:
sudo rogauracore brightness 3

# Static color:
sudo rogauracore single_static ff0000   # red
sudo rogauracore single_static 00ff00   # green

# Breathing effect:
sudo rogauracore single_breathing ff0000 0000ff  # red to blue

# Rainbow cycle:
sudo rogauracore rainbow_cycle

# Multi-zone static (even though it's 1-zone, this may still work):
sudo rogauracore multi_static ff0000 ffff00 00ff00 00ffff
```

If `rogauracore` causes the backlight control to become unresponsive in `rog-control-center`, restart `upower`:
```bash
sudo systemctl restart upower.service
```

### 4.3 Alternative: OpenRGB
`OpenRGB` also detects the ITE 8910 device as "Asus Aura Core Laptop" and can set direct colors.

```bash
sudo pacman -S openrgb
sudo openrgb --device 0 --color ff0000
```

### 4.4 Slash Lighting (Lid LED)
The GU605MY has the **ROG Slash LED** on the lid (also called AniMe Vision). On Linux:

```bash
# rog-control-center has a "Slash" tab for this.
# Or via command line:
asusctl slash -e true   # enable
asusctl slash -e false  # disable
```

The Slash lighting content files are stored at:
`C:\Users\kings\AppData\Local\Packages\B9ECED6F.ArmouryCrate_qmba6cd70vzyy\LocalState\SlashKit\GU605\Content\`

These are proprietary `.slashlighting` binary files and cannot be directly imported into Linux tools, but `rog-control-center` supports basic animations for the slash LED.

---

## 5. Summary Table

| Feature | Windows (Armoury Crate) | Linux |
|---------|------------------------|-------|
| **Backlight ON/OFF** | ✅ Yes | ✅ `asusctl -k 0/3` |
| **Brightness levels** | ✅ 4 levels | ✅ 4 levels |
| **Static color** | ✅ Yes | ✅ `asusctl` / `rogauracore` |
| **Breathing** | ✅ Yes | ✅ `rogauracore` |
| **Rainbow / Color Cycle** | ✅ Yes | ✅ `rogauracore` / `asusctl` |
| **Reactive / Ripple** | ✅ Yes (1-zone limited) | ❌ Not supported on Linux |
| **Music / Temp effects** | ✅ Yes | ❌ Not supported on Linux |
| **Aura Sync** | ✅ Yes | ❌ Not supported |
| **Per-key customization** | ❌ No (1-zone hardware) | ❌ No (1-zone hardware) |
| **Macro keys** | ❌ No physical macro keys | ❌ No physical macro keys |
| **Slash lighting** | ✅ Yes | ✅ `rog-control-center` basic support |

---

## 6. Bottom Line

- Your GU605MY keyboard is **1-zone RGB**, controlled by the **ITE 8910 (`0B05:19B6`)**.
- It has **no dedicated macro keys** and **no per-key RGB**.
- On Linux, you can reliably control **brightness, static colors, breathing, and rainbow effects** using `asusctl`, `rog-control-center`, and `rogauracore`.
- Complex Armoury Crate-exclusive effects (Reactive, Music, Temperature, Aura Sync) **do not have Linux equivalents** for this controller.
- If you want full lighting control on Linux, the winning combo is:
  1. `asusctl` for brightness and platform profiles
  2. `rogauracore` for color effects
  3. `rog-control-center` for GUI control + Slash LED
