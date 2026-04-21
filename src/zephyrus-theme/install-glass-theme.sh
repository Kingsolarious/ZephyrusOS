#!/bin/bash
# Install Zephyrus Glass Theme for windows

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║  Install Zephyrus Glass Theme                             ║"
echo "║  Translucent windows with ROG aesthetic                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.themes/Zephyrus-Glass"

echo "Installing glass theme..."

# Create theme directory
mkdir -p "$INSTALL_DIR/gtk-4.0"

# Copy theme file
cp "$THEME_DIR/gtk-4.0/gtk.css" "$INSTALL_DIR/gtk-4.0/"

# Create index.theme
cat > "$INSTALL_DIR/index.theme" << 'EOF'
[Desktop Entry]
Name=Zephyrus-Glass
Type=X-GNOME-Metatheme
Comment=Glass/translucent window theme for Zephyrus OS
Encoding=UTF-8

[X-GNOME-Metatheme]
Name=Zephyrus-Glass
GtkTheme=Zephyrus-Glass
IconTheme=Zephyrus-Icons
EOF

echo "✓ Theme installed to: $INSTALL_DIR"
echo ""
echo "To apply theme, run:"
echo "  gsettings set org.gnome.desktop.interface gtk-theme 'Zephyrus-Glass'"
echo ""
echo "Note: For full glass effect, you may need:"
echo "  - A compositor (Mutter/Compton)"
echo "  - Blur-my-shell extension for background blur"
echo ""
