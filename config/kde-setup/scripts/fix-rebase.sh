#!/bin/bash
# Fix the rebase GPG key issue

echo "Fixing terra-mesa GPG key issue..."

# Option 1: Temporarily disable the terra-mesa repo during rebase
echo "Option 1: Disable terra-mesa repo and rebase"
sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/terra-mesa.repo 2>/dev/null || true

# Option 2: Download the missing GPG key
echo "Option 2: Download GPG key"
sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-terra41-mesa \
    https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra41-mesa.pub 2>/dev/null || true

# Try rebase again
echo ""
echo "Retrying rebase..."
cd ~/Desktop/Zephyrus\ OS/kde-setup/scripts
./rebase-to-kde.sh
