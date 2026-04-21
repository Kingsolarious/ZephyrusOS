#!/usr/bin/env python3
"""
Zephyrus Shortcut Listener - Single non-exclusive listener for all shortcuts
Handles: Print, Alt+Print, Meta+Shift+S, FN+F5 profile cycling
"""
import os, sys, fcntl, select, subprocess, time
from evdev import InputDevice, ecodes

PROFILE_PATH = "/sys/devices/platform/asus-nb-wmi/throttle_thermal_policy"
PROFILE_NAMES = {"0": "Balanced", "1": "Performance", "2": "Quiet"}

# Debounce timestamps
_last_fn_f5 = 0
_last_print = 0
_last_region = 0

def find_ite_keyboard():
    for dev in os.listdir('/dev/input'):
        if not dev.startswith('event'):
            continue
        try:
            d = InputDevice(f'/dev/input/{dev}')
            if "ITE" in d.name and ecodes.EV_KEY in d.capabilities():
                return d
        except (OSError, PermissionError):
            continue
    return None

def set_nonblocking(dev):
    flags = fcntl.fcntl(dev.fd, fcntl.F_GETFL)
    fcntl.fcntl(dev.fd, fcntl.F_SETFL, flags | os.O_NONBLOCK)

def cycle_profile():
    subprocess.run(["asusctl", "profile", "next"], check=False, capture_output=True)
    try:
        with open(PROFILE_PATH, 'r') as f:
            profile = f.read().strip()
        name = PROFILE_NAMES.get(profile, f"Unknown ({profile})")
        subprocess.run([
            "notify-send", "-a", "Zephyrus OS", "-i", "cpu",
            "Performance Profile", f"Switched to {name}"
        ], check=False, capture_output=True)
        print(f"Profile cycled to {name}", flush=True)
    except Exception as e:
        print(f"Profile cycled (could not read: {e})", flush=True)

def screenshot_fullscreen():
    subprocess.Popen(["spectacle", "-f", "-b", "-n"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("Screenshot: Full screen", flush=True)

def screenshot_active_window():
    subprocess.Popen(["spectacle", "-a", "-b", "-n"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("Screenshot: Active window", flush=True)

def screenshot_region():
    # Use -r without -c so the GUI shows for region selection
    # -b = background (don't show main window)
    # But for region, we NEED the GUI to show the selection overlay
    subprocess.Popen(["spectacle", "-r"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("Screenshot: Region", flush=True)

def monitor_device(dev):
    global _last_fn_f5, _last_print, _last_region
    
    set_nonblocking(dev)
    meta_pressed = False
    alt_pressed = False
    shift_pressed = False
    
    print(f"Monitoring {dev.name}", flush=True)
    
    try:
        while True:
            readable, _, _ = select.select([dev.fd], [], [], 0.1)
            if not readable:
                continue
            
            try:
                for event in dev.read():
                    if event.type != ecodes.EV_KEY:
                        continue
                    
                    # Track modifiers
                    if event.code == ecodes.KEY_LEFTMETA:
                        meta_pressed = event.value in (1, 2)
                    elif event.code == ecodes.KEY_LEFTALT:
                        alt_pressed = event.value in (1, 2)
                    elif event.code == ecodes.KEY_LEFTSHIFT:
                        shift_pressed = event.value in (1, 2)
                    
                    # Key press events
                    elif event.value == 1:
                        # FN+F5 (KEY_PROG4)
                        if event.code == ecodes.KEY_PROG4:
                            current_time = time.time()
                            if current_time - _last_fn_f5 > 0.5:
                                cycle_profile()
                                _last_fn_f5 = current_time
                        
                        # Print key
                        elif event.code == ecodes.KEY_PRINT:
                            current_time = time.time()
                            if current_time - _last_print > 0.5:
                                if alt_pressed:
                                    screenshot_active_window()
                                else:
                                    screenshot_fullscreen()
                                _last_print = current_time
                        
                        # Meta+Shift+S = Region screenshot
                        elif event.code == ecodes.KEY_S and meta_pressed and shift_pressed:
                            current_time = time.time()
                            if current_time - _last_region > 0.5:
                                screenshot_region()
                                _last_region = current_time
                                
            except (OSError, BlockingIOError):
                continue
    except KeyboardInterrupt:
        print("\nShutting down...", flush=True)

def main():
    dev = find_ite_keyboard()
    if not dev:
        print("No ITE device found!", file=sys.stderr)
        return 1
    monitor_device(dev)
    return 0

if __name__ == "__main__":
    sys.exit(main() or 0)
