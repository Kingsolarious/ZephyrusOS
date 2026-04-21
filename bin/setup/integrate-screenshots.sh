#!/bin/bash
# Integrate screenshot configuration into Zephyrus OS build
# Run this when building the OS image

set -e

echo "Integrating screenshot configuration into OS..."

# Create system-wide scripts in /usr/local/bin
cat > /usr/local/bin/screenshot-region << 'INNEREOF'
#!/bin/bash
/usr/bin/spectacle -r -g &
INNEREOF

cat > /usr/local/bin/screenshot-full << 'INNEREOF'
#!/bin/bash
OUTPUT="$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"
mkdir -p "$HOME/Pictures/Screenshots"
/usr/bin/spectacle -f -b -o "$OUTPUT"
if [ -f "$OUTPUT" ]; then
    echo "Screenshot saved: $OUTPUT"
    wl-copy < "$OUTPUT" 2>/dev/null || true
fi
INNEREOF

chmod +x /usr/local/bin/screenshot-region /usr/local/bin/screenshot-full

# Create default KDE shortcuts config
cat > /usr/share/kglobalaccel/org.kde.spectacle.desktop << 'INNEREOF'
[services][org.kde.spectacle.desktop]
RectangularRegionScreenShot=Meta+Shift+S,Meta+Shift+S,Region Screenshot
FullScreenScreenShot=Print,Print,Full Screen Screenshot
ActiveWindowScreenShot=Alt+Print,Alt+Print,Active Window
INNEREOF

echo "✅ Screenshot integration complete"
