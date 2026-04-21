#!/usr/bin/env python3
"""
Screenshot Key Listener

Listens for screenshot keys and calls spectacle via DBus.
Works around broken kglobalaccel in KDE Plasma 6.

Keys:
- Print -> Full screen screenshot
- Alt+Print -> Active window screenshot  
- Meta+Shift+S -> Rectangular region screenshot
"""
import os
import sys
import subprocess
import select
import fcntl
from evdev import InputDevice, ecodes

# Track modifier states
modifiers = {
    'alt': False,
    'meta': False,
    'shift': False,
    'ctrl': False,
}

def find_keyboards():
    """Find all keyboard devices."""
    keyboards = []
    for dev_name in os.listdir('/dev/input'):
        if not dev_name.startswith('event'):
            continue
        path = f'/dev/input/{dev_name}'
        try:
            dev = InputDevice(path)
            if ecodes.EV_KEY in dev.capabilities():
                # Check if it has regular keyboard keys
                keys = dev.capabilities()[ecodes.EV_KEY]
                if ecodes.KEY_A in keys and ecodes.KEY_ENTER in keys:
                    keyboards.append(dev)
        except (OSError, PermissionError):
            pass
    return keyboards

def set_nonblocking(dev):
    """Set device to non-blocking mode."""
    flags = fcntl.fcntl(dev.fd, fcntl.F_GETFL)
    fcntl.fcntl(dev.fd, fcntl.F_SETFL, flags | os.O_NONBLOCK)

def take_screenshot(mode):
    """Call spectacle via DBus."""
    if mode == 'fullscreen':
        cmd = ['qdbus', 'org.kde.Spectacle', '/', 'org.kde.Spectacle.FullScreen', '0']
    elif mode == 'activewindow':
        cmd = ['qdbus', 'org.kde.Spectacle', '/', 'org.kde.Spectacle.ActiveWindow', '1', '0', '0']
    elif mode == 'region':
        cmd = ['qdbus', 'org.kde.Spectacle', '/', 'org.kde.Spectacle.RectangularRegion', '0']
    else:
        return
    
    subprocess.run(cmd, check=False, capture_output=True)
    print(f"Screenshot: {mode}", flush=True)

def handle_key(event):
    """Handle key events."""
    code = event.code
    value = event.value  # 0=release, 1=press, 2=repeat
    
    # Update modifiers
    if code == ecodes.KEY_LEFTALT or code == ecodes.KEY_RIGHTALT:
        modifiers['alt'] = value != 0
    elif code == ecodes.KEY_LEFTMETA or code == ecodes.KEY_RIGHTMETA:
        modifiers['meta'] = value != 0
    elif code == ecodes.KEY_LEFTSHIFT or code == ecodes.KEY_RIGHTSHIFT:
        modifiers['shift'] = value != 0
    elif code == ecodes.KEY_LEFTCTRL or code == ecodes.KEY_RIGHTCTRL:
        modifiers['ctrl'] = value != 0
    
    # Only handle key press (value == 1)
    if value != 1:
        return
    
    # Print key -> Full screen
    if code == ecodes.KEY_PRINT:
        if modifiers['alt']:
            take_screenshot('activewindow')
        else:
            take_screenshot('fullscreen')
    
    # S key with Meta+Shift -> Region
    elif code == ecodes.KEY_S:
        if modifiers['meta'] and modifiers['shift']:
            take_screenshot('region')

def main():
    keyboards = find_keyboards()
    if not keyboards:
        print("No keyboards found", flush=True)
        return 1
    
    print(f"Monitoring {len(keyboards)} keyboards:", flush=True)
    for dev in keyboards:
        print(f"  {dev.path}: {dev.name}", flush=True)
        set_nonblocking(dev)
    
    try:
        while True:
            fds = [dev.fd for dev in keyboards]
            readable, _, _ = select.select(fds, [], [], 0.1)
            for fd in readable:
                for dev in keyboards:
                    if dev.fd == fd:
                        try:
                            for event in dev.read():
                                if event.type == ecodes.EV_KEY:
                                    handle_key(event)
                        except OSError:
                            pass
    except KeyboardInterrupt:
        pass
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
