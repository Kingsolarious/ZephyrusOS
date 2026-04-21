#!/bin/bash
# Check if you're on the host or in a container

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Host/Container Detection                                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

if [ -n "$container" ]; then
    echo "❌ You are in a CONTAINER: $container"
    echo ""
    echo "You CANNOT install system packages here."
    echo ""
    echo "To get to the host:"
    echo "  1. Open a NEW terminal window (Konsole) from your desktop"
    echo "  2. Run this script again"
    exit 1
else
    echo "✅ You are on the HOST system"
    echo ""
    echo "You can install packages here."
    echo ""
    
    # Check rpm-ostree
    if command -v rpm-ostree &> /dev/null; then
        echo "rpm-ostree is available"
        echo ""
        echo "Current status:"
        rpm-ostree status | head -20
    else
        echo "rpm-ostree not found - you may not be on an atomic system"
    fi
fi
