#!/bin/bash
# Setup Spectacle screenshots for KDE on Bazzite
# This is the working configuration

set -e

echo "Setting up Spectacle screenshots..."

# Create directories
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/Screenshots

# Create screenshot-region script
cat > ~/.local/bin/screenshot-region << 'INNEREOF'
#!/bin/bash
# Region screenshot using Spectacle GUI
/usr/bin/spectacle -r -g &
INNEREOF

# Create screenshot-full script  
cat > ~/.local/bin/screenshot-full << 'INNEREOF'
#!/bin/bash
# Full screen screenshot using Spectacle
OUTPUT="$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"
mkdir -p "$HOME/Pictures/Screenshots"
/usr/bin/spectacle -f -b -o "$OUTPUT"
if [ -f "$OUTPUT" ]; then
    echo "Screenshot saved: $OUTPUT"
    wl-copy < "$OUTPUT" 2>/dev/null || true
fi
INNEREOF

chmod +x ~/.local/bin/screenshot-region ~/.local/bin/screenshot-full

# Configure KDE shortcuts
kwriteconfig6 --file kglobalshortcutsrc --group "custom_shortcuts" --key "screenshot-region" "Meta+Shift+S,/home/solarious/.local/bin/screenshot-region,Screenshot Region"
kwriteconfig6 --file kglobalshortcutsrc --group "custom_shortcuts" --key "screenshot-full" "Print,/home/solarious/.local/bin/screenshot-full,Screenshot Full"

# Restart KDE shortcuts
killall -9 kglobalacceld 2>/dev/null || true
sleep 1
/usr/libexec/kglobalacceld & 2>/dev/null || true

echo "✅ Screenshots configured!"
echo "   Meta+Shift+S = Region screenshot"
echo "   Print        = Full screen"
