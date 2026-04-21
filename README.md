# ⚡ Zephyrus OS

<p align="center">
  <b>The ultimate Linux tuning layer for ASUS ROG Zephyrus G16 (GU605MY)</b><br>
  <i>Extracted from Windows. Perfected on Bazzite.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/ASUS-GU605MY-FF0022?style=flat-square&logo=asus&logoColor=white">
  <img src="https://img.shields.io/badge/CPU-Intel%20Core%20Ultra%209%20185H-0071C5?style=flat-square&logo=intel&logoColor=white">
  <img src="https://img.shields.io/badge/GPU-RTX%204090%20Laptop-76B900?style=flat-square&logo=nvidia&logoColor=white">
  <img src="https://img.shields.io/badge/OS-Bazzite%20(Fedora%20Silverblue)-294172?style=flat-square&logo=fedora&logoColor=white">
</p>

---

## 📖 Table of Contents

- [What is Zephyrus OS?](#what-is-zephyrus-os)
- [Hardware](#hardware)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Research](#research)
- [License](#license)

---

## What is Zephyrus OS?

**Zephyrus OS** is a comprehensive tuning and customization layer built on top of [Bazzite](https://bazzite.gg/) (Fedora Silverblue) specifically for the **ASUS ROG Zephyrus G16 GU605MY**.

Every setting, fan curve, and RGB protocol in this repository was **extracted from Windows 11 with Armoury Crate** through direct hardware analysis, USB/HID capture, and ACPI table decoding.

---

## Hardware

| Component | Specification |
|-----------|---------------|
| **Model** | ASUS ROG Zephyrus G16 GU605MY |
| **CPU** | Intel Core Ultra 9 185H (Meteor Lake) |
| **dGPU** | NVIDIA GeForce RTX 4090 Laptop GPU (16 GB GDDR6) |
| **iGPU** | Intel Arc Graphics (MTL) |
| **Display** | Samsung SDC41A3, 2560×1600, 240 Hz OLED |
| **RAM** | 32 GB LPDDR5X-7467 |
| **Audio** | Realtek ALC285 + Cirrus Logic CS35L56 Smart Amp |
| **Keyboard** | ASUS ITE 8910 HID, 1-zone per-key RGB |
| **Slash LED** | ASUS AniMe Matrix-style LED array |
| **WiFi** | Intel Wi-Fi 7 BE200 |
| **Battery** | 90 Wh |

---

## Project Structure

```
Zephyrus-OS/
├── README.md              # This file
├── LICENSE                # MIT License
├── Makefile               # Build orchestration
├── Justfile               # Alternative build tasks
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
│   ├── rog-control-center/   # Rust-based Armoury GUI
│   ├── zephyrus-about/       # System info panel (PyQt6)
│   ├── zephyrus-global-menu/ # GNOME Shell global menu
│   ├── zephyrus-face-auth/   # IR face authentication
│   ├── zephyrus-desktop/     # Desktop customizations
│   └── zephyrus-theme/       # GTK/KDE theme engine
│
├── config/                # System configuration overlays
│   ├── systemd/           # systemd services
│   ├── udev/              # udev rules
│   ├── modprobe.d/        # Kernel module options
│   ├── desktop-entries/   # Application launchers
│   ├── polkit/            # PolicyKit rules
│   ├── layered-fixes/     # Bazzite layered fixes
│   ├── kde-setup/         # KDE Plasma setup
│   └── scripts/           # Config helper scripts
│
├── docs/                  # Documentation
│   ├── hardware/          # Hardware tuning guides
│   ├── install/           # Installation guides
│   └── research/          # Research findings
│
├── themes/                # Visual themes
│   ├── gtk/               # GTK 4.0 theme
│   ├── gnome-shell/       # GNOME Shell theme
│   └── plymouth/          # Boot animation
│
├── assets/                # Icons, logos, images
│   └── icons/
│
├── build/                 # Build system
│   ├── container/         # Containerfiles
│   ├── rpm/               # RPM specs & patches
│   └── scripts/           # Build scripts
│
└── research/              # Reverse engineering
    ├── acpi/              # ACPI table analysis
    └── windows-extraction/# Windows data extraction
```

---

## Quick Start

> ⚠️ **Warning:** Tailored for GU605MY. Verify compatibility before installing on other models.

```bash
# 1. Clone
git clone http://localhost:3333/solarious/Zephyrus-OS.git
cd Zephyrus-OS

# 2. Install dependencies
./bin/install/install-deps.sh

# 3. Apply layered fixes
sudo ./config/layered-fixes/apply-fixes.sh

# 4. Install custom components
sudo ./build/scripts/install.sh

# 5. Reboot
systemctl reboot
```

### Post-Install

```bash
# Set performance profile
asusctl profile set performance

# Verify GPU power limit (should show ~115W)
nvidia-smi -q | grep "Default Power Limit"

# Test keyboard effects
gu605my-keyboard-effects --rainbow-anim

# Test Slash LED
gu605my-slash-player --mode rainbow
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/hardware/GU605MY-HARDWARE-TUNING.md](docs/hardware/GU605MY-HARDWARE-TUNING.md) | Complete hardware tuning guide |
| [docs/hardware/GU605MY_EXACT_FACTORY_FAN_CURVES.md](docs/hardware/GU605MY_EXACT_FACTORY_FAN_CURVES.md) | Decoded factory fan curves |
| [docs/hardware/FACTORY_FAN_CURVES.md](docs/hardware/FACTORY_FAN_CURVES.md) | Fan curve reference |
| [docs/install/KDE_SETUP_GUIDE.md](docs/install/KDE_SETUP_GUIDE.md) | KDE Plasma setup |
| [docs/install/MACOS_APPLE_LOOK_GUIDE.md](docs/install/MACOS_APPLE_LOOK_GUIDE.md) | macOS-style theming |

---

## Research

### Factory Fan Curves

Decoded from Armoury Crate EC firmware via three independent methods:
- Armoury Crate service logs
- NVPCF ACPI table index buffers
- Live EC register reads

### Power Profiles

| Profile | CPU PL1 | CPU PL2 | GPU Base | Dynamic Boost | Effective TGP |
|---------|---------|---------|----------|---------------|---------------|
| Silent | 60W | 70W | — | — | ~55W |
| Balanced | 45W | 65W | — | — | 90W |
| Performance | 80W | 100W | 95W | 20W | **115W** |

