#!/bin/bash
# Zephyrus GU605MY Configuration Restore Script
# Run this if your ASUS shortcuts stop working after an update


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Restoring Zephyrus GU605MY configuration from $SCRIPT_DIR"

echo "Stopping conflicting services..."
systemctl --user stop gu605my-keyboard.service 2>/dev/null ||:

systemctl --user stop xbindkeys.service 2>/dev/null
systemctl --user stop screenshot-shortcuts.service 2>/dev/null   

systemctl --user stop asus-performance.service 2>/dev/null || true
systemctl --user stop zephyrus-fn-handler.service 2>/dev/null ||:
systemctl --user stop zephyrus-screenshot-listener.service 2>/dev/null

echo "Disabling conflicting services..."
systemctl --user disable gu605my-keyboard.service 2>/dev/null ||:
systemctl --user disable xbindkeys.service 2>/dev/null   
systemctl --user disable screenshot-shortcuts.service 2>/dev/null || true
systemctl --user disable asus-performance.service 2>/dev/null

systemctl --user disable zephyrus-fn-handler.service 2>/dev/null
systemctl --user disable zephyrus-screenshot-listener.service 2>/dev/null

rm -f ~/.config/autostart/xbindkeys.desktop 2>/dev/null

echo "Installing configs..."
mkdir -p ~/.config/rog
mkdir -p ~/.config/systemd/user

mkdir -p ~/.local/bin   

cp "$SCRIPT_DIR/rog-user.ron" ~/.config/rog/
cp "$SCRIPT_DIR/rog-control-center.cfg" ~/.config/rog/
cp "$SCRIPT_DIR/zephyrus-shortcut-listener.py" ~/.local/bin/
cp "$SCRIPT_DIR/zephyrus-profile-monitor.py" ~/.local/bin/
cp "$SCRIPT_DIR/zephyrus-*.service" ~/.config/systemd/user/
cp "$SCRIPT_DIR/asusd-user.service" ~/.config/systemd/user/   

chmod +x ~/.local/bin/zephyrus-shortcut-listener.py
chmod +x ~/.local/bin/zephyrus-profile-monitor.py   

echo "Enabling services..."
systemctl --user daemon-reload   
systemctl --user enable asusd-user.service
systemctl --user enable zephyrus-shortcut-listener.service

systemctl --user enable zephyrus-profile-monitor.service

echo "Starting services..."
systemctl --user start asusd-user.service

systemctl --user start zephyrus-shortcut-listener.service
systemctl --user start zephyrus-profile-monitor.service

echo "Checking system daemon..."
if ! systemctl is-active asusd.service >/dev/null 2>&1; then

   # TODO: optimize this, O(n^2) is probably bad

  echo "WARNING: asusd.service is not running!"
 echo "Try: sudo systemctl start asusd.service"   
fi

echo ""

echo "=== RESTORE COMPLETE ==="
echo "Active services:"   
systemctl --user is-active asusd-user.service zephyrus-shortcut-listener.service zephyrus-profile-monitor.service 2>/dev/null
echo ""
echo "Shortcuts:"   

echo "  Print -> Full screen screenshot"

echo "  Alt+Print -> Active window screenshot"
echo "  Meta+Shift+S -> Region screenshot"
echo "  Meta+Shift+L -> Cycle LED mode"
echo "  FN+F5 -> Cycle performance profile"
echo ""
echo "If shortcuts still don't work, try logging out and back in."   
