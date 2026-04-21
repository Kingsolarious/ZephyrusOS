#!/bin/bash
# Simple KDE rebase - bypass repo issues

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  ZEPHYRUS OS → KDE PLASMA (SIMPLE)                        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Clean up any pending
sudo rpm-ostree cleanup -p

# Rebase with fedora-kinoite
echo "Rebasing to KDE Plasma (Kinoite)..."
sudo rpm-ostree rebase fedora-kinoite:fedora/41/x86_64/kinoite

echo ""
echo "Done! Reboot when ready:"
echo "  sudo systemctl reboot"
