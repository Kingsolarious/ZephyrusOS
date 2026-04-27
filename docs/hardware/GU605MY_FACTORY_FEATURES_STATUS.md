# GU605MY Factory Features — Linux Implementation Status

> **Last Updated:** 2026-04-20  
> **OS:** Zephyrus Crimson OS (Bazzite-based, OSTree)  
> **Kernel:** 6.17.7-ba28.fc43.x86_64  
> **Base:** Fedora Silverblue 43

---

## Legend

| Icon | Meaning |
|------|---------|
| ✅ | Fully working — matches or exceeds factory |
| 🟡 | Partial — approximated or limited |
| 🔴 | Not possible — hardware/firmware limitation |
| 📝 | Documented — research complete, implementation pending |

---

## Power & Thermal

| Feature | Status | Details |
|---------|--------|---------|
| **ASUS Profile Switching** | ✅ | `asusctl` + `rog-control-center` GUI fully functional |
| **Profile Auto-Sync** | ✅ | `zephyrus-profile-watch` syncs GPU PL + RAPL + governor on D-Bus profile change |
| **GPU TGP (Max 115W)** | ✅ | Dynamic via `nvidia-powerd`. VBIOS fallback 80W, ACPI TPPL 115W, manual max 125W |
| **Intel RAPL** | ✅ | PL1/PL2 per profile: Quiet=55W/60W, Balanced=70W/95W, Performance=80W/100W |
| **CPU Governor** | ✅ | `powersave` (Quiet), `performance` (Balanced/Performance) |
| **CPU Boost** | ✅ | Controlled via `asusctl profile --boost-set` |
| **Fan Curves — Exact** | ✅ | **BREAKTHROUGH:** Exact PWM/temp values extracted from `asus_custom_fan_curve` hwmon device for all 3 profiles. See `GU605MY_EXACT_FACTORY_FAN_CURVES.md` |
| **Fan Curves — Quiet** | ✅ | CPU: 58°C→2 PWM, GPU: 53°C→2 PWM. Max ~4000 RPM |
| **Fan Curves — Balanced** | ✅ | CPU: 59°C→15 PWM, GPU: 51°C→25 PWM. Max ~5100 RPM |
| **Fan Curves — Performance** | ✅ | CPU: 50°C→153 PWM, GPU: 50°C→128 PWM. Max ~6500 RPM |
| **DPTF Thermal** | ✅ | `INT3400 Thermal` + `SEN1/2/3` zones active. Trip points: critical 80°C, hot 75°C, passive 65°C, active 60/50/40°C |
| **Thermald** | ✅ | Running in adaptive mode with DPTF ACPI tables |
| **Tuned** | ✅ | **Disabled** — was conflicting with profile sync |

---

## Display & Graphics

| Feature | Status | Details |
|---------|--------|---------|
| **MUX Switch** | 🟡 | `supergfxctl` — **deprecated**. NVIDIA driver power management preferred. See notes below. |
| **Dynamic MUX** | 🔴 | **Impossible.** ASUS firmware requires reboot for MUX state change. No Linux NVAPI support for Advanced Optimus |
| **OLED Backlight** | ✅ | `i915.enable_dpcd_backlight=1` |
| **NVIDIA DRM Modeset** | ✅ | `nvidia-drm.modeset=1` |
| **Panel Overdrive** | 📝 | Not yet configured. Need to check if exposed via DDC/CI or ASUS WMI |
| **HDR** | 📝 | KDE Plasma supports HDR. Need calibration/ICC profile |
| **VRR (240Hz)** | ✅ | Panel supports 240Hz, VRR enabled in kwinrc |

---

## Audio

| Feature | Status | Details |
|---------|--------|---------|
| **Internal Speakers** | ✅ | Realtek ALC285 + CS35L41 smart amp. Firmware: `CS35L56_Rev3.11.16.wmfw` |
| **PipeWire** | ✅ | Full 0-100% volume control (volume limiter removed) |
| **Dolby Atmos** | 🟡 | Not replicated. Can approximate with EasyEffects HRTF convolver |
| **Spatial Audio** | 📝 | Research complete. Need EasyEffects preset implementation |

---

## Input

| Feature | Status | Details |
|---------|--------|---------|
| **Touchpad** | ✅ | ASUS Precision Touchpad (ASUF1207) fully functional |
| **Keyboard Backlight** | ✅ | 1-zone RGB via `asusd`. Static/breathing/rainbow supported |
| **Advanced Keyboard RGB** | 📝 | Protocol decoded (`0B05:19B6`, report ID `0x5D`). Reactive/music/temp effects need daemon implementation |
| **Slash LED** | 📝 | `asusctl` supports basic modes. Custom `.slashlighting` animations need player daemon (`0B05:193B`) |
| **ROG Key / Hotkeys** | ✅ | Mapped via udev hwdb |

---

## Power Management

| Feature | Status | Details |
|---------|--------|---------|
| **S3 Deep Sleep** | ✅ | `mem_sleep_default=deep`. TBT wakeup disabled pre-suspend |
| **S0ix Modern Standby** | 🟡 | Available but not configured. S3 preferred for this laptop |
| **Battery Threshold** | ✅ | 80% limit via `asusctl battery limit` |
| **USB Autosuspend** | ✅ | Rules for ASUS devices, Logitech |
| **GPU Power Management** | ✅ | `nvidia.NVreg_DynamicPowerManagement=0x02` |

---

## Networking

| Feature | Status | Details |
|---------|--------|---------|
| **Wi-Fi 6E AX211** | ✅ | `iwlwifi` driver |
| **Bluetooth 5.3** | ✅ | `btusb` driver |
| **USB4 / Thunderbolt** | ✅ | Security level: `user`. Controller present at `domain0` |
| **Gaming QoS** | ✅ | `zephyrus-gaming-qos` HTB traffic shaping |

---

## Security & Encryption

| Feature | Status | Details |
|---------|--------|---------|
| **TPM 2.0** | ✅ | Available |
| **LUKS2 + TPM2** | 📝 | Can be configured with `systemd-cryptenroll` |
| **Secure Boot** | 📝 | Check with `mokutil --sb-state` |
| **Face Auth** | 📝 | `howdy` can approximate Windows Hello |

---

## GPU Overclocking

| Feature | Status | Details |
|---------|--------|---------|
| **Clock Offset** | 🔴 | **VBIOS locked.** `nvidia-smi --lock-gpu-clocks` returns permission denied. `nvidia-settings --query GPUClockOffset` not available |
| **Application Clocks** | 🔴 | `nvidia-smi -ac` returns "not supported" |
| **Voltage Curve** | 🔴 | **VBIOS locked.** No Linux tool can unlock |
| **Performance Levels** | ✅ | 6 P-states visible via `nvidia-settings --query GPUPerfModes`. Dynamic clock switching works |

> **Note:** The RTX 4090 Laptop VBIOS on the GU605MY explicitly disables overclocking. This is a **hardware/firmware lock**, not a driver limitation. On Windows, Armoury Crate's "Manual" mode allows only pre-configured profiles from the encrypted `AC_Config.VgaOc.GU605MY.enc` — the GPU is not actually user-overclockable even on Windows.

---

## Deprecated / Pending Replacement

| Feature | Status | Details |
|---------|--------|---------|
| **supergfxctl dGPU disable** | 🔴 | **Deprecated.** Disabling dGPU via supergfxctl leaves the GPU powered-on but inaccessible, consuming power without benefit. NVIDIA driver's native power management is preferred. Community replacement tool in development. |

---

## What Was Fixed in This Session

1. **Disabled `tuned.service`** — Was overriding CPU governor to `powersave` and resetting RAPL PL1 to 200W
2. **Disabled legacy `zephyrus-gpu-profile-sync.service`** — Replaced by unified `zephyrus-profile-watch`
3. **Fixed Balanced governor** — Changed from `schedutil` to `performance` (intel_pstate doesn't support schedutil)
4. **Enabled fan curves for Quiet & Balanced** — Were `enabled: false`, now active
5. **Removed volume limiter** — `volume-limiter.service` was capping audio at 75%
6. **Updated OS build overlays** — Kernel cmdline, Containerfile, scripts all synced with live system
7. **Extracted exact factory fan curves** — From `asus_custom_fan_curve` hwmon device
8. **Verified DPTF is working** — `INT3400 Thermal` + `SEN1/2/3` zones active with correct trip points

---

## Remaining Research Gaps

| Gap | Priority | Path Forward |
|-----|----------|--------------|
| Encrypted Armoury Crate configs | Low | AES-256-CBC via .NET `EncryptedXml`. Runtime memory dump of Armoury Crate Service is only viable path |
| VBIOS inner tables (BOOST, thermal curve) | Low | Need `nvflash --save vbios.rom` or GPU-Z dump from Windows |
| EC firmware fan PWM-to-RPM mapping | Low | `ectool` basic version only. Need ASUS-specific EC tool or SPI dump |
| Intel ME firmware version | Low | `cat /sys/class/mei/mei0/fw_ver` when `mei_me` module loaded |
| Complete PCIe config space | Low | `lspci -xxx` dump |
| IR camera stream formats | Low | `v4l2-ctl --list-formats-ext` |

---

## OS Build Updates Applied

| File | Change |
|------|--------|
| `os-build/overlays/etc/kernel/cmdline` | Removed `acpi_osi=!`, kept `acpi_osi="Windows 2022" acpi_osi=Linux` |
| `os-build/overlays/usr/local/bin/zephyrus-profile-sync` | Updated with unified profile syncer |
| `os-build/overlays/usr/local/bin/zephyrus-profile-watch` | **Added** |
| `os-build/overlays/etc/systemd/system/zephyrus-profile-watch.service` | **Added** |
| `os-build/Containerfile` | Enables `zephyrus-profile-watch`, disables `tuned`/`nvidia-power-limit`/`rapl-tune`/`zephyrus-gpu-profile-sync` |
| `layered-fixes/` | Fully synced with current live state |
| `docs/GU605MY_EXACT_FACTORY_FAN_CURVES.md` | **New** — Exact PWM/temp tables for all profiles |
| `docs/GU605MY_FACTORY_FEATURES_STATUS.md` | **New** — This document |
