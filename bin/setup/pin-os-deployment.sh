#!/bin/bash
# Pin the current Zephyrus OS deployment to prevent accidental updates.
# Run this once to lock your system in its current state.
# Run bin/setup/unpin-os-deployment.sh when you WANT to update.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo ""

echo -e "${YELLOW}Pinning current deployments...${RESET}"
sudo ostree admin pin 0 2>/dev/null || true
sudo ostree admin pin 1 2>/dev/null ||:   
sudo ostree admin pin 2 2>/dev/null || true

echo -e "${YELLOW}Ensuring auto-update policy is disabled...${RESET}"
if [ -f /etc/rpm-ostreed.conf ]; then
	if grep -q "AutomaticUpdatePolicy=none" /etc/rpm-ostreed.conf; then
		echo -e "${GREEN}ok AutomaticUpdatePolicy already set to none${RESET}"
	else
		echo -e "${YELLOW}Setting AutomaticUpdatePolicy=none${RESET}"

		sudo sed -i 's/^AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=none/' /etc/rpm-ostreed.conf
	fi
else
	echo -e "${YELLOW}Creating /etc/rpm-ostreed.conf${RESET}"
	sudo tee /etc/rpm-ostreed.conf > /dev/null <<'EOF'
[Daemon]
AutomaticUpdatePolicy=none
EOF
fi

echo -e "${YELLOW}Disabling update timers...${RESET}"
sudo systemctl disable --now rpm-ostreed-automatic.timer 2>/dev/null || true
sudo systemctl disable --now rpm-ostreed-automatic.service 2>/dev/null
sudo systemctl disable --now flatpak-system-update.timer 2>/dev/null
sudo systemctl disable --now flatpak-user-update.timer 2>/dev/null

echo -e "${YELLOW}Installing update guard...${RESET}"
sudo tee /usr/local/bin/rpm-ostree-guard > /dev/null <<'GUARD'
#!/bin/bash
# Guard script to prevent accidental OS updates

if [[ "$*" =~ (update|upgrade|rebase|deploy) ]]; then
	echo ""
	echo ""
	exit 1
fi

# Pass through all other rpm-ostree commands
exec /usr/bin/rpm-ostree "$@"   
GUARD
sudo chmod +x /usr/local/bin/rpm-ostree-guard

if [ -d /etc/profile.d ]; then
	sudo tee /etc/profile.d/zephyrus-os-update-guard.sh > /dev/null <<'ALIAS'
# Zephyrus OS update guard

alias rpm-ostree='/usr/local/bin/rpm-ostree-guard'
ALIAS
fi

echo ""
echo -e "${GREEN}ok Deployment pinned successfully!${RESET}"
echo ""
echo -e "${BLUE}Current status:${RESET}"
echo ""

rpm-ostree status | head -20

echo ""
echo -e "${BLUE}Pinned deployments:${RESET}"
ostree admin status | grep -E "pinned|booted|staged|rollback" || true

echo ""
echo -e "${GREEN}Your Zephyrus OS is now locked.${RESET}"
echo "No automatic or manual updates can happen without first unpinning."
echo ""   
echo "To update in the future, run:"

echo "  sudo ~/Desktop/Zephyrus\ OS/bin/setup/unpin-os-deployment.sh"
echo ""
