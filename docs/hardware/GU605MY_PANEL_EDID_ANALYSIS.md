# ASUS ROG Zephyrus G16 GU605MY — Panel EDID Analysis

**Date:** 2026-04-22
**Panel:** Samsung SDC ATNA60DL01-0 (SDC41A3)
**Interface:** eDP (DisplayPort)

---

## Summary

The internal OLED panel is fully decoded. Key findings:

| Feature | Spec |
|---------|------|
| **Native Resolution** | 2560×1600 @ 240 Hz |
| **Fallback Resolution** | 2560×1600 @ 60 Hz |
| **Aspect Ratio** | 16:10 |
| **Panel Size** | 344.4 mm × 215.3 mm (~16.0″ diagonal) |
| **Color Depth** | 12 bpc native, 10 bpc RGB |
| **Panel Type** | OLED (Organic LED) |
| **Color Gamut** | DCI-P3 + BT.2020 |
| **HDR EOTF** | SMPTE ST 2084 (PQ) |
| **Peak Brightness** | 616 nits (10% window), 400 nits (full screen) |
| **Min Brightness** | 0.0005 cd/m² |
| **Gamma** | 2.20 |
| **VRR Range** | **48–240 Hz** (Adaptive Sync) |
| **VRR Secondary** | 48–60 Hz |
| **VRR Features** | Seamless transition, fixed + adaptive V-total |
| **Max Dotclock** | 1125.275 MHz |
| **eDP Version** | DisplayID 2.0 extension |

---

## Colorimetry

```
Red:   (0.6799, 0.3201)
Green: (0.2371, 0.7229)
Blue:  (0.1399, 0.0500)
White: (0.3127, 0.3291) — D65
```

This exceeds DCI-P3 and approaches BT.2020 in green coverage.

---

## VRR / Adaptive Sync

The EDID contains an **Adaptive Sync Data Block** with two descriptors:

1. **Native Panel Range:** 60–240 Hz
2. **Secondary Range:** 48–60 Hz

Both support:
- Fixed Average V-Total and Adaptive V-Total
- Seamless transition (no black screen when switching refresh rates)
- Zero added jitter for frame duration changes

**Linux implication:** VRR should work out-of-the-box with `amdgpu`/`i915` + `nvidia-drm` modeset. Use `vrr_enabled=1` in games or enable in desktop compositor (KWin/GNOME Mutter).

---

## HDR

The panel advertises:
- **DCI-P3** color space
- **BT.2020 / SMPTE ST 2084** EOTF (Perceptual Quantizer)
- 10-bit RGB encoding

**Linux implication:** HDR is supported by the panel but requires:
- KDE Plasma 6.1+ with HDR enabled, OR
- Gamescope with `--hdr-enabled`, OR
- GNOME HDR support (still experimental)

The 616-nit peak brightness makes this a solid HDR400+ class display.

---

## DSC (Display Stream Compression)

**Not required.** The native 240 Hz timing uses:
- 1125.275 MHz dotclock
- H: 2560 + 8 front + 32 sync + 40 back = 2640 total
- V: 1600 + 158 front + 8 sync + 10 back = 1776 total

At 240 Hz, this is within eDP HBR3 bandwidth (≈25.92 Gbit/s). No DSC compression needed.

---

## Linux Tuning Recommendations

### Enable VRR
```bash
# For KDE Plasma (Wayland):
kwriteconfig5 --file kwinrc --group Compositing --key VRRPolicy 2

# For GNOME (mutter):
gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"
```

### Enable HDR (KDE)
```bash
# In System Settings → Display → HDR → Enable
# Or via command line when available
```

### Panel Overdrive
The EDID does **not** contain explicit overdrive/response time data. The 240 Hz native refresh + OLED pixel response makes overdrive largely unnecessary. ASUS likely handles any overshoot in the panel firmware.

---

## Verification Commands

```bash
# Read EDID directly
cat /sys/class/drm/card0-eDP-1/edid | edid-decode

# Check current refresh rate
xrandr --output eDP-1 --verbose | grep "refresh"

# Check VRR status (AMD/Intel)
cat /sys/kernel/debug/dri/0/eDP-1/vrr_enabled 2>/dev/null
```
