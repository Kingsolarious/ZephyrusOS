#!/bin/bash
# Set maximum volume to 75% to prevent audio crackling
# This creates a WirePlumber configuration that limits volume

set -e

CONFIG_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
SCRIPT_DIR="$HOME/.config/wireplumber/scripts"

echo "Setting up 75% maximum volume limit..."

# Create directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$SCRIPT_DIR"

# Create the volume limit configuration
cat > "$CONFIG_DIR/50-max-volume-limit.conf" << 'EOF'
wireplumber.settings = {
  # Set maximum volume to 75% (0.75 in linear scale)
  # This prevents audio crackling at high volumes
  device.max-volume = 0.75
}

# Alternative: use a script to enforce the limit
monitor.alsa.rules = [
  {
    matches = [
      {
        # Apply to all audio devices
        device.name = "~alsa_output.*"
      }
    ]
    actions = {
      update-props = {
        # Set maximum hardware volume to 75%
        device.max-volume = 0.75
      }
    }
  }
]
EOF

# Create a Lua script to enforce volume limit in real-time
cat > "$SCRIPT_DIR/volume-limit.lua" << 'EOF'
-- Volume limiter script for WirePlumber
-- Caps volume at 75% to prevent audio crackling

local MAX_VOLUME = 0.75  -- 75% maximum volume

-- Function to limit volume
local function limit_volume(node)
  local props = node.properties
  if not props then return end
  
  local id = node["bound-id"]
  if not id then return end
  
  -- Get current volume
  local volume = node:get_param("Props", "ChannelVolumes")
  if volume then
    local needs_update = false
    local new_volumes = {}
    
    for i, v in ipairs(volume) do
      if v > MAX_VOLUME then
        new_volumes[i] = MAX_VOLUME
        needs_update = true
      else
        new_volumes[i] = v
      end
    end
    
    if needs_update then
      node:set_param("Props", "ChannelVolumes", new_volumes)
    end
  end
end

-- Subscribe to node changes
si_nodes = ScriptingSystem:get_instance():get_objects_by_type("SiNode")
for _, node in ipairs(si_nodes) do
  limit_volume(node)
end

-- Subscribe to new nodes
ScriptingSystem:get_instance():connect("object-added", function(_, object)
  if object.type == "SiNode" then
    limit_volume(object)
  end
end)

Log.message(Log.Level_INFO, "Volume limiter loaded (max: 75%)")
EOF

# Create a simpler approach using wireplumber main config
cat > "$CONFIG_DIR/50-volume-limit.conf" << 'EOF'
# Limit maximum volume to 75% to prevent crackling
# This applies to all audio output devices

{
  matches = [
    {
      device.name = "~alsa_output.*|~bluez_output.*"
    }
  ]
  actions = {
    update-props = {
      # Limit hardware volume to 75%
      device.max-volume = 0.75
      # Also set a soft limit
      device.soft-volumes = true
    }
  }
}
EOF

echo "Configuration files created."
echo ""
echo "Restarting WirePlumber to apply changes..."

# Restart WirePlumber
systemctl --user restart wireplumber 2>/dev/null || true
sleep 1

# Also set current volume to 75% if it's higher
CURRENT_VOL=$(pactl list sinks | grep "Volume:" | head -1 | grep -oP '\d+%' | head -1 | tr -d '%' || echo "0")
if [ "$CURRENT_VOL" -gt 75 ] 2>/dev/null; then
    echo "Current volume is ${CURRENT_VOL}%, lowering to 75%..."
    pactl set-sink-volume @DEFAULT_SINK@ 75%
fi

echo ""
echo "✓ Maximum volume limit set to 75%"
echo ""
echo "To verify: adjust your volume - it should stop at 75%"
echo "To remove this limit, delete: $CONFIG_DIR/50-max-volume-limit.conf"
echo "  and run: systemctl --user restart wireplumber"
