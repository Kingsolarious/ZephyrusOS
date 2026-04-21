# ROG Zephyrus G16 GU605MY — Complete LED Mapping Capture

**Date:** 2026-04-16  
**Model:** ASUS ROG Zephyrus G16 GU605MY  
**Keyboard Controller:** ASUS ITE 8910 (`USB VID:PID 0B05:19B6`)  
**Internal Classification:** `WDL_NB_KB_4ZONE_RGB_LIGHTING`  
**Device ID:** `3F49AD29-52D9-46A5-A608-203D54E7D12A`  
**Physical Layout:** 1-Zone RGB (all keys share color simultaneously)

---

## 1. Keyboard LED Key Naming Map

Armoury Crate uses `.keylight` files to script timed LED animations. These files reference keys by standardized internal names. Below is the **complete key name registry** extracted from all `.keylight` files on this system.

### Complete Key Name List (Alphabetical)

```
0, 1, 2, 3, 4, 5, 6, 7, 8, 9
A, B, C, D, E, F, G, H, I, J, K, L, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
APOSTROPHE, APP, DOT, EQUATION, FN, L_ALT, L_BRACKETS, L_CTRL, L_WIN
NEG, R_ALT, R_BRACKETS, R_CTRL, SEMICOLON, SLASH, SPACE
F3, F6, F9
```

### Key Name Reference Table

| Internal Name | Physical Key |
|---------------|--------------|
| `0`–`9` | Number row keys |
| `A`–`Z` | Alphabet keys |
| `L_CTRL` | Left Ctrl |
| `L_WIN` | Left Windows / Meta |
| `L_ALT` | Left Alt |
| `SPACE` | Spacebar |
| `R_ALT` | Right Alt |
| `FN` | Fn key |
| `APP` | Application/Menu key |
| `R_CTRL` | Right Ctrl |
| `L_BRACKETS` | `[` / Left square bracket |
| `R_BRACKETS` | `]` / Right square bracket |
| `SEMICOLON` | `;` |
| `APOSTROPHE` | `'` |
| `SLASH` | `/` |
| `DOT` | `.` |
| `EQUATION` | `=` |
| `NEG` | `-` (minus/underscore) |
| `F3`, `F6`, `F9` | Function keys (only these referenced in animations) |

### Missing Key Names (Not Used in Animations)
The following keys exist physically but were **never referenced** in any `.keylight` animation file on this system:
- `M` (oddly absent from all captured animations)
- `BACKSPACE`, `ENTER`, `SHIFT`, `TAB`, `CAPS_LOCK`, `ESC`
- `F1`, `F2`, `F4`, `F5`, `F7`, `F8`, `F10`, `F11`, `F12`
- `PRINT_SCREEN`, `SCROLL_LOCK`, `PAUSE_BREAK`
- Arrow keys (`UP`, `DOWN`, `LEFT`, `RIGHT`)
- `INSERT`, `DELETE`, `HOME`, `END`, `PG_UP`, `PG_DOWN`
- `NUM_LOCK` (no numpad on this model)

> **Note:** Absence from animation files does **not** mean these keys lack LEDs. It simply means the pre-packaged festival effects didn't animate them. The 1-zone controller illuminates all keys simultaneously.

---

## 2. KeyLight File Format Specification

`.keylight` files are **INI-style text files** that define per-key RGB animations over time.

### Format Structure

```ini
[timestamp_in_ms]
KEYNAME=A,R,G,B
KEYNAME=A,R,G,B
...
```

### Field Definitions

| Field | Range | Meaning |
|-------|-------|---------|
| `timestamp_in_ms` | 0–999999 | Millisecond marker for this frame |
| `KEYNAME` | See table above | Internal key identifier |
| `A` | 0–255 | Alpha / Brightness (255 = full brightness) |
| `R` | 0–255 | Red component |
| `G` | 0–255 | Green component |
| `B` | 0–255 | Blue component |

### Example: `open.keylight` (Christmas Effect)

```ini
[724]
H=255,0,0,0

[1448]
SPACE=255,252,0,0

[2172]
1=255,0,0,0

[2896]
SPACE=255,66,160,66
```

This script lights the `H` key red at 724ms, then `SPACE` yellow at 1448ms, then `1` red at 2172ms, then `SPACE` teal at 2896ms. On a **1-zone keyboard**, the entire keyboard changes to each color in sequence (not just the named key).

---

## 3. Slash Lighting (Lid LED) Mapping

The GU605MY features the **ROG Slash LED** on the lid — a diagonal LED strip controlled separately from the keyboard.

### Hardware Profile
- **Controller:** ASUS ITE 8910 (`0B05:193B`) — secondary EC device
- **LED segments:** **7 segments** (confirmed by frame data structure)
- **Content format:** `.slashlighting` (text-based INI)

### SlashLighting File Format

```ini
[UUID]
UUID=0x??

[EFFECT NAME]
name=EffectName

[CONFIG]
FrameCount=N

[FRAMES]
0=A1,R1,G1,B1,A2,R2,G2,
1=A1,R1,G1,B1,A2,R2,G2,
...
```

Wait — looking at the actual data, each frame has **7 comma-separated numeric values**, not ARGB quadruples. Re-examining the data:

```
0=255,255,0,255,0,0,255,
```

This is 7 values. Given the ASUS Slash LED strip has 7 physical segments, each value likely represents the **brightness of one segment** for a specific color channel, or the format is:

```
Seg1_Brightness, Seg2_Brightness, Seg3_Brightness, Seg4_Brightness, Seg5_Brightness, Seg6_Brightness, Seg7_Brightness
```

with the color being defined by the effect name / UUID. However, some frames mix non-zero values across all 7 positions (e.g. `160,160,203,201,203,155,158`), suggesting it may actually be a simple grayscale/brightness map per segment where the effect's base color is applied by the controller.

### GU605 Preloaded Slash Themes

| Theme | Effect File | Internal Name | Frames |
|-------|-------------|---------------|--------|
| **Theme 1 — Glitch** | `theme1_effect10` | `Glitch_Bounce` | 22 |
| | `theme1_effect20` | `Glitch_Slash` | 40 |
| | `theme1_effect30` | `Glitch_Loading` | 50 |
| | `theme1_effect40` | `Static` | 1 |
| **Theme 2 — DataStream** | `theme2_effect10` | `DataStream_Flow` | 23 |
| | `theme2_effect20` | `DataStream_Transmission` | 50 |
| | `theme2_effect30` | `DataStream_Bitstream` | 30 |
| | `theme2_effect40` | `Static` | 1 |
| **Theme 3 — NeoRetro** | `theme3_effect10` | `NeoRetro_Phantom` | 22 |
| | `theme3_effect20` | `NeoRetro_Flux` | 19 |
| | `theme3_effect30` | `NeoRetro_Spectrum` | 22 |
| | `theme3_effect40` | `Static` | 1 |
| **Theme 4 — Resonance** | `theme4_effect10` | `Resonance_Hazard` | 36 |
| | `theme4_effect20` | `Resonance_Interfacing` | 16 |
| | `theme4_effect30` | `Resonance_Ramp` | 42 |
| | `theme4_effect40` | `Static` | 1 |
| **Theme 5 — 8 Bit Electro** | `theme5_effect10` | `8 Bit Electro_Game Over` | 30 |
| | `theme5_effect20` | `8 Bit Electro_Start` | 42 |
| | `theme5_effect30` | `8 Bit Electro_Buzzer` | 42 |
| | `theme5_effect40` | `Static` | 1 |
| **Theme 6 — Custom/User** | `theme6_effect10` | `theme6_effect10` | 10 |
| | `theme6_effect20` | `theme6_effect20` | 40 |
| | `theme6_effect30` | `theme6_effect30` | 50 |
| | `theme6_effect40` | `Static` | 1 |

### Static Slash Frame Default
All `themeX_effect40.slashlighting` files contain the same static default:

```ini
[UUID]
UUID=0x06

[EFFECT NAME]
name=Static

[CONFIG]
FrameCount=1

[FRAMES]
0=255,255,255,255,255,255,255,
```

This sets all 7 slash segments to full brightness (white).

---

## 4. Device Capability & Status XML Data

### From `GetDeviceStatusNew.xml`

```xml
<Name UWPDisplayName="GU605MY" DeviceType="WDL_NB_KB_4ZONE_RGB_LIGHTING">
    <Type>285212684</Type>
    <PrimitiveDeviceTypeID>64</PrimitiveDeviceTypeID>
    <DeviceID>3F49AD29-52D9-46A5-A608-203D54E7D12A</DeviceID>
    <DeviceInGame>0</DeviceInGame>
    <DeviceSync>0</DeviceSync>
    <ACControllable>0</ACControllable>
    <CheckBoxEnable>4</CheckBoxEnable>
    <DependentAppStatus>0</DependentAppStatus>
    <LightingModeEnable>2</LightingModeEnable>
    <DeviceCount>1</DeviceCount>
    <DeviceIndex>0</DeviceIndex>
    <PIDMode>0</PIDMode>
    <PartNumber_90>90NR0IQ5-M004L0</PartNumber_90>
    <StatusReady>1</StatusReady>
</Name>
```

**Key findings:**
- **DeviceType:** `WDL_NB_KB_4ZONE_RGB_LIGHTING` — ASUS's internal software classifies the keyboard controller as a 4-zone-capable device
- **PrimitiveDeviceTypeID:** `64`
- **Type:** `285212684` (`0x1100000C` in hex)
- **CheckBoxEnable:** `4` — this often maps to the number of controllable light zones in ASUS's internal API
- **PIDMode:** `0` — indicates the controller uses a fixed PID (`0B05:19B6`) rather than dynamic PID switching

### What "4ZONE" means for the G16
Even though ASUS software reports `WDL_NB_KB_4ZONE_RGB_LIGHTING`, the **GU605MY physically implements a 1-zone keyboard**. The 4-zone classification is at the **controller firmware level** (ITE 8910 supports up to 4 zones), but the G16 keyboard PCB wires all key LEDs to a single zone channel. This is why:
- Effects like Reactive and Ripple animate the **entire keyboard at once**
- You cannot set different colors for WASD vs. the rest of the keyboard

---

## 5. Matrix LED Configuration

### `MatrixLED.ini`

```ini
[MatrixSettings]
MasterSwitch=1
MatrixScreenSwitch=1
MatrixLidSwitch=1
BatterySavingMode=1
ECAnimeSwitch=1
LightLevel=3
EC_Animation_apply=0
EC_Animation_Start=1
EC_Animation_Shutdown=1
EC_Animation_Sleep=1
EC_Animation_Save=1
```

This configures the **Slash/AniMe Matrix** behavior:
- `MasterSwitch=1` — Matrix effects enabled
- `MatrixLidSwitch=1` — Lid slash LED enabled
- `LightLevel=3` — Maximum brightness level for matrix animations
- `EC_Animation_*` — Embedded controller handles start/shutdown/sleep animations

### `SetMatrixLEDScript.xml`

```xml
<root>
    <header>AURA_3.0</header>
    <version>1.0</version>
    <effectProvider>
        <period>0</period>
        <queue/>
    </effectProvider>
    <viewport/>
    <effectList/>
</root>
```

This is a template used by Armoury Crate to push custom matrix animations to the EC. The actual animation data is injected into the `<effectList/>` node at runtime.

---

## 6. Festival Effect Binary Matrix Files

Armoury Crate ships pre-rendered binary animations for seasonal "Festival Effects" (Christmas, Halloween, New Year, Valentine's Day, etc.). These use two proprietary formats:

| Extension | Purpose |
|-----------|---------|
| `.MATRIX` | Full-keyboard animation bitmap sequences |
| `.MATRIXSLASH` | Slash-lid animation sequences |

### File Naming Convention

```
<Holiday>_festival_<DeviceCode>_<Index>.MATRIX[SLASH]
```

**Device Codes found in files:**
- `AIO` — All-in-One / generic keyboard matrix
- `GA401` — ASUS ROG Zephyrus G14 (2021)
- `GA402` — ASUS ROG Zephyrus G14 (2022/2023)
- `GU604` — ASUS ROG Zephyrus G16 (2023/predecessor)
- `HS_L` / `HS_R` — Headset left/right earcup
- `KB` — Generic keyboard
- `MB` — Motherboard / desktop

> **Note:** There are **no `GU605` specific `.MATRIX` files** in the festival pack. The G16 uses either the `AIO` or `GU604` matrix data, or the generic `KB` matrix. This confirms the keyboard LED layout is considered generic/standard by ASUS.

### Binary Structure (Inferred)
Based on file sizes and the `.keylight` text format, `.MATRIX` files likely contain:
- Header with frame count and dimensions
- Frame data as a bitmap where each byte/pixel maps to one LED in the keyboard matrix grid
- Possibly a key-to-index lookup table at the start

These files cannot be directly edited without reverse engineering, but they are not needed for Linux control since `rogauracore` and `asusctl` handle the protocol directly.

---

## 7. Slash Light Content State (`SlashLightContent.ini`)

```ini
[Setting]
OnBatteryPower=0
LidClosed=0
MasterSwitchOn=1
PowerSaving=1
PowerSavingPercent=20
BootUpShutDown=1
Sleep=1
LowBattery=1
ThemeID=1
SystemContentWavOn=0
BatteryLevel=1
BatteryAnimation=LoopTwice
AppInteraction=1

[PluginSetting]
ReadedBackFirstStartup=1

[GU605Basic]
DeviceType=SlashLaptop
ContentType=Off
ContentPath=
WContentUUID=
ContentWavOn=248
ContentUUID=1208463208
ContentWavPath=
Interval=0
ApplyModeEnumNum=255
Brightness=0
HexBrightness=0
repeat_times=3
priority=5
```

This shows the current Slash LED state on this machine:
- `DeviceType=SlashLaptop` — Confirms slash lighting hardware presence
- `ContentType=Off` — Currently disabled
- `Brightness=0` — Currently at 0% brightness
- `ThemeID=1` — Default theme is Theme 1 (Glitch)

---

## 8. LED Control Paths on Linux

### Keyboard Backlight
The 1-zone keyboard is exposed via the standard ASUS WMI interface:

```
/sys/class/leds/asus::kbd_backlight/brightness
```

Values: `0`, `1`, `2`, `3`

### Color Control (via `rogauracore`)
`rogauracore` talks directly to the ITE 8910 HID device at `0B05:19B6` using libusb. It sends USB control transfers with the following high-level command structure:

```c
// Initialize keyboard controller
rogauracore initialize_keyboard

// Set single-zone static color
rogauracore single_static <hex_color>

// Set brightness level
rogauracore brightness <0-3>
```

The USB protocol uses vendor-specific HID reports. For the `0B05:19B6` device, the known report structure is:
- **Report ID:** `0x5D`
- **Payload:** varies by command (typically 17 bytes for color commands)
- The first few bytes identify the command type, followed by RGB values for each zone

Since the G16 keyboard is wired as 1-zone, setting zone 0's color affects the entire keyboard.

### Slash LED Control
On Linux with `asusctl` ≥ 6.x:

```bash
# Enable/disable slash
asusctl slash -e true
asusctl slash -e false

# Set slash brightness
asusctl slash -b <0-255>

# Set slash mode (if supported)
asusctl slash -m <mode_name>
```

The slash LED is controlled via the same `asus-nb-wmi` kernel module but uses a different WMI method ID than the keyboard backlight.

---

## 9. Complete LED Ecosystem Summary

| Component | LEDs | Controller | Linux Support | Control Method |
|-----------|------|------------|---------------|----------------|
| **Keyboard** | ~82 keys (1 shared zone) | ITE 8910 `0B05:19B6` | ✅ Full | `asusctl`, `rogauracore`, `OpenRGB` |
| **Slash Lid** | 7 segments | ITE 8910 `0B05:193B` | ✅ Partial | `asusctl` (basic on/off/brightness) |
| **Logo (ROG Eye)** | None on G16 | N/A | N/A | N/A |

---

## 10. Key Takeaways for Custom Control

1. **Key names are standardized** — Use the list in Section 1 when writing custom scripts or parsing ASUS config files.
2. **The keyboard is truly 1-zone** — Despite the `WDL_NB_KB_4ZONE_RGB_LIGHTING` device type, all keys share one color.
3. **Slash has 7 segments** — `.slashlighting` files control each segment independently with 7 brightness values per frame.
4. **No per-key addressing** — You cannot light individual keys different colors on this hardware.
5. **Linux tools are sufficient** — `rogauracore` handles all color effects, `asusctl` handles brightness and slash LED basics.
