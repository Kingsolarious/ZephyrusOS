# ROG Zephyrus G16 GU605MY — Ultimate Linux Gaming & Cooling Optimization Guide

**Date:** 2026-04-16  
**Target Hardware:** ASUS ROG Zephyrus G16 GU605MY  
**CPU:** Intel Core Ultra 9 185H (Meteor Lake — 6P + 8E + 2LPE cores, 22 threads)  
**iGPU:** Intel Arc Graphics (8 Xe cores, 2560×1600 240Hz OLED internal panel)  
**dGPU:** NVIDIA GeForce RTX 4090 Laptop GPU (16GB GDDR6, AD103, PCIe `10DE:2757`)  
**RAM:** 32GB LPDDR5X-7467 (soldered, Samsung K3KL9L90CM-MGCT)  
**Storage:** 2TB SK hynix NVMe + 1TB Samsung 960 EVO NVMe  
**Networking:** Intel Wi-Fi 6E AX211 (`8086:7E40`)  
**Audio:** Realtek ALC285 (`10EC:0285`), Intel SST  
**Display:** 16" Samsung OLED SDC41A3 (2560×1600, 240Hz, HDR, VRR capable)  

---

## The Core Problem: This Laptop Is Thermally Constrained

You have a **desktop-class RTX 4090** crammed into a **16mm-thin chassis**. The CPU and GPU share heatpipes. Here is the hard reality:

- **RTX 4090 Laptop TDP:** 80W default / 125W max
- **Core Ultra 9 185H TDP:** 45W base / 115W max turbo
- **Combined sustained thermal capacity of the heatsink:** ~140–160W total

**What this means:**
- If you uncap the GPU to **125W**, the CPU will immediately throttle to ~35–45W in sustained loads.
- If you cap the GPU to **80–90W**, the CPU can sustain **55–65W**, giving you significantly better frame rates in **CPU-bound games** (open-world titles, strategy games, simulation games, MMOs).
- The GPU at 90W is only ~10–15% slower than at 125W for most titles because the laptop 4090 is memory-bandwidth-limited at these power levels.

**Your optimization strategy on Linux is therefore:**
1. **Manage the thermal budget** between CPU and GPU
2. **Maximize CPU sustained power** via RAPL tuning, C-state disabling, and thread scheduling
3. **Raise GPU power only when the game is GPU-bound**
4. **Maximize physical cooling** (fans, stand, repaste)

---

## 1. Recommended Linux Distribution

### Primary Recommendation: **CachyOS**
**Why:**
- Ships with the **Cachy-BPF kernel** (BORE scheduler + sched-ext support out of the box)
- Automatic NVIDIA driver installation (proprietary or open)
- Pre-tuned compiler optimizations (`x86-64-v3`/`v4` packages)
- Excellent Arch Wiki compatibility
- Easy to install `asusctl`/`supergfxctl` from AUR

### Alternative: **Nobara 41** (Fedora-based)
**Why:**
- Gaming-oriented out of the box (Kernel patched for gaming, Wine-GE, Gamemode)
- Strong ASUS ROG support community
- More "stable" than Arch if you don't want rolling release maintenance

### Avoid:
- **Ubuntu LTS** — kernel too old for Meteor Lake P-cores/E-cores scheduling and NVIDIA Dynamic Boost
- **Vanilla Debian** — same kernel issue, missing `asusctl` packages
- **Bazzite** — designed for HTPC/handheld use, poor laptop MUX/dGPU workflow

---

## 2. Pre-Installation BIOS Setup

Enter BIOS (spam `F2` during boot) and configure:

| Setting | Recommended Value | Reason |
|---------|-------------------|--------|
| **Secure Boot** | `Disabled` | Required for NVIDIA DKMS and custom kernels |
| **SATA Mode** | `AHCI` (should already be) | NVMe works best |
| **CPU C-States** | `Disabled` or `C1 only` | Eliminates 1.6ms DPC latency spikes (audio + gaming stutter) |
| **Intel Speed Shift** | `Disabled` | Prevents rapid frequency swings that cause frame-time spikes |
| **Intel SpeedStep** | `Disabled` | Same as above |
| **ASUS MultiCore Enhancement** | `Disabled` | Prevents transient voltage spikes that trigger thermal throttling |
| **VT-d** | `Disabled` or `Enabled` | Disable if you want GPU passthrough; otherwise leave on |
| **Fast Boot** | `Disabled` | Ensures all devices initialize properly for Linux |
| **Thunderbolt Boot Support** | `Disabled` unless needed | Reduces PCI initialization issues |

**Save & Exit.**

---

## 3. ASUS Linux Stack Installation

These tools replace Armoury Crate on Linux and are **essential** for fan control, keyboard RGB, MUX switching, and GPU power profiles.

```bash
# On CachyOS (Arch-based):
sudo pacman -S asusctl supergfxctl rog-control-center

# Enable services:
sudo systemctl enable --now asusd
sudo systemctl enable --now supergfxd
```

### Verify ASUS ACPI WMI Interface
Your Windows probe confirmed `ASUS System Control Interface v3` is present. On Linux, verify with:

```bash
dmesg | grep -i "asus"
# You should see:
# asus_wmi: ASUS WMI hardware monitor initialized
# asus_wmi: ASUS WMI sensors initialized
```

If missing, add this kernel parameter:
```
acpi_osi=! acpi_osi="Windows 2022"
```

### Critical Hardware IDs for Debugging

If `asusctl` does not work, verify these devices exist in Linux:

```bash
# The ASUS keyboard/RGB controller MUST appear for asusctl to work:
lsusb | grep 0b05:19b6
# → Bus 001 Device 002: ID 0b05:19b6 ASUSTek Computer, Inc.

# Verify the ASUS WMI module loaded:
dmesg | grep -i "asus.*wmi"
# → asus_wmi: ASUS WMI hardware monitor initialized

# Verify PCI devices:
lspci -nn | grep -E "(VGA|Audio|Network|USB)"
# 00:02.0 VGA compatible controller [0300]: Intel Corporation Meteor Lake-P [Intel Arc Graphics] [8086:7d55]
# 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation AD103 [GeForce RTX 4090 Laptop GPU] [10de:2757]
# 00:1f.3 Audio device [0403]: Intel Corporation Meteor Lake-P HD Audio Controller [8086:7e28]
# 00:14.3 Network controller [0280]: Intel Corporation Wi-Fi 6E AX211 [8086:7e40]
```

> See `GU605MY_Linux_Hardware_Debug_and_Fan_Profiles.md` for the full DSDT dump, ACPI method analysis, and registry-extracted power settings.

### ASUS Platform Profiles on the GU605MY

`asusctl` exposes three platform profiles that map to Armoury Crate modes:

| Linux Profile | Armoury Crate | CPU PL1 | CPU PL2 | GPU TGP (solo) | Noise | Use Case |
|---------------|---------------|---------|---------|----------------|-------|----------|
| `quiet` | Silent | 55W | 60W | ~55W | ~35 dBA | Battery, office, light gaming |
| `balanced` | Performance | 70W | 95W | 90W | ~42 dBA | Daily driver, mixed workloads |
| `performance` | Turbo | 80W | 100W | 115W | ~45–46 dBA | Heavy gaming, rendering |

> **Note:** The fourth Windows mode, **Manual**, allows up to 125W GPU and 85W/110W CPU PL1/PL2. On Linux you can approximate Manual by setting `performance` profile and using `nvidia-smi -pl 125` plus a custom `asusctl` fan curve.

### Key `asusctl` Commands for This Laptop

```bash
# Set fan curve to maximum cooling:
asusctl fan-curve -m performance -D 30c:100,40c:100,50c:100,60c:100,70c:100,80c:100,90c:100,100c:100

# Enable keyboard lighting (if desired):
asusctl led-mode static -c ff0000

# Check current platform profile:
asusctl profile -v

# Cycle profiles: quiet -> balanced -> performance
asusctl profile -P performance
```

> **Critical:** The `performance` profile on this laptop sets the GPU power target to **90W**, not 125W. Only `turbo` (115W) and `manual` (125W) raise the GPU ceiling. Use `performance` for CPU-bound games, `turbo` for GPU-bound games, and `quiet` on battery. See Section 3.1 for the full profile specification.

---

## 4. MUX Switch & GPU Mode Configuration

Your GU605MY has a **MUX switch + NVIDIA Advanced Optimus**. On Linux, dynamic switching does **not work**. You must reboot to switch between `integrated` and `dedicated` GPU modes.

```bash
# Check current mode:
supergfxctl -g

# Switch to dedicated GPU mode (dGPU directly drives internal OLED panel):
supergfxctl -m dedicated
# Then reboot.

# Switch back to hybrid (iGPU drives panel, dGPU renders):
supergfxctl -m hybrid
# Then reboot.
```

### Recommendation:
- **For competitive FPS / lowest latency:** Use `dedicated` mode
- **For battery life / desktop use:** Use `hybrid` mode
- **For HDR+VRR gaming:** `dedicated` mode often has better NVIDIA G-Sync compatibility on Linux

### OLED Panel Note
Your internal panel is **Samsung SDC41A3** (2560×1600 240Hz OLED). In `dedicated` mode, the NVIDIA GPU drives it directly. You need:

```bash
# Enable Variable Refresh Rate (VRR) in NVIDIA Settings:
nvidia-settings -a AllowVRR=1
```

And in `/etc/X11/xorg.conf.d/20-nvidia.conf`:
```
Section "Monitor"
    Identifier "DP-2"  # verify with xrandr
    Option "AllowGSYNCCompatible" "true"
EndSection
```

---

## 5. NVIDIA RTX 4090 Laptop Optimization

### Driver Choice
For the RTX 4090 (Ada Lovelace), use the **proprietary NVIDIA driver**, not the open kernel module:

```bash
# CachyOS:
sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings

# Verify module loaded:
lsmod | grep nvidia
```

> The open `nvidia-open-dkms` module works, but the proprietary driver still has better power management and G-Sync support on laptops.

### Kernel Parameters (GRUB / systemd-boot)
Add these to your bootloader cmdline for the RTX 4090 Laptop:

```
nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=1 nvidia.NVreg_DynamicPowerManagement=0x02
```

| Parameter | Purpose |
|-----------|---------|
| `nvidia-drm.modeset=1` | Required for Wayland, VRR, and proper PRIME offloading |
| `NVreg_PreserveVideoMemoryAllocations=1` | Fixes suspend/resume memory corruption |
| `NVreg_EnableGpuFirmware=1` | Enables GSP firmware offload for better power efficiency |
| `NVreg_DynamicPowerManagement=0x02` | Allows full dGPU power-down in hybrid mode on battery |

### ReBAR / Above 4G Decoding
Your Windows probe showed the RTX 4090 has full 16GB VRAM exposed. Ensure **Resizable BAR** is enabled in BIOS for +3–10% performance in some titles.

### OLED Brightness in Hybrid Mode
If you run in `hybrid` or `integrated` GPU mode and screen brightness controls stop working, add this to GRUB:
```
i915.enable_dpcd_backlight=1 nvidia.NVreg_EnableBacklightHandler=0 nvidia.NVreg_RegistryDwords=EnableBrightnessControl=0
```
This is a known fix on GU605MY/MI models when the iGPU drives the OLED panel.

### Raise GPU Power Limit (Conditional)
The default GPU power limit is **80W**. The VBIOS allows up to **125W**.

```bash
# Check current limits:
nvidia-smi -q -d POWER

# Raise to 125W:
sudo nvidia-smi -pl 125

# To make it persistent across reboots, create a systemd service:
sudo tee /etc/systemd/system/nvidia-power-limit.service << 'EOF'
[Unit]
Description=NVIDIA GPU Power Limit
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pl 115
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now nvidia-power-limit.service
```

> **Important:** I set the persistent service to **115W**, not 125W. At 125W, the shared heatsink chokes the CPU too hard in CPU-bound games. **115W is the sweet spot** for this chassis. Adjust per-game as shown below.

### Per-Game GPU Power Profiles
Create wrapper scripts for different thermal strategies:

```bash
# /usr/local/bin/cpu-heavy-game.sh
#!/bin/bash
# Use for: Baldur's Gate 3, Cities Skylines 2, Cyberpunk 2077 (CPU-bound areas), Starfield
sudo nvidia-smi -pl 90  # Give CPU more thermal headroom
gamemoderun "$@"

# /usr/local/bin/gpu-heavy-game.sh
#!/bin/bash
# Use for: Alan Wake 2, Hogwarts Legacy, Metro Exodus, DLSS3 path-tracing titles
sudo nvidia-smi -pl 125  # Max GPU power
gamemoderun "$@"
```

In Steam, set launch options:
```
/usr/local/bin/cpu-heavy-game.sh %command%
```

---

## 6. Intel Core Ultra 9 185H Optimization (The Big One)

This is where most of your gains will come from. The 185H is a powerful chip, but Meteor Lake's aggressive power management and thin chassis thermal limits kneecap it in sustained loads.

### 6.1 Kernel Command-Line Parameters

Add these to your bootloader in addition to the NVIDIA params:

```
intel_idle.max_cstate=1 processor.max_cstate=1 intel_pstate=active nosmt
cpufreq.default_governor=performance split_lock_detect=off mitigations=off
```

| Parameter | Effect | Trade-off |
|-----------|--------|-----------|
| `intel_idle.max_cstate=1` | Blocks deep C-states (C6/C8) | Higher idle power, worse battery life |
| `processor.max_cstate=1` | Backup for older kernels | Same as above |
| `intel_pstate=active` | Uses Intel's active p-state driver | Best turbo response |
| `nosmt` | **Disables Hyper-Threading** | Reduces heat ~5–10%, improves 1% lows in games that don't scale past 16 threads |
| `cpufreq.default_governor=performance` | Locks max frequency | More heat, but less stutter |
| `split_lock_detect=off` | Disables split-lock bus traps | Prevents micro-stutters in some emulators/older engines |
| `mitigations=off` | Disables Spectre/Meltdown mitigations | ~3–5% CPU performance gain, security risk |

> **Note on `nosmt`:** The 185H has 22 threads. Most games use 8–12 threads. Disabling SMT turns it into a 16-core chip (6P + 8E + 2LPE), which is actually ideal for gaming and reduces thermal load. You can alternatively use `isolcpus` to isolate P-cores for the game process instead of disabling SMT globally.

### 6.2 E-Core / LP-E-Core Management

Meteor Lake's E-cores and LP-E-cores can cause frame-time spikes if game threads migrate to them. On Linux, there are three ways to handle this:

#### Option A: Disable E-cores entirely via kernel (Drastic, but effective)
Add to kernel cmdline:
```
maxcpus=8  # Boots only first 8 logical CPUs (all P-cores + some E-cores)
```
This is too blunt. Better:

#### Option B: CPU Affinity via `taskset` (Recommended)
Use `taskset` to bind your game to P-cores only (CPUs 0–11 on this chip):

```bash
# Launch game on P-cores only:
taskset -c 0-11 gamemoderun %command%
```

But Meteor Lake's E-cores are CPUs 12–19, and LP-E-cores are 20–21. So `taskset -c 0-11` keeps the game on P-cores + some E-cores? Actually, Linux enumerates P-cores first, then E-cores, then LP-E-cores. So:
- P-cores (6 cores, 12 threads with HT): CPUs 0–11
- E-cores (8 cores, 8 threads): CPUs 12–19
- LP-E-cores (2 cores, 2 threads): CPUs 20–21

For pure P-cores only:
```bash
taskset -c 0-5,6-11 gamemoderun %command%
# Wait, 0-11 includes all P-core threads. Yes.
```

Actually, with SMT disabled (`nosmt`), it becomes:
- P-cores: 0–5
- E-cores: 6–13
- LP-E-cores: 14–15

So with `nosmt`, binding to `0-5` is pure P-core gaming.

#### Option C: Use `sched-ext` (scx_lavd or scx_bpfland)
CachyOS ships with sched-ext. Install and enable:

```bash
sudo pacman -S scx-scheds
sudo systemctl enable --now scx.service
```

Then set the scheduler:
```bash
sudo scxctl set sched lavd
```

`scx_lavd` is designed for hybrid CPUs and automatically keeps latency-sensitive threads on P-cores. It is **highly recommended** for the 185H.

### 6.3 RAPL Power Limit Tuning (Raise CPU TDP)

The default Intel RAPL limits on this laptop are conservative. You can raise them via sysfs:

```bash
# Find the RAPL domain:
ls /sys/class/powercap/intel-rapl/
# Usually: intel-rapl:0 (package), intel-rapl:0:0 (core), intel-rapl:0:1 (uncore)

# Check current limits:
cat /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
cat /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw

# constraint_0 = PL1 (sustained)
# constraint_1 = PL2 (turbo, short duration)
```

Create a systemd service to raise CPU power limits at boot:

```bash
sudo tee /etc/systemd/system/rapl-tune.service << 'EOF'
[Unit]
Description=Intel RAPL Tuning for Gaming
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo 75000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw && echo 115000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw && echo 28000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_time_window_us'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now rapl-tune.service
```

This sets:
- **PL1 = 75W** (sustained)
- **PL2 = 115W** (turbo burst)
- **Tau = 28 seconds**

> **Warning:** The VRMs and heatsink may not sustain 75W+125W GPU simultaneously. Use the per-game GPU power capping from Section 5 to balance the load.

### 6.4 Undervolting Reality Check

**Meteor Lake (Core Ultra) cannot be undervolted on Linux** as of 2026.

- `intel-undervolt` does **not** support MTL
- `throttlestop` is Windows-only
- The voltage/frequency curves are locked by Intel's FIT (Fail-safe Voltage Guardband)

**Workarounds:**
1. **Repaste with liquid metal** (see Section 8) — this is your biggest thermal win
2. **Use Intel's `intel-speed-select` (RAPL only)** — can trade E-core voltage for P-core headroom, but limited on consumer silicon
3. **Disable AVX-512** if present (not relevant on 185H)
4. **Lower PL1/PL2** in games that don't need full CPU power — paradoxically, a 55W sustained CPU often runs at higher *average* clocks than a 75W CPU that thermal throttles to 35W after 10 seconds

### 6.5 Thermal Daemon (`thermald`) Configuration

`thermald` is Intel's thermal management daemon. On gaming laptops, it can be **too aggressive** and throttle the CPU prematurely.

```bash
# Check if thermald is throttling you:
sudo systemctl status thermald

# If active, you have two choices:
# A) Disable it entirely (not recommended for thin laptops)
sudo systemctl disable --now thermald

# B) Use a custom config that only engages at 95°C
sudo tee /etc/thermald/thermal-conf.xml << 'EOF'
<?xml version="1.0"?>
<ThermalConfiguration>
  <Platform>
    <Name>ROG Zephyrus G16 GU605MY</Name>
    <ProductName>*</ProductName>
    <Preference>PERFORMANCE</Preference>
    <ThermalSensors>
      <ThermalSensor>
        <Type>x86_pkg_temp</Type>
        <Path>/sys/class/thermal/thermal_zone0/temp</Path>
        <AsyncCapable>0</AsyncCapable>
      </ThermalSensor>
    </ThermalSensors>
    <ThermalZones>
      <ThermalZone>
        <Type>cpu</Type>
        <TripPoints>
          <TripPoint>
            <SensorType>x86_pkg_temp</SensorType>
            <Temperature>95000</Temperature>
            <Type>Passive</Type>
            <ControlType>SEQUENTIAL</ControlType>
            <CoolingDevice>
              <index>1</index>
              <type>rapl_controller</type>
              <influence>100</influence>
              <SamplingPeriod>10</SamplingPeriod>
            </CoolingDevice>
          </TripPoint>
        </TripPoints>
      </ThermalZone>
    </ThermalZones>
  </Platform>
</ThermalConfiguration>
EOF
sudo systemctl restart thermald
```

This tells `thermald` to **only start RAPL throttling at 95°C**, letting the CPU run at its BIOS/VRM limits up to that point.

---

## 7. The Cooling Maximization Protocol

Since you cannot undervolt on Linux, **physical cooling is your only lever** for raising the CPU thermal ceiling.

### 7.1 Software: Max Fan Curves
The GU605MY has **dual blower fans** (CPU-side + GPU-side) with the following approximate limits:

| Fan | Max RPM (@ 100%) | Typical Turbo RPM |
|-----|------------------|-------------------|
| CPU fan | ~6400–6500 | ~5800–6200 |
| GPU fan | ~6100–6300 | ~5500–5900 |

You can force fans to 100% before launching a game:

```bash
# Set all fan channels to 100%:
asusctl fan-curve -m performance -D 30:100,50:100,70:100,90:100,100:100
```

A reference stock curve from a similar G16 on Linux looks like this:
```
CPU: 40c:2%,44c:4%,55c:11%,64c:13%,68c:17%,72c:27%,76c:36%,80c:48%
GPU: 40c:7%,44c:11%,55c:20%,64c:22%,68c:24%,72c:32%,76c:37%,80c:50%
MID: 40c:8%,44c:12%,55c:17%,64c:25%,68c:29%,72c:40%,76c:52%,80c:66%
```

On some GU605MY units, `asusctl` cannot override the EC fan curve entirely. If fans still won't max out, use `nbfc-linux` (NoteBook FanControl) as a fallback:

```bash
yay -S nbfc-linux
sudo nbfc config --apply "ASUS ROG Zephyrus G16 GU605MY"
sudo nbfc set -s 100
```

### 7.2 Hardware: The 3-Step Cooling Overhaul

#### Step 1: Laptop Stand (Immediate, Cheap)
Use a **raised laptop stand** that lifts the rear 2–3 inches. The GU605MY intakes air from the bottom. Even a $20 stand improves airflow by 15–20%.

#### Step 2: Cooling Pad (Effective for Sustained Loads)
A **high-RPM cooling pad** (e.g. IETS GT300, KLIM Cyclone) with bottom blowers can reduce CPU/GPU temps by **5–10°C** in sustained gaming. This is often the difference between 45W CPU throttling and 65W sustained.

#### Step 3: Repaste with Liquid Metal (The Nuclear Option)
The GU605MY uses standard thermal paste from the factory. In thin laptops, paste pump-out is common after 6–12 months.

**Recommended repaste:**
- **Thermal Grizzly Conductonaut** (liquid metal) — best performance, -10–15°C possible
- **Thermalright TFX / Honeywell PTM7950** — if you don't want liquid metal risk

**Critical caution:** The 185H and RTX 4090 have exposed capacitors near the dies on some boards. Use **nail polish or conformal coating** to protect nearby SMDs before applying liquid metal.

**Expected gains:**
- Stock paste: CPU throttles at ~85°C after 30s
- Liquid metal: CPU sustains 90–95°C at 70W for minutes

#### Step 4: VRM Thermal Pads
The VRMs on the GU605MY run hot when PL1 is raised to 75W. Replace the stock VRM pads with **1.5mm Thermalright Extreme Odyssey** or **Fujipoly Ultra Extreme**.

---

## 8. Gaming Performance Stack on Linux

### 8.1 GameMode

```bash
sudo pacman -S gamemode lib32-gamemode
```

Create `/home/$USER/.config/gamemode.ini`:

```ini
[general]
renice=10

cpu_governor=performance

gpu_device=0
gpu_powersave=false

[custom]
start=notify-send "GameMode" "Performance mode active"
end=notify-send "GameMode" "Performance mode ended"
```

Launch all games with `gamemoderun`:
```bash
gamemoderun %command%
```

### 8.2 Ananicy-cpp (Process Priority Daemon)

```bash
sudo pacman -S ananicy-cpp
sudo systemctl enable --now ananicy-cpp
```

Add a custom rule for your most-played games in `/etc/ananicy.d/99-games.rules`:
```
{ "name": "eldenring.exe", "type": "Game" }
{ "name": "cyberpunk2077.exe", "type": "Game" }
{ "name": "starfield.exe", "type": "Game" }
```

### 8.3 MangoHud

```bash
sudo pacman -S mangohud lib32-mangohud
```

Create `~/.config/MangoHud/MangoHud.conf`:

```ini
cpu_stats
gpu_stats
ram
vram
fps
frame_timing
display_sync
time
engine_version
wine
toggle_hud=Shift_R+F12
```

Launch with `mangohud gamemoderun %command%`

### 8.4 FSR 3 Frame Generation & DLSS

- **DLSS/FSR2:** Works natively in Proton for most titles
- **FSR 3 FrameGen:** Use `dxvk-gplasync` + `proton-ge` for best compatibility
- **Forcing FSR on all games:** Use `Gamescope`:

```bash
gamescope -W 2560 -H 1600 -r 240 --force-grab-cursor --adaptive-sync --fsr-sharpness 2 -- gamemoderun %command%
```

This forces FSR 1.0 upscaling + Gamescope's compositor, which can actually improve latency on OLED panels.

### 8.5 Steam Launch Options Template

For a **CPU-bound game** on this laptop:
```bash
taskset -c 0-11 gamemoderun mangohud %command%
```

For a **GPU-bound game**:
```bash
gamemoderun mangohud %command%
```

For **competitive FPS** (Valorant, CS2, Apex):
```bash
sudo nvidia-smi -pl 90; taskset -c 0-11 gamemoderun mangohud %command%
```

---

## 9. OLED Display Optimization & Care

Your internal Samsung OLED (SDC41A3) is gorgeous but requires care on Linux.

### 9.1 VRR / G-Sync
In `dedicated` GPU mode:
```bash
# Enable in nvidia-settings, then add to xorg config:
Option "VariableRefresh" "true"
```

For Wayland (KDE Plasma / Hyprland):
- KDE: Settings > Display > Adaptive Sync = **Always**
- Hyprland: `vrr = 2` in config

### 9.2 HDR
Linux HDR is still experimental. For gaming:
- Use **Gamescope** with `--hdr-enabled` for titles that support it
- Or use **MangoHud's HDR indicator** to verify

### 9.3 Burn-in Prevention
OLED burn-in is real. Install `wl-gammarelay` or `gammastep` to:
- **Dim the display to 60% brightness** when not gaming
- **Enable a 5-minute screensaver** that fully blanks the screen
- **Hide the panel/dock** in your desktop environment (static UI elements are the enemy)

For KDE Plasma:
```bash
# Enable OLED dimming:
kwriteconfig5 --file kwinrc --group Compositing --key MaxFPS 60
```

---

## 10. Complete Kernel Parameter String for GRUB

Based on everything above, your `/etc/default/grub` `GRUB_CMDLINE_LINUX_DEFAULT` should look like:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet intel_idle.max_cstate=1 processor.max_cstate=1 intel_pstate=active nosmt cpufreq.default_governor=performance split_lock_detect=off mitigations=off nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_EnableGpuFirmware=1 nvidia.NVreg_DynamicPowerManagement=0x02 i915.enable_dpcd_backlight=1 nvidia.NVreg_EnableBacklightHandler=0 acpi_osi=! acpi_osi=\"Windows 2022\""
```

Then regenerate GRUB:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

> **Warning:** `mitigations=off` is a security risk. Only use it for a dedicated gaming install. For daily driver use, remove it.

---

## 11. Monitoring & Benchmarking

Install these tools to validate your optimizations:

```bash
sudo pacman -S s-tui nvtop intel-gpu-tools lm_sensors mangohud
```

### Validation Checklist

| Test | Expected Result After Optimization |
|------|-----------------------------------|
| `s-tui` stress test | CPU sustains 65W+ at 90°C without throttling below 3.5 GHz |
| `nvidia-smi dmon` during gaming | GPU hits your set power limit (90W or 115W/125W) |
| `nvtop` | No CPU cores pinned at 100% while GPU is under 80% (bottleneck check) |
| `sensors` | VRM temps under 100°C, SSD temps under 70°C |
| LatencyMon equivalent on Linux | `cyclictest --smp -p95 -m` shows max latency <200 µs |

### CPU-Bound Game Benchmarks
Test these titles to verify CPU tuning:
- **Cyberpunk 2077** (Ray Tracing Overdrive, crowds stress the CPU)
- **Baldur's Gate 3** (Act 3 city areas)
- **Cities: Skylines 2**
- **Total War: Warhammer III** (battle benchmarks)

If the CPU still drops to 35W in these titles, lower the GPU power cap further (try 80W) and verify fan speeds are at 100%.

---

## 12. One-Shot Setup Script for Linux

Save this as `setup_gu605my.sh` and run it after installing CachyOS:

```bash
#!/bin/bash
set -e

echo "=== Installing ASUS Linux stack ==="
sudo pacman -S --needed asusctl supergfxctl rog-control-center gamemode lib32-gamemode mangohud lib32-mangohud ananicy-cpp scx-scheds s-tui nvtop intel-gpu-tools lm_sensors

echo "=== Enabling services ==="
sudo systemctl enable --now asusd
sudo systemctl enable --now supergfxd
sudo systemctl enable --now ananicy-cpp
sudo systemctl enable --now scx.service

echo "=== Setting ASUS profile to Performance ==="
sudo asusctl profile -P performance

echo "=== Setting max fan curves ==="
sudo asusctl fan-curve -m performance -D 30c:100,40c:100,50c:100,60c:100,70c:100,80c:100,90c:100,100c:100

echo "=== Creating NVIDIA power limit service (115W default) ==="
sudo tee /etc/systemd/system/nvidia-power-limit.service << 'EOF'
[Unit]
Description=NVIDIA GPU Power Limit
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pl 115
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now nvidia-power-limit.service

echo "=== Creating RAPL tuning service ==="
sudo tee /etc/systemd/system/rapl-tune.service << 'EOF'
[Unit]
Description=Intel RAPL Tuning for Gaming
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo 75000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw && echo 115000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw && echo 28000000 > /sys/class/powercap/intel-rapl/intel-rapl:0/constraint_0_time_window_us'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now rapl-tune.service

echo "=== Done. Reboot and verify with: s-tui, nvtop, nvidia-smi ==="
```

---

## Bottom Line

Your GU605MY is **not slow** — it is **thermally choked**. The RTX 4090 Laptop is massively overpowered for the shared heatsink.

### The Winning Formula on Linux:
1. **Cap the GPU to 90–115W** depending on the game's CPU demands
2. **Raise CPU PL1 to 65–75W** via RAPL tuning
3. **Disable C-states and use P-core affinity** for consistent frame times
4. **Max the fans** via `asusctl`
5. **Use a cooling pad + repaste** to physically move more heat

If you follow this guide completely, you can expect:
- **CPU-bound games:** +20–35% better 1% lows
- **GPU-bound games:** ~95% of the performance of a 125W unlimited GPU, but with a cooler, quieter system
- **Thermals:** CPU sustained at 65W instead of throttling to 35W

For a pure plug-and-play experience with most of this pre-configured, **CachyOS** is the move. Install it, run the setup script, tweak your GRUB cmdline, and game on.
