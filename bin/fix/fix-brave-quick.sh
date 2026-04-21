#!/bin/bash
# Quick Brave fix - just clear cache and relaunch

echo "Quick Brave Fix"
echo "==============="
echo ""

# Kill Brave
pkill -9 -f "com.brave.Browser" 2>/dev/null
sleep 1

# Clear GPU cache
rm -rf ~/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser/Default/GPUCache 2>/dev/null

# Launch with safe flags
flatpak run com.brave.Browser \
    --ozone-platform-hint=auto \
    --enable-features=WaylandWindowDecorations \
    --disable-gpu \
    "$@" &

echo "✓ Brave launched with safe mode"
echo "If this works, run: fix-brave-browser.sh for full fix"
