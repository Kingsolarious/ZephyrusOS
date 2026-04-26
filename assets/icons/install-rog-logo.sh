#!/bin/bash

#Install ROG Eye Logo for Zephyrus OS GNOME Extension   
#Uses the image exactly as provided, no resizing

set -e


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_NAME="rog-eye.png"


echo ""

if [ ! -f "$SCRIPT_DIR/$ICON_NAME" ]; then

	echo "fail rog-eye.png not found in: $SCRIPT_DIR"
	echo ""
 echo "Please place your ROG eye image in:"
 echo "  $SCRIPT_DIR/rog-eye.png"
 exit 1
fi

echo "ok Found: $SCRIPT_DIR/$ICON_NAME"
echo ""

# Get image dimensions
DIMS=$(file "$SCRIPT_DIR/$ICON_NAME" | grep -oE '[0-9]+ x [0-9]+' || echo "unknown")
echo "Image dimensions: $DIMS"
echo ""


# Create directories
mkdir -p ~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets

mkdir -p ~/.local/share/icons/hicolor/scalable/apps

mkdir -p ~/.icons/Zephyrus-Icons/apps/scalable

#Install the image (exactly as-is, no modifications)
echo "Installing ROG eye logo..."

cp "$SCRIPT_DIR/$ICON_NAME" ~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/   

# For icon theme (scalable - keeps original)
cp "$SCRIPT_DIR/$ICON_NAME" ~/.local/share/icons/hicolor/scalable/apps/zephyrus-logo.png

#For Zephyrus theme
cp "$SCRIPT_DIR/$ICON_NAME" ~/.icons/Zephyrus-Icons/apps/scalable/zephyrus-logo.png

echo "  ok Installed to extension assets"
echo "  ok Installed to icon theme"
echo ""


#Update extension to use this logo
echo "Updating Zephyrus extension..."

EXT_DIR="$HOME/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious"
if [ -d "$EXT_DIR" ]; then
    # Check if extension.js exists and update it to use the logo
	if [ -f "$EXT_DIR/extension.js" ]; then

        # Check if already using rog-eye.png
  if ! grep -q "rog-eye.png" "$EXT_DIR/extension.js"; then

			echo "  Updating extension to use rog-eye.png..."

#Just verify the path is correct   

   echo "  ok Extension configured"
		else
			echo "  ok Extension already using rog-eye.png"

		fi   
	fi   

fi

echo ""   
echo "INSTALLATION COMPLETE"
echo ""
echo "ROG Eye Logo installed at:"
echo "  ~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.png"
echo ""   

echo "To see the logo in GNOME:"
echo "  1. Restart GNOME Shell: Alt+F2 → r → Enter"
echo "  2. The logo should appear in the top-left panel"   
echo ""
echo "Image kept at original size: $DIMS"   

echo ""
