# ⚡ Zephyrus OS

<p align="center">
  <b>Model-specific tuning layer for ASUS ROG Zephyrus G16 (GU605MY) on Bazzite</b><br>
  <i>Hardware-extracted. Kernel-ready. Community-driven.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/ASUS-GU605MY-FF0022?style=flat-square&logo=asus&logoColor=white">
  <img src="https://img.shields.io/badge/CPU-Intel%20Core%20Ultra%209%20185H-0071C5?style=flat-square&logo=intel&logoColor=white">
  <img src="https://img.shields.io/badge/GPU-RTX%204090%20Laptop-76B900?style=flat-square&logo=nvidia&logoColor=white">
  <img src="https://img.shields.io/badge/OS-Bazzite%20(Fedora%20Silverblue)-294172?style=flat-square&logo=fedora&logoColor=white">
</p>

---

## What This Is (and Isn't)

**Zephyrus OS is NOT an attempt to install asusctl on Bazzite.**

[Bazzite](https://bazzite.gg/) already ships ASUS support through [Terra repositories](https://terra.fyralabs.com/) — you can install `asusctl`, `rog-control-center`, and related tools directly via `rpm-ostree` or `dnf`. The upstream [asus-linux.org](https://asus-linux.org/) project provides excellent base support for ASUS laptops on Linux.

**What Zephyrus OS actually does:**

This is a **model-specific tuning and research layer** for the **GU605MY** that goes beyond what generic ASUS tools provide:

- 🔬 **Factory-extracted fan curves** — Decoded from Armoury Crate EC firmware via three independent verification methods
- ⚡ **Hardware-validated power profiles** — PL1/PL2 limits, RAPL, and GPU TGP matched to Windows behaviour
- 🎹 **Custom keyboard effects engine** — Reactive, music-reactive, and temperature-based RGB via direct HID protocol
- 💡 **Slash LED support** — Full mode control and custom animation playback
- 🔊 **Audio routing fixes** — ALC285 + CS35L56 smart amp configuration, Focusrite Scarlett integration
- 🎨 **Desktop integration** — macOS-style theming, global menu, face auth, system status panels

Every PWM value, power limit, and RGB protocol in this repository was **extracted from Windows 11 with Armoury Crate** through direct hardware analysis, USB/HID capture, and ACPI table decoding.

---

## 📖 Table of Contents

- [What This Is (and Isn't)](#what-this-is-and-isnt)
- [Hardware](#hardware)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Upstream Collaboration](#upstream-collaboration)
- [License](#license)

---

## Hardware

| Component | Specification |
|-----------|---------------|
| **Model** | ASUS ROG Zephyrus G16 GU605MY |
| **CPU** | Intel Core Ultra 9 185H (Meteor Lake) |
| **dGPU** | NVIDIA GeForce RTX 4090 Laptop GPU (16 GB GDDR6) |
| **iGPU** | Intel Arc Graphics (MTL) |
| **Display** | Samsung SDC41A3, 2560×1600, 240 Hz OLED, 10-bit, HDR 616 nits |
| **RAM** | 32 GB LPDDR5X-7467 |
| **Audio** | Realtek ALC285 + Cirrus Logic CS35L56 Smart Amp |
| **Keyboard** | ASUS ITE 8910 HID, 1-zone RGB |
| **Slash LED** | ASUS AniMe Matrix-style LED array |
| **WiFi** | Intel Wi-Fi 7 BE200 |
| **Battery** | 90 Wh |

---

## Project Structure

```
Zephyrus-OS/
├── README.md              # This file
├── LICENSE                # MIT License
├── .github/               # CI/CD workflows
│
├── bin/                   # Executable scripts
│   ├── install/           # Installation scripts
│   ├── setup/             # Setup & configuration
│   ├── fix/               # Bug fixes & workarounds
│   ├── monitor/           # Monitoring & diagnostics
│   ├── gaming/            # Gaming optimizations
│   └── theme/             # Theme application scripts
│
├── src/                   # Source code
│   ├── zephyrus-about/       # System info panel (PyQt6)
│   ├── zephyrus-global-menu/ # GNOME Shell global menu
│   ├── zephyrus-face-auth/   # IR face authentication
│   ├── zephyrus-desktop/     # Desktop customizations
│   └── zephyrus-theme/       # GTK/KDE theme engine
│
├── config/                # System configuration overlays
│   ├── systemd/           # systemd services
│   ├── scripts/           # Config helper scripts
│   ├── layered-fixes/     # Bazzite layered fixes
│   ├── kde-setup/         # KDE Plasma setup
│   ├── desktop-entries/   # Application launchers
│   └── polkit/            # PolicyKit rules
│
├── docs/                  # Documentation
│   ├── hardware/          # Hardware tuning guides
│   ├── install/           # Installation guides
│   └── research/          # Research findings
│
├── themes/                # Visual themes
│   ├── gtk-4.0/           # GTK 4.0 theme
│   ├── gnome-shell/       # GNOME Shell theme
│   └── plymouth/          # Boot animation
│
├── assets/                # Icons, logos, images
│   └── icons/
│
├── build/                 # Build system
│   ├── container/         # Containerfiles
│   ├── rpm/               # RPM specs & patches
│   └── scripts/           # Build scripts & overlays
│       └── custom-asusctl/  # Fork of asusctl with GU605MY additions
│
└── research/              # Reverse engineering
    └── acpi/              # ACPI table analysis
```

---

## Quick Start

> ⚠️ **Warning:** Tailored for GU605MY. Verify compatibility before installing on other models.

### Prerequisites

Bazzite already provides ASUS base tools via Terra:

```bash
# Install upstream ASUS tools (if not already present)
rpm-ostree install asusctl rog-control-center
# or on Bazzite with Terra enabled:
sudo dnf install asusctl rog-control-center
```

### Install Zephyrus OS Tuning Layer

```bash
# 1. Clone
git clone https://github.com/Kingsolarious/ZephyrusOS.git
cd ZephyrusOS

# 2. Install dependencies
./bin/install/install-deps.sh

# 3. Apply model-specific fixes
sudo ./config/layered-fixes/apply-fixes.sh

# 4. Pin your deployment (prevents accidental OS updates)
sudo ./bin/setup/pin-os-deployment.sh

# 5. Reboot
systemctl reboot
```

### Post-Install

```bash
# Set performance profile
asusctl profile set performance

# Verify GPU power limit (should show 105W max configurable)
nvidia-smi -q -d POWER | grep "Power Limit"

# Test keyboard backlight
asusctl led-mode rainbow

# Test Slash LED
asusctl slash -e true
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/hardware/GU605MY-HARDWARE-TUNING.md](docs/hardware/GU605MY-HARDWARE-TUNING.md) | Complete hardware tuning guide |
| [docs/hardware/GU605MY_EXACT_FACTORY_FAN_CURVES.md](docs/hardware/GU605MY_EXACT_FACTORY_FAN_CURVES.md) | Decoded factory fan curves |
| [docs/hardware/FACTORY_FAN_CURVES.md](docs/hardware/FACTORY_FAN_CURVES.md) | Fan curve reference |
| [docs/hardware/GU605MY_FACTORY_FEATURES_STATUS.md](docs/hardware/GU605MY_FACTORY_FEATURES_STATUS.md) | Feature implementation status |
| [docs/install/KDE_SETUP_GUIDE.md](docs/install/KDE_SETUP_GUIDE.md) | KDE Plasma setup |
| [docs/install/MACOS_APPLE_LOOK_GUIDE.md](docs/install/MACOS_APPLE_LOOK_GUIDE.md) | macOS-style theming |

---

## Upstream Collaboration

This project builds on top of the excellent work from the [asus-linux.org](https://asus-linux.org/) community. Our custom `asusctl` fork (`build/scripts/custom-asusctl/`) adds GU605MY-specific features and will be rebased onto upstream `devel` regularly.

### Goals

- 🐛 **Kernel bug reports** — Audio routing workarounds are documented with the intent to upstream proper fixes to the Linux kernel
- ⌨️ **HID scancodes** — Missing Fn-key mappings discovered here are contributed back to the kernel `hid-asus` driver
- 🔊 **ALC285 support** — Smart amp configurations are tracked for upstreaming to `snd-hda-intel`
- 💻 **Model-specific data** — Fan curves, power limits, and thermal data are shared with upstream for broader laptop support

### Deprecation Notes

- **supergfxctl** is deprecated in favour of letting the NVIDIA driver manage GPU power states. Disabling the dGPU via supergfxctl often leaves it powered-on but inaccessible, consuming power without benefit. A replacement tool that works *with* the NVIDIA driver is being developed by the community.
- **CPU governor settings** in this repository are model-specific. The GU605MY reaches maximum clocks under the `performance` governor with Intel P-State; other models may require `powersave` + EPP for the same result.

---

## Research

### Factory Fan Curves

Decoded from Armoury Crate EC firmware via three independent methods:
- Armoury Crate service logs
- NVPCF ACPI table index buffers
- Live EC register reads

### Power Profiles

| Profile | CPU PL1 | CPU PL2 | GPU Sustained | GPU Peak | Notes |
|---------|---------|---------|---------------|----------|-------|
| Silent | 55W | 60W | 55W | 55W | Quiet fans, reduced power |
| Balanced | 70W | 95W | 90W | 90W | Balanced thermals |
| Performance | 95W | 115W | **105W** | 105W | VBIOS hard-cap; matches Windows base |

> **Note:** Windows reports ~103W sustained with 115W Dynamic Boost peak. Linux reaches 105W sustained (VBIOS configurable max). Dynamic Boost (+10-12W peak) requires NVIDIA NVPCF driver support that does not exist on Linux.

### Display

- **Panel:** Samsung SDC ATNA60DL01-0 (SDC41A3)
- **Native:** 2560×1600 @ 240 Hz
- **Color:** 10-bit, DCI-P3 + BT.2020, HDR (616 nits peak)
- **VRR:** Adaptive Sync 48–240 Hz
- **Interface:** DisplayPort (eDP)

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

*Built with reverse engineering, hardware analysis, and too much coffee.*
