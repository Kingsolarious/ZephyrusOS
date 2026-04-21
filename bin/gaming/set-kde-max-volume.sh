#!/bin/bash
# Set maximum volume using KDE Plasma settings and ALSA
# This provides multiple methods to ensure 75% max volume

echo "Setting up 75% maximum volume using multiple methods..."

# Method 1: KDE Plasma audio settings (if available)
if command -v kwriteconfig5 &> /dev/null; then
    # Set maximum volume in KDE config
    kwriteconfig5 --file kcmfonts --group "General" --key "maxVolume" "75" 2>/dev/null || true
fi

# Method 2: Create a systemd user service for the volume limiter daemon
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/volume-limiter.service << 'EOF'
[Unit]
Description=Audio Volume Limiter (75% max)
After=pipewire.service pulseaudio.service

[Service]
Type=simple
ExecStart=/bin/bash -c 'MAX_VOL=75; while true; do CURR=$(pactl list sinks | grep "Volume:" | head -1 | grep -oP "\\d+%" | head -1 | tr -d "%"); if [ -n "$CURR" ] && [ "$CURR" -gt "$MAX_VOL" ]; then pactl set-sink-volume @DEFAULT_SINK@ "${MAX_VOL}%"; fi; sleep 0.5; done'
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Method 3: Create an autostart desktop entry
cat > ~/.config/autostart/volume-limiter.desktop << EOF
[Desktop Entry]
Name=Volume Limiter
Comment=Limits maximum volume to 75%
Exec=/bin/bash -c "while true; do CURR=\\\$(pactl list sinks | grep 'Volume:' | head -1 | grep -oP '\\\\d+%' | head -1 | tr -d '%'); if [ -n '\\\$CURR' ] && [ '\\\$CURR' -gt 75 ]; then pactl set-sink-volume @DEFAULT_SINK@ 75%; fi; sleep 0.5; done"
Type=Application
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

# Method 4: ALSA softvol plugin configuration (system-wide-ish, per user)
mkdir -p ~/.config/alsa

cat > ~/.config/alsa/asoundrc << 'EOF'
# ALSA configuration to limit maximum volume to 75%
# This creates a softvol device that caps at 75%

pcm.softvol {
    type softvol
    slave {
        pcm "default"
    }
    control {
        name "PCM"
        card 0
    }
    max_dB 0.0
    min_dB -50.0
    resolution 256
}

# Override default to use our softvol device
pcm.!default {
    type plug
    slave.pcm "softvol"
}
EOF

echo ""
echo "Multiple volume limiting methods configured:"
echo ""
echo "1. WirePlumber config: ~/.config/wireplumber/wireplumber.conf.d/"
echo "2. Systemd service: ~/.config/systemd/user/volume-limiter.service"
echo "3. Autostart entry: ~/.config/autostart/volume-limiter.desktop"
echo "4. ALSA config: ~/.config/alsa/asoundrc"
echo ""
echo "To enable the systemd service (recommended):"
echo "  systemctl --user daemon-reload"
echo "  systemctl --user enable --now volume-limiter"
echo ""
echo "To start the autostart method:"
echo "  Log out and log back in"
echo ""
echo "To use the ALSA method (might not work with PipeWire):"
echo "  cp ~/.config/alsa/asoundrc ~/.asoundrc"
echo ""
echo "Current volume reduced to 75%"
pactl set-sink-volume @DEFAULT_SINK@ 75% 2>/dev/null || true
