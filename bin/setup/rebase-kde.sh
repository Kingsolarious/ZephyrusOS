#!/bin/bash
# Rebase to Fedora Kinoite (KDE) with correct remote

echo "Adding Fedora Kinoite remote..."

# Remove old fedora remote if exists
sudo ostree remote delete fedora 2>/dev/null || true

# Add the correct Fedora Kinoite remote
sudo ostree remote add --if-not-exists fedora-kinoite \
    https://kojipkgs.fedoraproject.org/ostree/repo/ \
    --set=gpgkeypath=/etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-41-primary

echo "Fetching refs..."
sudo ostree remote refs fedora-kinoite | grep -i kinoite | head -10

echo ""
echo "Attempting rebase to Fedora Kinoite 41..."
sudo rpm-ostree rebase fedora-kinoite:fedora/41/x86_64/kinoite
