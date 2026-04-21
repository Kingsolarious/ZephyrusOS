#!/bin/bash
# Fix terra-mesa repo issue for KDE rebase

echo "Fixing terra-mesa repository issue..."
echo ""

# Method 1: Remove the repo file entirely
if [ -f /etc/yum.repos.d/terra-mesa.repo ]; then
    echo "Removing terra-mesa repo..."
    sudo rm -f /etc/yum.repos.d/terra-mesa.repo
fi

# Method 2: Reset rpm-ostree to drop layered packages that need terra-mesa
echo "Resetting rpm-ostree to base..."
sudo rpm-ostree reset

echo ""
echo "Repository issue fixed. Now run the rebase:"
echo "  ./rebase-kde-simple.sh"
echo ""
echo "After KDE is installed, you can reinstall packages manually."
