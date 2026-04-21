#!/bin/bash
# Quick script to enable external displays using kscreen-doctor
# Run this after plugging in your external monitor

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Enable External Display                                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Show current outputs
echo "Current display outputs:"
echo "========================"
kscreen-doctor --outputs 2>/dev/null | grep -E "Output:|enabled|connected"
echo ""

# Get list of disconnected outputs that might be external monitors
echo "Checking for external displays..."
echo ""

# Try to find outputs that aren't the internal panel
INTERNAL=$(kscreen-doctor --outputs 2>/dev/null | grep -i "panel\|eDP" | head -1)
EXTERNAL_OUTPUTS=$(kscreen-doctor --outputs 2>/dev/null | grep -v "eDP\|Panel" | grep "Output:" | awk '{print $2}')

if [ -z "$EXTERNAL_OUTPUTS" ]; then
    echo "No external display outputs found."
    echo ""
    echo "Possible reasons:"
    echo "  1. Monitor not physically connected"
    echo "  2. Cable/adapter issue"
    echo "  3. External ports wired to NVIDIA GPU (need proprietary driver)"
    echo "  4. Display needs to be enabled in settings"
    echo ""
    echo "Try: System Settings → Display & Monitor → Displays"
    exit 1
fi

echo "Found external outputs: $EXTERNAL_OUTPUTS"
echo ""

# Enable each external output found
for output in $EXTERNAL_OUTPUTS; do
    echo "Attempting to enable $output..."
    
    # Enable the output
    kscreen-doctor output.$output.enable 2>/dev/null
    
    # Wait a moment
    sleep 1
    
    # Check if it's now connected/enabled
    STATUS=$(kscreen-doctor --outputs 2>/dev/null | grep -A 2 "Output:.*$output" | grep -c "enabled")
    
    if [ "$STATUS" -gt 0 ]; then
        echo "  ✓ $output enabled!"
        
        # Set a reasonable default mode (1080p@60)
        kscreen-doctor output.$output.mode.1920x1080@60 2>/dev/null
        
        # Position to the right of internal display
        kscreen-doctor output.$output.position.2560,0 2>/dev/null
        
        echo "  ✓ Set to 1920x1080@60, positioned to the right"
    else
        echo "  ✗ Could not enable $output"
        echo "    (Monitor may not be detected - check cable/NVIDIA driver)"
    fi
    echo ""
done

echo ""
echo "Display configuration applied."
echo ""
echo "To adjust manually: System Settings → Display & Monitor → Displays"
