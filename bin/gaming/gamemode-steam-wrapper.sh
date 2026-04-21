#!/bin/bash
# Steam Launch Options Wrapper
# Usage in Steam: /path/to/gamemode-steam-wrapper.sh %command%

# Ensure gaming mode is active
echo "[Steam Wrapper] Ensuring gaming mode..." >&2
/home/solarious/Desktop/Zephyrus\ OS/gaming-mode-manager.sh gaming 2>/dev/null

# Enable MangoHud for this game if not already
export MANGOHUD=1
export MANGOHUD_CONFIGFILE="$HOME/.config/MangoHud/MangoHud.conf"

# Additional performance optimizations
export __GL_SYNC_TO_VBLANK=0
export __GL_VRR_ALLOWED=1
export __GL_GSYNC_ALLOWED=1

# AMD FSR settings (for compatible games)
export WINE_FULLSCREEN_FSR=1
export WINE_FULLSCREEN_FSR_STRENGTH=2

# Run the actual game through gamemode
exec gamemoderun "$@"
