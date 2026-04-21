#!/bin/bash
# Start Maximum Monitoring Setup
# Launches all monitoring systems

echo "🚀 Starting Maximum Monitoring Setup..."

# 1. KDE Widget (should already be in panel from manual add)
echo "✓ KDE Widget: Add manually to panel if not already there"
echo "  Right-click panel → Add Widgets → 'ROG Monitor'"

# 2. Terminal Desktop Monitor (floating window)
echo ""
echo "🖥️  Starting Terminal Monitor..."
if command -v konsole &> /dev/null; then
    # Launch konsole with profile
    konsole -p TerminalColumns=45 -p TerminalRows=20 \
        -e bash -c '~/Desktop/Zephyrus\ OS/rog-monitor-conky.sh run' &
    sleep 1
    # Move window to top-left (using xdotool if available)
    if command -v xdotool &> /dev/null; then
        sleep 1
        xdotool search --class konsole windowmove 20 50 2>/dev/null
    fi
    echo "✓ Terminal monitor launched"
else
    # Fallback to generic terminal
    xterm -geometry 45x20+20+50 -e '~/Desktop/Zephyrus\ OS/rog-monitor-conky.sh run' &
    echo "✓ Terminal monitor launched (xterm)"
fi

# 3. System notifications for high temps
echo ""
echo "🌡️  Starting thermal watchdog..."
~/Desktop/Zephyrus\ OS/thermal-watchdog.sh &
echo "✓ Thermal watchdog started"

# 4. MangoHud is already configured for Steam games
echo ""
echo "🎮 MangoHud: Add 'mangohud %command%' to Steam games"
echo "  Toggle in-game: Shift+F12"

echo ""
echo "═══════════════════════════════════════════════════"
echo "✅ MAXIMUM MONITORING ACTIVE"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Active monitors:"
echo "  🖥️  KDE Panel Widget      → Manual add to panel"
echo "  📟 Terminal Monitor      → Floating window (top-left)"
echo "  🔔 Thermal Watchdog      → Background alerts"
echo "  🎮 MangoHud             → In Steam games"
echo ""
echo "Commands to run anytime:"
echo "  nvtop                   → GPU terminal monitor"
echo "  btop                    → System resources"
echo "  sensors                 → Quick temps"
echo ""
echo "Press Ctrl+C to stop terminal monitor"
