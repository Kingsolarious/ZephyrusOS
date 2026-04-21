#!/usr/bin/env python3
"""
Zephyrus Profile Monitor

Monitors /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy
and shows OSD notifications when the profile changes (e.g., via FN+F5).
"""
import os
import subprocess
import time

PROFILE_PATH = "/sys/devices/platform/asus-nb-wmi/throttle_thermal_policy"

PROFILE_NAMES = {
    "0": "Balanced",
    "1": "Performance",
    "2": "Quiet",
}

PROFILE_ICONS = {
    "0": "battery-good-symbolic",
    "1": "cpu",
    "2": "battery-low-symbolic",
}

def get_profile():
    try:
        with open(PROFILE_PATH, 'r') as f:
            return f.read().strip()
    except Exception as e:
        print(f"Error reading profile: {e}")
        return None

def show_notification(profile_value):
    name = PROFILE_NAMES.get(profile_value, f"Unknown ({profile_value})")
    icon = PROFILE_ICONS.get(profile_value, "preferences-system")
    
    subprocess.run([
        "notify-send",
        "-a", "Zephyrus OS",
        "-i", icon,
        "Performance Profile",
        f"Switched to {name}"
    ], check=False)
    
    print(f"Profile changed to: {name}", flush=True)

def main():
    print("Zephyrus Profile Monitor started", flush=True)
    
    # Verify the profile file exists
    if not os.path.exists(PROFILE_PATH):
        print(f"ERROR: {PROFILE_PATH} not found", flush=True)
        return 1
    
    last_profile = None
    
    # Initial read
    current = get_profile()
    if current is not None:
        print(f"Current profile: {PROFILE_NAMES.get(current, current)}", flush=True)
        last_profile = current
    
    # Poll for changes
    while True:
        time.sleep(0.2)  # 200ms polling interval
        
        current = get_profile()
        if current is None:
            continue
        
        if current != last_profile:
            show_notification(current)
            last_profile = current

if __name__ == "__main__":
    exit(main() or 0)
