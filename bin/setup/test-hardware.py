#!/usr/bin/env python3
"""
Test script for hardware detection functions.
Run this to verify all hardware probes work correctly.
"""

import platform
import subprocess
import os
import sys

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'zephyrus-about'))

def run_command(cmd: str) -> str:
    """Execute shell command and return output."""
    try:
        result = subprocess.run(
            cmd, 
            shell=True, 
            capture_output=True, 
            text=True, 
            timeout=5
        )
        return result.stdout.strip() if result.returncode == 0 else 'Unknown'
    except Exception as e:
        return f'Error: {e}'

def test_all():
    """Test all hardware detection functions."""
    
    print("=" * 60)
    print("Zephyrus Hardware Detection Test")
    print("=" * 60)
    print()
    
    # CPU
    print("CPU:")
    print(f"  platform.processor(): {platform.processor()}")
    try:
        with open('/proc/cpuinfo', 'r') as f:
            for line in f:
                if 'model name' in line:
                    print(f"  /proc/cpuinfo: {line.split(':')[1].strip()}")
                    break
    except Exception as e:
        print(f"  Error reading /proc/cpuinfo: {e}")
    print()
    
    # Memory
    print("Memory:")
    try:
        with open('/proc/meminfo', 'r') as f:
            for line in f:
                if 'MemTotal' in line:
                    kb = int(line.split()[1])
                    gb = round(kb / (1024 * 1024))
                    print(f"  Total: {gb} GB")
                    break
    except Exception as e:
        print(f"  Error: {e}")
    print()
    
    # GPU
    print("GPU:")
    print(f"  lspci: {run_command('lspci | grep -i VGA')}")
    print()
    
    # NVIDIA
    print("NVIDIA Driver:")
    print(f"  nvidia-smi: {run_command('nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null')}")
    print()
    
    # Display
    print("Display:")
    print(f"  xrandr: {run_command('xrandr | grep \"*\" | head -1')}")
    print()
    
    # Display Panel (EDID)
    print("Display Panel:")
    edid_paths = [
        '/sys/class/drm/card0-eDP-1/edid',
        '/sys/class/drm/card1-eDP-1/edid',
        '/sys/class/drm/card0-eDP-2/edid',
    ]
    for path in edid_paths:
        if os.path.exists(path):
            print(f"  Found: {path}")
            output = run_command(f"strings {path} 2>/dev/null | head -5")
            print(f"  EDID strings: {output[:100]}...")
            break
    else:
        print("  No EDID found")
    print()
    
    # Serial Number
    print("Serial Number:")
    print(f"  product_serial: {run_command('cat /sys/class/dmi/id/product_serial 2>/dev/null')}")
    print()
    
    # BIOS
    print("BIOS:")
    print(f"  bios_version: {run_command('cat /sys/class/dmi/id/bios_version 2>/dev/null')}")
    print(f"  bios_vendor: {run_command('cat /sys/class/dmi/id/bios_vendor 2>/dev/null')}")
    print()
    
    # System
    print("System:")
    print(f"  product_name: {run_command('cat /sys/class/dmi/id/product_name 2>/dev/null')}")
    print(f"  product_version: {run_command('cat /sys/class/dmi/id/product_version 2>/dev/null')}")
    print(f"  sys_vendor: {run_command('cat /sys/class/dmi/id/sys_vendor 2>/dev/null')}")
    print()
    
    # Kernel
    print("Kernel:")
    print(f"  platform.release(): {platform.release()}")
    print(f"  uname: {run_command('uname -r')}")
    print()
    
    print("=" * 60)
    print("Test complete!")
    print("=" * 60)

if __name__ == '__main__':
    test_all()
