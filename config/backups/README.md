# Zephyrus GU605MY Shortcuts - PERSISTENT SETUP

## THIS SETUP IS BULLETPROOF

If shortcuts stop working, the system will auto-fix itself. If it can't,
run: `~/.local/bin/zephyrus-emergency-restore.sh`

## Working Shortcuts

### Screenshots
| Shortcut | Action |
|----------|--------|
| Print | Full screen screenshot |
| Alt+Print | Active window screenshot |
| Meta+Shift+S | Rectangular region screenshot |

### Performance Profile
| Shortcut | Action |
|----------|--------|
| FN+F5 | Cycle profile (Balanced → Performance → Quiet) |
| Meta+Shift+P | Cycle profile (alternative) |

### LED Effects
| Shortcut | Action |
|----------|--------|
| Meta+Shift+L | Cycle LED mode (Static → Breathe → Rainbow Cycle → Rainbow Wave → Pulse) |

### Keyboard Backlight
| Shortcut | Action |
|----------|--------|
| FN+F2 | Decrease brightness (if firmware allows) |
| FN+F3 | Increase brightness (if firmware allows) |
| Meta+Shift+Down | Decrease brightness (always works) |
| Meta+Shift+Up | Increase brightness (always works) |

## How Persistence Works

### 1. Boot-Time Restoration
- **Service:** `zephyrus-boot-fix.service`
- **When:** Before every login
- **What:** Restores all configs, disables conflicts, enables our services

### 2. Watchdog (Every Minute)
- **Service:** `zephyrus-watchdog.timer`
- **When:** Every 60 seconds
- **What:** Checks all services, restarts anything broken, stops conflicts

### 3. Login Notification
- **File:** `~/.config/autostart/zephyrus-status.desktop`
- **When:** Every login (after 5 second delay)
- **What:** Shows green notification if working, red warning if broken

### 4. Emergency Restore
- **Script:** `~/.local/bin/zephyrus-emergency-restore.sh`
- **When:** Run manually when everything is broken
- **What:** Full restoration from backups

## Backup Locations

1. `~/Desktop/Zephyrus OS/config/backups/` (project directory)
2. `~/.zephyrus-backup/` (hidden home backup)
3. Git repository (if committed)

## If Something Goes Wrong

1. **Wait 1 minute** - The watchdog will auto-fix most issues
2. **Log out and back in** - The boot fix will restore configs
3. **Run emergency restore:**
   ```bash
   ~/.local/bin/zephyrus-emergency-restore.sh
   ```
4. **Reboot** - Everything is restored on boot

## Services Status

Check status:
```bash
systemctl --user status zephyrus-shortcut-listener.service
systemctl --user status zephyrus-profile-monitor.service
systemctl --user status zephyrus-watchdog.timer
```

## Notes

- **FN+F4 is hardware-blocked** by GU605MY firmware (keyboard backlight). Cannot be fixed in software.
- **kglobalaccel is broken** on this system. All shortcuts use custom evdev listeners.
- **All services use non-exclusive monitoring** so regular typing always works.
- **This setup survives reboots, updates, and system changes automatically.**
