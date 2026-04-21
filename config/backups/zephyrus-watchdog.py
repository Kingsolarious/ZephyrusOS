#!/usr/bin/env python3
"""
Zephyrus Watchdog - Ensures all ASUS shortcuts are always working
Runs every minute via systemd timer. Restarts services if they fail.
"""
import subprocess
import sys
import os
import time

SERVICES = [
    "asusd-user.service",
    "zephyrus-shortcut-listener.service",
    "zephyrus-profile-monitor.service",
]

CONFLICTING_SERVICES = [
    "gu605my-keyboard.service",
    "xbindkeys.service",
    "screenshot-shortcuts.service",
    "asus-performance.service",
    "zephyrus-fn-handler.service",
    "zephyrus-screenshot-listener.service",
]

REQUIRED_FILES = [
    os.path.expanduser("~/.local/bin/zephyrus-shortcut-listener.py"),
    os.path.expanduser("~/.local/bin/zephyrus-profile-monitor.py"),
    os.path.expanduser("~/.config/rog/rog-user.ron"),
]

def check_service(service):
    """Check if a user service is active."""
    result = subprocess.run(
        ["systemctl", "--user", "is-active", service],
        capture_output=True, text=True
    )
    return result.returncode == 0

def restart_service(service):
    """Restart a user service."""
    subprocess.run(["systemctl", "--user", "restart", service], capture_output=True)

def enable_service(service):
    """Enable a user service."""
    subprocess.run(["systemctl", "--user", "enable", service], capture_output=True)

def main():
    issues = []
    
    # Check required files exist
    for f in REQUIRED_FILES:
        if not os.path.exists(f):
            issues.append(f"MISSING FILE: {f}")
    
    # Ensure required services are enabled and running
    for service in SERVICES:
        # Check if enabled
        result = subprocess.run(
            ["systemctl", "--user", "is-enabled", service],
            capture_output=True, text=True
        )
        if result.returncode != 0:
            enable_service(service)
            issues.append(f"RE-ENABLED: {service}")
        
        # Check if running - with retry for services that need time to find devices
        max_retries = 3
        is_running = False
        for attempt in range(max_retries):
            if check_service(service):
                is_running = True
                break
            if attempt < max_retries - 1:
                time.sleep(2)
        
        if not is_running:
            restart_service(service)
            issues.append(f"RESTARTED: {service}")
            # Wait a bit for service to start
            time.sleep(3)
    
    # Ensure conflicting services are disabled and stopped
    for service in CONFLICTING_SERVICES:
        if check_service(service):
            subprocess.run(["systemctl", "--user", "stop", service], capture_output=True)
            subprocess.run(["systemctl", "--user", "disable", service], capture_output=True)
            issues.append(f"STOPPED CONFLICT: {service}")
    
    # Check system asusd service
    result = subprocess.run(
        ["systemctl", "is-active", "asusd.service"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        subprocess.run(["sudo", "systemctl", "start", "asusd.service"], capture_output=True)
        issues.append("RESTARTED SYSTEM asusd.service")
    
    if issues:
        print("Zephyrus Watchdog found issues and fixed them:")
        for issue in issues:
            print(f"  - {issue}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
