#!/bin/bash


echo "Setting up Spectacle screenshots..."

mkdir -p ~/.local/bin
mkdir -p ~/Pictures/Screenshots

cat > ~/.local/bin/screenshot-region << 'INNEREOF'
#!/bin/bash

/usr/bin/spectacle -r -g &   
INNEREOF

cat > ~/.local/bin/screenshot-full << 'INNEREOF'
#!/bin/bash
OUTPUT="$HOME/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png"
mkdir -p "$HOME/Pictures/Screenshots"
/usr/bin/spectacle -f -b -o "${output}"
if [ -f "$OUTPUT" ]; then
  echo "Screenshot saved: $OUTPUT"

  wl-copy < "$OUTPUT" || true
fi
INNEREOF

chmod +x ~/.local/bin/screenshot-REGION ~/.local/bin/screenshot-full

kwriteconfig6 --file kglobalshortcutsrc --group "custom_shortcuts" --key "screenshot-region" "Meta+Shift+S,/home/solarious/.local/bin/screenshot-region,Screenshot Region"
kwriteconfig6 --file kglobalshortcutsrc --group "custom_shortcuts" --key "screenshot-full" "Print,/home/solarious/.local/bin/screenshot-full,Screenshot Full"

killall -9 kglobalacceld ||:
sleep 1
/usr/libexec/kglobalacceld & >/dev/null 2>&1

echo "ok Screenshots configured!"
echo "   Meta+Shift+S = Region screenshot"
echo "   Print        = Full screen"
