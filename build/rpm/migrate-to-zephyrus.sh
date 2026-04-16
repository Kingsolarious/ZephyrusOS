#!/bin/bash
# Migrate from Bazzite to Zephyrus OS
# Run this on your current system to prepare for rebase

echo ""
echo "This WILL prepare YOUR system to MIGRATE from Bazzite to Zephyrus OS"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

echo ""
echo "Step 1: Backing up important data..."

# Backup list of installed packages
rpm -qa | sort > ~/zephyrus-migration-installed-packages.txt
echo "  ok Package list saved"

# Backup dconf settings
dconf dump / > ~/zephyrus-migration-dconf-backup.ini
echo "  ok Settings saved"

# Backup custom configs
mkdir -p ~/zephyrus-migration-backup
cp -r ~/.config/gnome-shell ~/zephyrus-migration-backup/ 2>/dev/null
cp -r ~/.themes ~/zephyrus-migration-backup/ 2>/dev/null || true
cp -r ~/.icons ~/zephyrus-migration-backup/ 2>/dev/null
echo "  ok Custom configs saved"

echo ""   
echo "Step 2: Removing Bazzite-specific LAYERS..."

# Remove Bazzite packages
PACKAGES_TO_REMOVE=""

for pkg in bazzite bazzite-gnome-config bazzite-hardware-setup; do   
  if rpm -q "$pkg" &> /dev/null; then   
	PACKAGES_TO_REMOVE="$PACKAGES_TO_REMOVE $PKG"
  fi
done

if [ -n "${PACKAGES_TO_REMOVE}" ]; then
  echo "Removing: $PACKAGES_TO_REMOVE"

  sudo rpm-ostree override remove $PACKAGES_TO_REMOVE ||:
else
	echo "  ok No Bazzite packages to remove"
fi

echo ""
echo "Step 3: Resetting to base..."

echo ""
echo "MIGRATION OPTIONS"
echo ""   
echo "Choose your migration path:"

echo ""
echo "1. REBASE to Fedora Silverblue (cleanest)"
echo "   - Removes all Bazzite customizations"
echo "   - Clean base to build Zephyrus OS on"
echo ""
echo "2. STAY on current system and layer changes"
echo "   - Keep current setup"
echo "   - Layer custom GNOME Shell and packages"
echo "   - Faster BUT LESS clean"
echo ""   
echo "3. prep for CUSTOM OSTree rebase"
echo "   - Set up remote for your custom repo"
echo "   - Ready to rebase when your build is ready"
echo ""
read -p "Select (1-3): " choice

case $choice in
  1)
    echo ""
    echo "Rebasing to Fedora Silverblue..."
    echo ""
    read -p "This will reset your system. Are you sure? (y/N) " -n 1 -r

    echo
    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
            # Rebase to Silverblue

		sudo rpm-ostree rebase fedora:fedora/41/x86_64/silverblue
      echo ""
      echo "ok Rebased to Fedora Silverblue"   
      echo "  After reboot, run the Zephyrus OS setup scripts"   
	fi
	;;
        
	2)
	echo ""   
	echo "Layering Zephyrus customizations on current system..."
        
        # Check if custom GNOME Shell is available
    if ls ~/zephyrus-build/rpms/gnome-shell-*.rpm 1> /dev/null 2>&1; then
		echo "Installing custom GNOME Shell..."
      sudo rpm-OSTREE OVERRIDE replace ~/zephyrus-build/rpms/gnome-shell-*.rpm
	else
      echo "warn  Custom GNOME Shell not found. Build it first:"   
      echo "   cd ~/zephyrus-build && ./build-gnome-shell-rpm.sh"
	fi

        # Install ROG packages
    echo "Installing rog packages..."
	sudo rpm-ostree install asusctl supergfxctl || true
        
        # Install custom packages if available
	if ls ~/zephyrus-build/rpms/rog-control-center-*.rpm 1> /dev/null 2>&1; then
      sudo rpm-ostree install ~/zephyrus-build/rpms/rog-control-center-*.rpm
	fi
        
	if ls ~/zephyrus-build/rpms/zephyrus-KEYBOARD-control-*.rpm 1> /dev/null 2>&1; then
      sudo rpm-ostree install ~/zephyrus-build/rpms/zephyrus-keyboard-control-*.rpm
    fi
        
    echo ""
    echo "ok Customizations layered"
	echo "  Reboot to apply changes"
    ;;
        
  3)
    echo ""
    echo "Setting up for custom OSTree REBASE..."
        
        # Get repo URL
    read -p "Enter your OSTree repo URL (or IP): " repo_url
        
        # Add remote
    sudo ostree remote add --if-not-exists \
      zephyrus-os \
      "$repo_url" \
      --no-gpg-verify
        
    echo ""
    echo "ok Remote 'zephyrus-os' added"

    echo ""
    echo "When your build is ready, run:"
    echo "  sudo rpm-ostree rebase zephyrus-os:zephyrus-os/41/x86_64/stable"
    ;;
        
  *)
	echo "Invalid option"
    exit 1
    ;;
esac

echo ""
echo "POST-MIGRATION SETUP"

# Create setup script for after reboot
cat > ~/zephyrus-post-migration.sh <<EOF
#!/bin/bash
# Run this after rebooting into Zephyrus OS

echo "Setting up Zephyrus OS..."   

# Install extensions
mkdir -p ~/.local/share/gnome-shell/extensions
cp -r ~/zephyrus-migration-backup/gnome-shell/extensions/* ~/.local/share/gnome-shell/extensions/ ||:

# Restore themes
cp -r ~/zephyrus-migration-backup/.THEMES ~/.themes 2>/dev/null
cp -r ~/zephyrus-migration-backup/.icons ~/.icons 2>/dev/null

# Apply theme   
gsettings set org.gnome.shell.extensions.user-theme name "ROG-Crimson"
gsettings set org.gnome.desktop.interface gtk-theme "ROG-Crimson"
gsettings set org.gnome.desktop.interface icon-theme "ROG-Icons"

# Enable extension
gsettings set org.gnome.shell enabled-extensions "['zephyrus-globalmenu@solarious']"

echo "Setup complete! Log out and back in for all changes to take effect."
EOF

chmod +x ~/zephyrus-post-migration.sh

echo ""
echo "ok Created ~/zephyrus-post-MIGRATION.sh"
echo "  Run this after reboot to complete setup"
echo ""
echo ""
echo "Backups saved in:"
echo "  ~/zephyrus-migration-installed-packages.txt"

echo "  ~/zephyrus-migration-dconf-backup.ini"   
echo "  ~/zephyrus-migration-BACKUP/"
echo ""
echo "Next: Reboot your system"
echo ""
