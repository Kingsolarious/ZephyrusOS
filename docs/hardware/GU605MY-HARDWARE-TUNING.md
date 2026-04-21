# GU605MY Comprehensive Hardware Tuning Guide

**Validated for:** ASUS ROG Zephyrus G16 GU605MY  
**CPU:** Intel Core Ultra 9 185H (Meteor Lake)  
**dGPU:** NVIDIA RTX 4090 Laptop GPU (16 GB GDDR6)  
**Display:** Samsung SDC41A3, 2560×1600, 240 Hz  
**Audio:** Realtek ALC285 + Cirrus Logic CS35L56 smart amp  
**Keyboard:** ASUS ITE 8910 HID (0B05:19B6), 1-zone RGB  

---

## 🔴 Critical Fixes Applied (2026-04-20)

### 1. S3 Sleep (NOT S0ix)

**Problem:** Previous build assumed Modern Standby (S0ix) and used `intel_idle.max_cstate=1 processor.max_cstate=1` which destroys battery life and prevents proper suspend.

**Reality:** `powercfg /a` confirms **S3 (Suspend-to-RAM) only**. S0ix is NOT available on this firmware.

**Fix:**
- Removed `intel_idle.max_cstate=1 processor.max_cstate=1 nosmt` from kernel cmdline
- Added `mem_sleep_default=deep`

```bash
# Verify
cat /sys/power/mem_sleep  # Should show: s2idle [deep]
```

### 2. GPU Power Limit (NPCF Binding)

**Problem:** Without `acpi_osi="Windows 2022"`, the NVIDIA driver does NOT bind the `NPCF` ACPI device. GPU stuck at 80W VBIOS fallback instead of 115W ACPI default.

**Fix:** Kernel cmdline includes:
```
acpi_osi=! acpi_osi="Windows 2022"
```

**Result:** `nvidia-smi` now shows 115W default (not 80W).

### 3. Fan Curves

**Problem:** `zephyrus-gu605my-tune.service` hardcoded 100% fans at all temperatures — extremely loud and unnecessary.

**Fix:** Service now only sets `asusctl profile -P performance` and leaves fan curves at Armoury Crate firmware defaults. Use `asusctl fan-curve` manually only if needed.

### 4. Audio / CS35L56 Firmware

**Problem:** ZERO audio configuration existed. Internal speakers ran without DSP protection.

**Fix:**
- Added `snd-hda-intel` modprobe options for ALC285
- Embedded CS35L56 DSP firmware in OS image (`/usr/lib/firmware/cirrus/`)
- Added `zephyrus-cs35l56-firmware.service` to verify firmware at boot

### 5. USB Autosuspend

**Problem:** USB devices (ASUS keyboard, etc.) were subject to USB autosuspend, causing dropouts.

**Fix:** Added udev rules in `/etc/udev/rules.d/50-zephyrus-gu605my-usb.rules`

### 6. Sleep/Resume Hooks

**Problem:** No suspend/resume handling for NVIDIA memory or thermal tables.

**Fix:** Added `/etc/systemd/system-sleep/zephyrus-gu605my-sleep` that:
- Disables Thunderbolt/USB4 wakeup before suspend
- Restores GPU power limit after resume
- Restores asusctl profile after resume

---

## ⚡ Power Profiles (Hardware-Validated)

From decoded Armoury Crate service logs:

| Profile | CPU PL1 | CPU PL2 | GPU Base | Dynamic Boost | Effective TGP |
|---------|---------|---------|----------|---------------|---------------|
| **Silent** | 60W | 70W | — | — | ~55W |
| **Balanced** | 45W | 65W | — | — | 90W (custom) |
| **Performance/Turbo** | 80W | 100W | 95W | 20W | **115W** |
| **Max Manual** | — | — | — | — | 125W |

### TGP Discrete Levels (5-step)

| Index | TGP |
|-------|-----|
| 0 | 80W |
| 1 | 90W |
| 2 | 95W |
| 3 | 100W |
| 4 | 105W |

### RAPL Tuning (CPU)

```
PL1  = 75W  sustained
PL2  = 115W turbo burst
Tau  = 28s
```

---

## 🎮 GPU Power Wrappers

| Script | Power | Use Case |
|--------|-------|----------|
| `zephyrus-cpu-heavy-game` | 90W | CPU-bound games (leave GPU headroom) |
| `zephyrus-gpu-heavy-game` | 125W | GPU-bound titles |
| `zephyrus-gpu-profile-sync` | Auto | Syncs with asusctl profile (55W/90W/115W) |

---

## 🌙 Sleep Configuration

### Kernel Parameters

```
mem_sleep_default=deep
intel_pstate=active
cpufreq.default_governor=performance
split_lock_detect=off
nvidia-drm.modeset=1
nvidia.NVreg_PreserveVideoMemoryAllocations=1
nvidia.NVreg_EnableGpuFirmware=1
nvidia.NVreg_DynamicPowerManagement=0x02
i915.enable_dpcd_backlight=1
nvidia.NVreg_EnableBacklightHandler=0
acpi_osi=! acpi_osi="Windows 2022"
```

### Why Each Parameter Matters

| Parameter | Purpose |
|-----------|---------|
| `mem_sleep_default=deep` | **CRITICAL** — Forces S3 suspend-to-RAM |
| `nvidia-drm.modeset=1` | Required for Wayland, VRR, PRIME |
| `NVreg_PreserveVideoMemoryAllocations=1` | Fixes resume memory corruption |
| `NVreg_DynamicPowerManagement=0x02` | Allows dGPU power-down in hybrid mode on battery |
| `i915.enable_dpcd_backlight=1` | Fixes OLED brightness in hybrid mode |
| `NVreg_EnableBacklightHandler=0` | Prevents NVIDIA stealing backlight |
| `acpi_osi=! acpi_osi="Windows 2022"` | **CRITICAL** — Exposes NPCF for 115W TGP |

### Suspend/Resume Script

`/etc/systemd/system-sleep/zephyrus-gu605my-sleep`
- Disables TBT wakeup
- Restores GPU PL and ASUS profile on resume

---

## 🔊 Audio

### Hardware IDs

| Component | ID |
|-----------|-----|
| HDA Codec | Realtek ALC285 (`10EC:0285`) |
| Smart Amp | Cirrus Logic CS35L56 (`ACPI\CSC3556`) |

### Firmware Files (in image)

```
/usr/lib/firmware/cirrus/CS35L56_Rev3.11.16.wmfw
/usr/lib/firmware/cirrus/10431C63_240426_V0_A0-init.bin
/usr/lib/firmware/cirrus/10431C63_240426_V0_A1-init.bin
/usr/lib/firmware/cirrus/10431C63_240426_V1_A0-init.bin
/usr/lib/firmware/cirrus/10431C63_240426_V1_A1-init.bin
```

### Modprobe Config

`/etc/modprobe.d/zephyrus-gu605my-audio.conf`
- Sets `model=alc285-laptop`
- Disables audio power management to prevent dropouts
- Points DSP firmware to CS35L56 blob

---

## 🎮 Gaming QoS

`zephyrus-gaming-qos` (enabled via systemd) applies HTB traffic shaping:

| Class | Priority | Rate | Ports |
|-------|----------|------|-------|
| Gaming | 1 | 500mbit | Steam, Valorant, Apex, COD, OW |
| Voice | 2 | 100mbit | Discord, TeamSpeak, Zoom |
| Interactive | 3 | 100mbit | SSH, DNS |
| Bulk | 4 | 200mbit | HTTP, torrents, streaming |

---

## ⌨️ Keyboard RGB

- **Device:** `0B05:19B6`
- **Interface:** `UsagePage=0xFF31, Usage=0x0079`
- **Control:** `asusctl` handles brightness; custom daemon available at `gu605my_keyboard_effects.py`

---

## 🖥️ Display

| Property | Value |
|----------|-------|
| Panel | Samsung SDC41A3 |
| Resolution | 2560×1600 |
| Refresh | 240 Hz |
| Ratio | 16:10 |

### OLED / Brightness Fix

Already in kernel cmdline:
```
i915.enable_dpcd_backlight=1 nvidia.NVreg_EnableBacklightHandler=0
```

### VRR on KDE Wayland

```bash
kwriteconfig6 --file kwinrc --group OrgKdeKwinCompositor --key VRRPolicy 2
kwriteconfig6 --file kwinrc --group Compositing --key AllowTearing false
```

---

## 🔄 Services Enabled in Image

| Service | Purpose |
|---------|---------|
| `asusd` | ASUS WMI daemon |
| `supergfxd` | MUX switch control |
| `nvidia-power-limit` | GPU 115W baseline |
| `rapl-tune` | CPU PL1 75W / PL2 115W |
| `zephyrus-gu605my-tune` | Set performance profile |
| `zephyrus-gpu-profile-sync` | Sync GPU PL with profile |
| `zephyrus-cs35l56-firmware` | Verify audio DSP firmware |
| `zephyrus-gaming-qos` | Traffic prioritization |
| `scx` | Scheduler extensibility |
| `zephyrus-probe-hardware` | One-time DPTF/EC probe |

---

## 🛠️ Build Verification

After building the image, verify:

```bash
# Sleep state
cat /sys/power/mem_sleep

# GPU power limit
nvidia-smi -q -d POWER | grep "Power Limit"

# ASUS profile
asusctl profile get

# Audio firmware presence
ls /usr/lib/firmware/cirrus/CS35L56*

# Fan curve (should show firmware defaults, not 100%)
asusctl fan-curve --mod-profile performance

# Kernel cmdline
cat /proc/cmdline
```

---

## 📋 Change Log

| Date | Change |
|------|--------|
| 2026-04-20 | Fixed kernel cmdline for S3 sleep (removed C-state kill, added `mem_sleep_default=deep`) |
| 2026-04-20 | Removed 100% fan curve from tune service |
| 2026-04-20 | Updated power profile scripts to use decoded Armoury Crate values |
| 2026-04-20 | Added CS35L56 audio firmware and modprobe config |
| 2026-04-20 | Added USB autosuspend rules for ASUS keyboard + peripherals |
| 2026-04-20 | Added systemd sleep hooks for NVIDIA/resume stability |
| 2026-04-20 | Added GPU profile sync service |
| 2026-04-20 | Integrated gaming QoS script |
| 2026-04-20 | Fixed Containerfile.nvidia default profile (balanced → performance) |
