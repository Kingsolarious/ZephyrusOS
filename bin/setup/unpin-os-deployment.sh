#!/bin/bash
# Unpin the Zephyrus OS deployment so updates can be applied.
# Run this when you WANT to update your system.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Zephyrus OS — Unpin Deployment                             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Unpin all deployments
echo -e "${YELLOW}Unpinning deployments...${NC}"
sudo ostree admin pin -u 0 2>/dev/null || true
sudo ostree admin pin -u 1 2>/dev/null || true
sudo ostree admin pin -u 2 2>/dev/null || true

# 2. Remove update guard
echo -e "${YELLOW}Removing update guard...${NC}"
sudo rm -f /usr/local/bin/rpm-ostree-guard
sudo rm -f /etc/profile.d/zephyrus-os-update-guard.sh

# 3. Show status
echo ""
echo -e "${GREEN}✓ Deployment unpinned!${NC}"
echo ""
echo -e "${YELLOW}You can now update normally:${NC}"
echo "  rpm-ostree update"
echo "  rpm-ostree upgrade"
echo "  bazzite-update"
echo ""
echo -e "${YELLOW}After updating, remember to re-pin if you want:${NC}"
echo "  sudo ~/Desktop/Zephyrus\ OS/bin/setup/pin-os-deployment.sh"
echo ""

rpm-ostree status | head -15
