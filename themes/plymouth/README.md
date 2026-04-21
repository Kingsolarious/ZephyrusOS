# Zephyrus Crimson Plymouth Theme

Boot splash theme for Zephyrus Crimson OS.

## Files

- `zephyrus-crimson.plymouth` - Theme definition
- `zephyrus.script` - Animation script
- `assets/rog-eye.png` - ROG logo (white, 256x220)

## Animation

1. Black screen
2. ROG eye fades in
3. Subtle scale up
4. Gentle pulse while booting
5. Smooth transition to GDM

## Installation

```bash
sudo cp -r plymouth/ /usr/share/plymouth/themes/zephyrus-crimson
sudo plymouth-set-default-theme zephyrus-crimson -R
sudo dracut -f
```

## Testing

```bash
sudo plymouthd --debug --no-daemon
sudo plymouth --show-splash
sudo plymouth --quit
```
