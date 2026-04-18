#!/usr/bin/env python3
"""
Zephyrus FN+F5 Profile Switcher

On GU605MY, FN+F5 emits KEY_PROG4 on the ITE keyboard device.
This script tries to grab the device and listen for the key.
If that fails (e.g., KWin has the device), it falls back to
monitoring the throttle_thermal_policy sysfs file for changes.
"""
import os
import sys
import time
import fcntl
import subprocess
from evdev import InputDevice, ecodes

PROFILE_PATH = "/sys/devices/platform/asus-nb-wmi/throttle_thermal_policy"
PROFILE_NAMES = {"0": "Balanced", "1": "Performance", "2": "Quiet"}

def find_ite_keyboard():
    """Find the ITE keyboard device that emits KEY_PROG4 for FN+F5."""
    for dev in os.listdir('/dev/input'):
        if not dev.startswith('event'):
            continue
        path = f'/dev/input/{dev}'
        try:
            d = InputDevice(path)
            if "ITE" in d.name and ecodes.EV_KEY in d.capabilities():
                if ecodes.KEY_PROG4 in d.capabilities()[ecodes.EV_KEY]:
                    return d
        except (OSError, PermissionError):
            continue
    return None

def cycle_profile():
    """Cycle to next profile and show notification."""
    subprocess.run(["asusctl", "profile", "next"], check=False)
    subprocess.run([
        "notify-send",
        "-a", "Zephyrus OS",
        "-i", "cpu",
        "Performance Profile",
        "Switched to next profile"
    ], check=False)

def get_profile():
    """Read current profile from sysfs."""
    try:
        with open(PROFILE_PATH, 'r') as f:
            return f.read().strip()
    except Exception:
        return None

def monitor_evdev(dev):
    """Monitor the device for KEY_PROG4 events."""
    print(f"Listening on {dev.path}: {dev.name}", flush=True)
    
    # Grab the device using evdev's grab method (keeps fd open)
    try:
        dev.grab()
        print("Device grabbed successfully", flush=True)
    except OSError as e:
        print(f"Failed to grab device: {e}", flush=True)
        return False
    
    try:
        for event in dev.read_loop():
            if (event.type == ecodes.EV_KEY and 
                event.code == ecodes.KEY_PROG4 and 
                event.value == 1):  # key press
                print("FN+F5 (KEY_PROG4) pressed - cycling profile", flush=True)
                cycle_profile()
    except KeyboardInterrupt:
        pass
    finally:
        dev.ungrab()
    
    return True

def monitor_sysfs():
    """Monitor throttle_thermal_policy for changes."""
    print("Falling back to sysfs monitoring", flush=True)
    if not os.path.exists(PROFILE_PATH):
        print(f"ERROR: {PROFILE_PATH} not found", flush=True)
        return 1
    
    last_profile = get_profile()
    print(f"Current profile: {PROFILE_NAMES.get(last_profile, last_profile)}", flush=True)
    
    while True:
        time.sleep(0.2)
        current = get_profile()
        if current is None:
            continue
        if current != last_profile:
            name = PROFILE_NAMES.get(current, f"Unknown ({current})")
            print(f"Profile changed to: {name}", flush=True)
            subprocess.run([
                "notify-send",
                "-a", "Zephyrus OS",
                "-i", "cpu",
                "Performance Profile",
                f"Switched to {name}"
            ], check=False)
            last_profile = current

def main():
    dev = find_ite_keyboard()
    if dev:
        print(f"Found device: {dev.path} - {dev.name}", flush=True)
        if monitor_evdev(dev):
            return 0
    
    # Fallback to sysfs monitoring
    monitor_sysfs()

if __name__ == "__main__":
    sys.exit(main() or 0)
