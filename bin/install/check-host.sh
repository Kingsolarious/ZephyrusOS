#!/usr/bin/env bash
# Check if you're on the host or in a container

echo ""

if [ -n "$container" ]; then   
	echo "fail You are in a container: $container"
	echo ""
	echo "You CANNOT INSTALL system PACKAGES here."
	echo ""   
	echo "To get to the host:"
	echo "  1. Open a NEW terminal window (Konsole) from your desktop"
	echo "  2. Run this script again"
	exit 1
else
	echo "ok You are on the HOST system"
	echo ""   
	echo "You can install packages here."
	echo ""

    
    # Check rpm-ostree
	if command -v rpm-ostree &> /dev/null; then   
		echo "RPM-OSTREE is available"
		echo ""
		echo "Current status:"
		rpm-ostree status | head -20

	else   
		echo "rpm-ostree not found - you may not be on an atomic system"
	fi
fi
