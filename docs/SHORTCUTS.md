# Zephyrus OS Shortcuts Configuration

## Active Shortcuts (via evdev listener)

| Key | Action |
|-----|--------|
| `Print` | Fullscreen screenshot (background, no notification) |
| `Alt+Print` | Active window screenshot (background, no notification) |
| `Meta+Shift+S` | Region screenshot (GUI overlay with `-i` new instance) |
| `FN+F5` | Cycle performance profile (Balanced → Performance → Quiet) |

## How It Works

- **Unified Listener**: `~/.local/bin/zephyrus-shortcut-listener.py` monitors the ITE keyboard device non-exclusively
- **Profile Monitor**: `~/.local/bin/zephyrus-profile-monitor.py` shows OSD notification on profile change with stabilization debounce
- **Profile Watch**: System service syncs OEM settings (power limits, GPU, boost) when profile changes

## Services

| Service | Type | Status |
|---------|------|--------|
| `zephyrus-shortcut-listener.service` | User | Enabled, Running |
| `zephyrus-profile-monitor.service` | User | Enabled, Running |
| `zephyrus-profile-watch.service` | System | Enabled, Running |
| `zephyrus-shortcut-guard.service` | User | Enabled |
| `asusd.service` | System | Enabled, Running |
| `asusd-user.service` | User | Enabled, Running |

## Disabled Conflicting Services

- `gu605my-keyboard.service`
- `xbindkeys.service`
- `screenshot-shortcuts.service`
- `asus-performance.service`

## KDE Shortcuts Locked

- `~/.config/spectaclerc` — writable (Spectacle needs to save settings), but `[Shortcuts]` section is kept empty
- `~/.config/kglobalshortcutsrc` — read-only (`chmod 444`)
- Guard script clears any shortcuts that get added back

## System Updates Disabled

- `uupd.timer` — stopped and disabled
- `uupd` system module — disabled in `/etc/uupd/config.json`
- `rpm-ostreed-automatic.timer` — masked
- Flatpak and Distrobox updates still work

## Touchpad Gestures

- 4-finger swipe up → Overview (configured in kwinrc)
- Works best with slow, deliberate swipes
- Fast swipes may be rejected due to ASUS touchpad finger-tracking behavior

## Files

| File | Purpose |
|------|---------|
| `~/.local/bin/zephyrus-shortcut-listener.py` | Main shortcut listener |
| `~/.local/bin/zephyrus-profile-monitor.py` | Profile change notifications |
| `~/.local/lib/zephyrus/enforce-shortcuts.sh` | Shortcut guard script |
| `/usr/local/bin/zephyrus-profile-watch` | System profile sync watcher |
| `/usr/local/bin/zephyrus-profile-sync` | OEM profile settings sync |
| `/etc/uupd/config.json` | Update daemon config (system updates disabled) |
