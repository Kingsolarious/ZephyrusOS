#!/bin/bash
# Fix kernel cmdline for GU605MY S3 sleep + GPU TGP
# Run with sudo

set -e

echo "=== Current kernel cmdline ==="
cat /proc/cmdline
echo

echo "=== Adding correct args ==="
# S3 deep sleep
rpm-ostree kargs --append-if-missing="mem_sleep_default=deep"
# GPU TGP unlock - NPCF ACPI device binding
rpm-ostree kargs --append-if-missing='acpi_osi="Windows 2022"'
# Keep Linux OSI for compatibility (touchpad, audio)
rpm-ostree kargs --append-if-missing='acpi_osi=Linux'
# Performance governor
rpm-ostree kargs --append-if-missing="intel_pstate=active"
rpm-ostree kargs --append-if-missing="cpufreq.default_governor=performance"
# Stability
rpm-ostree kargs --append-if-missing="split_lock_detect=off"
# NVIDIA settings
rpm-ostree kargs --append-if-missing="nvidia-drm.modeset=1"
rpm-ostree kargs --append-if-missing="nvidia.NVreg_PreserveVideoMemoryAllocations=1"
rpm-ostree kargs --append-if-missing="nvidia.NVreg_EnableGpuFirmware=1"
rpm-ostree kargs --append-if-missing="nvidia.NVreg_DynamicPowerManagement=0x02"
# Backlight
rpm-ostree kargs --append-if-missing="i915.enable_dpcd_backlight=1"
rpm-ostree kargs --append-if-missing="nvidia.NVreg_EnableBacklightHandler=0"

echo
echo "=== New kernel cmdline (next boot) ==="
rpm-ostree kargs
echo
echo "✅ Kernel cmdline fixed. Reboot to apply."
echo "NOTE: If GPU power is still capped at 60W after reboot, run:"
echo "  sudo nvidia-smi -pl 105"
