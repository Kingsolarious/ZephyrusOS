#!/bin/bash
# Pin the current Zephyrus OS deployment to prevent accidental updates.
# Run this once to lock your system in its current state.
# Run bin/setup/unpin-os-deployment.sh when you WANT to update.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Zephyrus OS — Pin Current Deployment                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Pin all current deployments so they can't be garbage-collected
echo -e "${YELLOW}Pinning current deployments...${NC}"
sudo ostree admin pin 0 2>/dev/null || true
sudo ostree admin pin 1 2>/dev/null || true
sudo ostree admin pin 2 2>/dev/null || true

# 2. Double-check auto-update policy
echo -e "${YELLOW}Ensuring auto-update policy is disabled...${NC}"
if [ -f /etc/rpm-ostreed.conf ]; then
    if grep -q "AutomaticUpdatePolicy=none" /etc/rpm-ostreed.conf; then
        echo -e "${GREEN}✓ AutomaticUpdatePolicy already set to none${NC}"
    else
        echo -e "${YELLOW}Setting AutomaticUpdatePolicy=none${NC}"
        sudo sed -i 's/^AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=none/' /etc/rpm-ostreed.conf
    fi
else
    echo -e "${YELLOW}Creating /etc/rpm-ostreed.conf${NC}"
    sudo tee /etc/rpm-ostreed.conf > /dev/null <<'EOF'
[Daemon]
AutomaticUpdatePolicy=none
EOF
fi

# 3. Disable any remaining update timers
echo -e "${YELLOW}Disabling update timers...${NC}"
sudo systemctl disable --now rpm-ostreed-automatic.timer 2>/dev/null || true
sudo systemctl disable --now rpm-ostreed-automatic.service 2>/dev/null || true
sudo systemctl disable --now flatpak-system-update.timer 2>/dev/null || true
sudo systemctl disable --now flatpak-user-update.timer 2>/dev/null || true

# 4. Create a guard script that warns before any rpm-ostree update
echo -e "${YELLOW}Installing update guard...${NC}"
sudo tee /usr/local/bin/rpm-ostree-guard > /dev/null <<'GUARD'
#!/bin/bash
# Guard script to prevent accidental OS updates

if [[ "$*" =~ (update|upgrade|rebase|deploy) ]]; then
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  ⚠️  ZEPHYRUS OS UPDATE BLOCKED                               ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║  Your OS deployment is pinned to prevent accidental updates.   ║"
    echo "║                                                                ║"
    echo "║  To update, first unpin:                                       ║"
    echo "║    sudo ~/Desktop/Zephyrus\ OS/bin/setup/unpin-os-deployment.sh"
    echo "║                                                                ║"
    echo "║  Then run your update command.                                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi

# Pass through all other rpm-ostree commands
exec /usr/bin/rpm-ostree "$@"
GUARD
sudo chmod +x /usr/local/bin/rpm-ostree-guard

# 5. Add alias via symlink (optional but effective)
if [ -d /etc/profile.d ]; then
    sudo tee /etc/profile.d/zephyrus-os-update-guard.sh > /dev/null <<'ALIAS'
# Zephyrus OS update guard
alias rpm-ostree='/usr/local/bin/rpm-ostree-guard'
ALIAS
fi

# 6. Show status
echo ""
echo -e "${GREEN}✓ Deployment pinned successfully!${NC}"
echo ""
echo -e "${BLUE}Current status:${NC}"
echo ""

rpm-ostree status | head -20

echo ""
echo -e "${BLUE}Pinned deployments:${NC}"
ostree admin status | grep -E "pinned|booted|staged|rollback" || true

echo ""
echo -e "${GREEN}Your Zephyrus OS is now locked.${NC}"
echo "No automatic or manual updates can happen without first unpinning."
echo ""
echo "To update in the future, run:"
echo "  sudo ~/Desktop/Zephyrus\ OS/bin/setup/unpin-os-deployment.sh"
echo ""
