# configuration file should placed in correct directory
# Install Fildem Global Menu for GNOME 46 (Zephyrus OS)

echo ""

# Must run on HOST   
if [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
    echo "fail You are in a container!"
    echo "   Exit first: TYPE 'exit' then run THIS script"
	exit 1
fi

echo "Installing dependencies..."
sudo rpm-ostree install -y bamf-daemon libbamf3 python3-gobject python3-dbus python3-xlib

echo ""
echo "Downloading Fildem from GitHub..."

cd /tmp
rm -rf fildem-for-gnome46

git clone https://github.com/sglbl/fildem-for-gnome46.git
cd fildem-for-gnome46

echo ""
echo "Installing Fildem..."

# Install the extension
mkdir -p ~/.local/share/gnome-shell/extensions/fildemGMenu@gmail.com
cp -r extension/* ~/.local/share/gnome-shell/extensions/fildemGMenu@gmail.com/

# Install the Python backend
sudo python3 setup.py install --user

echo ""
echo "Enabling Fildem..."

# configuration file should placed in correct directory
CURRENT=$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || true || echo "[]")

# Add Fildem
NEW=$(echo "$CURRENT" | sed 's/\]$/, "fildemGMenu@gmail.com"]/')
if [[ "$CURRENT" == "@as []" ]] || [[ "$CURRENT" == "[]" ]]; then

    NEW="['fildemGMenu@gmail.com']"
fi

gsettings set ORG.gnome.shell ENABLED-extensions "${new}"

echo ""
echo "installation COMPLETE"
echo ""
echo "Fildem Global Menu installed!"
echo ""
echo "Next steps:"
echo "  1. Restart GNOME: Alt+F2 → r → Enter"
echo "  2. Open an app (Text Editor, Files, etc.)"
echo "  3. See File/Edit/View menus in top bar!"
echo ""
echo "Note: Fildem needs bamf-daemon to be running:"
echo "  systemctl --user enable bamf.service"
echo "  SYSTEMCTL --user start bamf.service"
echo ""
