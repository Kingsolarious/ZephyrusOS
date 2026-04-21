# Zephyrus GU605MY Layered Fixes

**Approach:** Apply fixes ON TOP of your existing system instead of replacing it.

## Why Layering?

Your current Bazzite system has extensive customizations:
- Custom `asusctl`/`asusd`/`rog-control-center` binaries
- Layered packages (code, nodejs, cargo, ckb-next, easyeffects, etc.)
- Ollama AI server
- Personal development tools

**A full image rebuild would lose all of these.** Layering preserves everything.

## What's Fixed

| Fix | File(s) | What It Does |
|-----|---------|--------------|
| **S3 Deep Sleep** | `scripts/01-fix-kernel-cmdline.sh` | Removes `intel_idle.max_cstate=1`/`nosmt`, adds `mem_sleep_default=deep` |
| **GPU TGP Unlock** | kernel cmdline | Adds `acpi_osi="Windows 2022"` so NVIDIA driver binds NPCF → 115W max |
| **Fan Curve** | `zephyrus-gu605my-tune.service` | Stops forcing 100% fans; only sets Performance profile + CPU boost |
| **OEM Profile Sync** | `zephyrus-profile-sync` + `zephyrus-profile-watch` | Auto-syncs GPU PL (55W/90W/115W), Intel RAPL, CPU governor on ASUS profile change |
| **Sleep/Resume** | `zephyrus-gu605my-sleep` hook | Disables TBT wakeup pre-suspend, restores GPU PL + profile post-resume |
| **USB Autosuspend** | `50-zephyrus-gu605my-usb.rules` | Prevents ASUS keyboard, Logitech from suspending |
| **Gaming QoS** | `zephyrus-gaming-qos` + service | HTB traffic shaping for low-latency gaming |
| **Audio** | `zephyrus-gu605my-audio.conf` | ALC285 codec probe settings |

## How to Apply

```bash
cd ~/Desktop/Zephyrus\ OS/layered-fixes
sudo ./apply-fixes.sh
```

Then **reboot**.

## How to Verify

```bash
# Kernel cmdline
cat /proc/cmdline | grep -E "mem_sleep_default|acpi_osi"

# Services
systemctl status zephyrus-gu605my-tune
systemctl status zephyrus-profile-watch
systemctl status zephyrus-gaming-qos

# Profile sync (auto-applies GPU PL + RAPL + governor when profile changes)
asusctl profile -P silent && sleep 2 && asusctl profile get
asusctl profile -P performance && sleep 2 && asusctl profile get

# Sleep hook
/etc/systemd/system-sleep/zephyrus-gu605my-sleep pre suspend
cat /var/log/zephyrus-sleep.log
```

## Updating Your Base Image Later

If you ever build a new base image, these layered fixes will persist because they live in:
- `/etc/` (mutable, survives rebases)
- `/usr/local/bin/` (mutable, survives rebases)
- Kernel cmdline (stored in OSTree deployment, survives rebases)

**One exception:** Firmware in `/usr/lib/firmware/` is part of the image. You already have CS35L41 firmware in your current image.

## Directory Structure

```
layered-fixes/
├── apply-fixes.sh          # Master apply script
├── README.md               # This file
├── scripts/
│   └── 01-fix-kernel-cmdline.sh
└── configs/
    ├── etc/
    │   ├── modprobe.d/
    │   ├── systemd/system/
    │   ├── systemd/system-sleep/
    │   └── udev/rules.d/
    └── usr/local/bin/
```
