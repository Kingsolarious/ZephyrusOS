#!/bin/bash
# Fix VS Code dock icon - restores the working configuration

echo "Fixing VS Code dock icon..."

# Create the correct desktop file
cat > ~/.local/share/applications/code.desktop << 'EOF'
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=flatpak-spawn --host flatpak run com.visualstudio.code %F
Icon=com.visualstudio.code
Type=Application
StartupNotify=true
StartupWMClass=code
Categories=TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=flatpak-spawn --host flatpak run com.visualstudio.code --new-window %F
EOF

# Make it read-only
chmod 444 ~/.local/share/applications/code.desktop

# Ensure dock has the desktop file (remove any duplicates first)
sed -i 's|applications:code.desktop||g' ~/.config/plasma-org.kde.plasma.desktop-appletsrc
sed -i 's|,,|,|g' ~/.config/plasma-org.kde.plasma.desktop-appletsrc

# Add to dock if not present
if ! grep -q "applications:code.desktop" ~/.config/plasma-org.kde.plasma.desktop-appletsrc; then
    sed -i 's|launchers=|launchers=applications:code.desktop,|g' ~/.config/plasma-org.kde.plasma.desktop-appletsrc
fi

# Update desktop database
update-desktop-database ~/.local/share/applications/ 2>/dev/null

# Restart Plasma
killall plasmashell 2>/dev/null && sleep 2 && plasmashell &

echo "✓ VS Code dock icon fixed!"
