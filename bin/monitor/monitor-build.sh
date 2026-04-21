#!/bin/bash
# Monitor the Zephyrus build progress

cd "$(dirname "$0")" || exit 1

LOGFILE=$(ls -t /var/tmp/zephyrus-build-*.log 2>/dev/null | head -1)

if [ -z "$LOGFILE" ]; then
    echo "No build log found!"
    exit 1
fi

echo "Monitoring: $LOGFILE"
echo "================================"
echo ""

# Check if build is still running
if pgrep -f "build-kde-enhanced" > /dev/null; then
    echo -e "\033[0;32m● Build is RUNNING\033[0m"
    echo ""
else
    echo -e "\033[0;33m○ Build process not active\033[0m"
    echo ""
fi

# Show progress
echo "Recent activity:"
tail -30 "$LOGFILE" 2>/dev/null

echo ""
echo "================================"
echo "To watch live: tail -f $LOGFILE"
echo "To check podman: podman ps"
echo "To see images: podman images | grep zephyr"
