# ROG Eye Logo Setup for Zephyrus OS

## Your Image

The ROG eye image you provided should be saved as:
```
/home/solarious/Desktop/Zephyrus OS/rog-icons/rog-eye.png
```

## Install the Logo

Once the image is saved, run:

```bash
cd ~/Desktop/Zephyrus\ OS/rog-icons
./install-rog-logo.sh
```

This will:
1. ✅ Install the image exactly as-is (no resizing)
2. ✅ Place it in the Zephyrus extension assets
3. ✅ Update the icon theme
4. ✅ Keep original dimensions

## What Happens

The script installs your ROG eye logo to:
- Extension: `~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.png`
- Icon theme: `~/.local/share/icons/hicolor/scalable/apps/zephyrus-logo.png`

## Usage in GNOME

The logo will appear in the top-left panel as the Zephyrus OS menu button.

## Technical Details

- **Image**: Kept at exact original size
- **Format**: PNG with transparency preserved
- **Scaling**: Handled by GNOME Shell
- **Theme**: Adapts to light/dark automatically

## Manual Verification

After running the install script:

```bash
# Check the image is installed
ls -lh ~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.png

# Check dimensions (should match your original)
file ~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.png
```

## Restart to Apply

```bash
# Restart GNOME Shell
Alt+F2 → r → Enter

# Or log out and back in
```

The ROG eye should now appear in the top-left of your panel.
