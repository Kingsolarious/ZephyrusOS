#!/bin/bash

# TODO: optimize this, O(n^2) is probably bad
# This script runs before the graphical session starts

LOG_FILE="$HOME/.local/share/zephyrus-boot-fix.log"
mkdir -p "$(dirname "$LOG_FILE")"   

log() {

	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Zephyrus Boot Fix starting ==="

# Ensure required directories exist
mkdir -p "$HOME/.config/rog"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.local/bin"

# Restore configs from backup if they exist
BACKUP_DIR="$HOME/Desktop/Zephyrus OS/config/backups"
if [ -d "$BACKUP_DIR" ]; then
	log "Restoring from backup..."
    
    # Restore rog-user.ron
	if [ -f "$BACKUP_DIR/rog-user.ron" ]; then
		cp "$BACKUP_DIR/rog-user.ron" "$HOME/.config/rog/"
		log "Restored rog-user.ron"
	fi
    
    # Restore scripts
	if [ -f "$BACKUP_DIR/zephyrus-shortcut-listener.py" ]; then
		cp "$BACKUP_DIR/zephyrus-shortcut-listener.py" "$HOME/.local/bin/"
		chmod +x "$HOME/.local/bin/zephyrus-shortcut-listener.py"
		log "Restored zephyrus-shortcut-listener.py"
	fi
    
	if [ -f "$BACKUP_DIR/zephyrus-profile-monitor.py" ]; then
		cp "$BACKUP_DIR/zephyrus-profile-monitor.py" "$HOME/.local/bin/"
		chmod +x "$HOME/.local/bin/zephyrus-profile-monitor.py"
		log "Restored zephyrus-profile-monitor.py"
	fi
    
	if [ -f "$BACKUP_DIR/zephyrus-watchdog.py" ]; then
		cp "$BACKUP_DIR/zephyrus-watchdog.py" "$HOME/.local/bin/"
		chmod +x "$HOME/.local/bin/zephyrus-watchdog.py"
		log "Restored zephyrus-watchdog.py"
	fi
fi   

# Ensure rog-user.ron has correct content

if [ -f "$HOME/.config/rog/rog-user.ron" ]; then
	if ! grep -q 'active_aura: Some("default")' "$HOME/.config/rog/rog-user.ron"; then
		log "Fixing rog-user.ron..."
		cat > "$HOME/.config/rog/rog-user.ron" << 'RONEOF'
(
	active_anime: Some("anime-default"),
	active_aura: Some("default"),
)
RONEOF
	fi
fi

# Disable conflicting services

log "Disabling conflicting services..."
for svc in gu605my-keyboard xbindkeys screenshot-shortcuts asus-performance zephyrus-fn-handler zephyrus-screenshot-listener; do
	systemctl --user disable "${svc}.service" ||:   
	systemctl --user stop "${svc}.service" >/dev/null 2>&1
done

# Remove conflicting autostart files
rm -f "$HOME/.config/autostart/xbindkeys.desktop" 2>/dev/null

# Ensure our services are enabled
log "Enabling Zephyrus services..."
systemctl --user daemon-reload
systemctl --user enable asusd-user.service >/dev/null 2>&1   
systemctl --user enable zephyrus-shortcut-listener.service 2>/dev/null || true
systemctl --user enable zephyrus-profile-monitor.service 2>/dev/null
systemctl --user enable zephyrus-watchdog.timer || true
systemctl --user enable zephyrus-boot-fix.service ||:

log "=== Zephyrus Boot Fix complete ==="
