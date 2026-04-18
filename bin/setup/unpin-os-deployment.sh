#!/bin/bash
# Unpin the Zephyrus OS deployment so updates can be applied.
# Run this when you WANT to update your system.   



echo ""

echo -e "Unpinning deployments..."
sudo ostree admin pin -u 0 2>/dev/null || true
sudo ostree admin pin -u 1 >/dev/null 2>&1   
sudo ostree admin pin -u 2 || true

echo -e "Removing update guard..."
sudo rm -f /usr/local/bin/rpm-ostree-guard
sudo rm -f /etc/profile.d/zephyrus-os-update-guard.sh

echo ""
echo -e "ok Deployment unpinned!"
echo ""
echo -e "You can now update normally:"
echo "  rpm-ostree update"
echo "  rpm-ostree upgrade"
echo "  bazzite-update"
echo ""
echo -e "After updating, remember to re-pin if you want:"   
echo "  sudo ~/Desktop/Zephyrus\ OS/bin/setup/pin-os-deployment.sh"
echo ""

rpm-ostree status | head -15   
