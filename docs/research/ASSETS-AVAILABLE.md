# Available Assets from Windows Research (GU605MY)

These assets have been copied into the OS image for future use.

## Embedded in OS Image

| Asset | Path | Source |
|-------|------|--------|
| Silent sound | `/usr/share/zephyrus-crimson/assets/sounds/silent.wav` | Armoury Crate theme1_effect10 |
| Balanced sound | `/usr/share/zephyrus-crimson/assets/sounds/balanced.wav` | Armoury Crate theme2_effect20 |
| Performance sound | `/usr/share/zephyrus-crimson/assets/sounds/performance.wav` | Armoury Crate theme4_effect30 |
| Keyboard layout | `/usr/share/zephyrus-crimson/assets/images/keyboard-layout.png` | GU605_US_0000.png |
| Slash preview | `/usr/share/zephyrus-crimson/assets/images/slash-preview.png` | Slash LED preview |

## Still on External Drive (for later extraction)

**Location:** `/run/media/solarious/SolariousT9/GU605MY_Hardware_Research/Optimization/ArmouryCrate_Extracted/`

### Profile Notification Icons (not yet found)
No dedicated profile-mode notification icons were discovered in the extracted Armoury Crate files. The extraction contains:
- Slash lighting theme images (6 themes, preview PNGs)
- Slash lighting sound effects (24 WAV files across themes + intensities)
- Keyboard layout diagrams (US/UK/JP)
- Aura wallpapers

**To extract notification icons later:**
Search inside the Armoury Crate installation directory on Windows for:
- `ToastNotification` or `OSD` image folders
- `PowerMode` icon sets
- `ResourceDictionary` XAML files containing vector icons

### All Sound Effects Available

```
configs/ROG_Live_Service/SlashContent/GU605/Content/
├── theme1/  (subtle)
│   ├── theme1_effect10.wav
│   ├── theme1_effect20.wav
│   ├── theme1_effect30.wav
│   └── theme1_effect40.wav
├── theme2/  (moderate)
├── theme3/  (medium)
├── theme4/  (aggressive)
├── theme5/  (intense)
└── theme6/  (maximum)
```

## How to Add Notification Icons Later

1. Extract PNG/SVG icons from Armoury Crate's `Resources` or `UI` folders on Windows
2. Copy them to `/usr/share/zephyrus-crimson/assets/icons/`
3. Update `zephyrus-profile-simple.sh` / `zephyrus-profile-enhanced.sh` to reference them in `notify-send -i <icon-name>`
