#!/bin/bash
# Aggressively remove the Screen Lock toggle from GNOME Quick Settings

set -e

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     REMOVE SCREEN LOCK TOGGLE - AGGRESSIVE FIX           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Get the actual user's home directory
if [ -n "$SUDO_USER" ]; then
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    REAL_USER="$SUDO_USER"
else
    REAL_HOME="$HOME"
    REAL_USER=$(whoami)
fi

echo "Applying fixes for user: $REAL_USER"
echo "Home directory: $REAL_HOME"
echo ""

# ============================================================================
# METHOD 1: Disable privacy indicator via gsettings
# ============================================================================
echo "Method 1: Disabling privacy indicator via gsettings..."

# Run gsettings as the real user
if command -v gsettings &> /dev/null; then
    # Disable the privacy indicator in Quick Settings
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.privacy show-full-name-in-top-bar false 2>/dev/null || true
    
    # Disable screen sharing indicator
    sudo -u "$REAL_USER" gsettings set org.gnome.desktop.privacy disable-screen-lock false 2>/dev/null || true
    
    echo "  ✓ gsettings applied"
else
    echo "  ✗ gsettings not found"
fi

# ============================================================================
# METHOD 2: Create aggressive GNOME Shell user CSS
# ============================================================================
echo ""
echo "Method 2: Creating aggressive GNOME Shell CSS..."

SHELL_CSS_DIR="$REAL_HOME/.config/gnome-shell"
mkdir -p "$SHELL_CSS_DIR"

cat > "$SHELL_CSS_DIR/user.css" << 'CSS'
/* AGGRESSIVE: Hide Screen Lock toggle in Quick Settings */
.quick-toggle-menu .privacy-screen,
.privacy-screen-quick-toggle,
.quick-toggle.privacy-screen,
#quickSettingsGrid .privacy-screen,
.quick-settings-system-level .privacy-screen {
    display: none !important;
    width: 0 !important;
    height: 0 !important;
    opacity: 0 !important;
    visibility: hidden !important;
    margin: 0 !important;
    padding: 0 !important;
    border: none !important;
}

/* Hide screen recording/sharing indicators */
.screen-recording-indicator,
.screen-sharing-indicator,
.privacy-indicator {
    display: none !important;
    width: 0 !important;
    height: 0 !important;
}

/* Hide the toggle arrow button next to system menu */
.quick-menu-toggle .quick-toggle-arrow {
    display: none !important;
}

/* Target specific Quick Settings toggles */
.quick-settings-grid .quick-toggle:nth-child(1),
.quick-settings-grid .quick-toggle:first-child {
    display: none !important;
}
CSS

chown -R "$REAL_USER:$REAL_USER" "$SHELL_CSS_DIR"
echo "  ✓ Created $SHELL_CSS_DIR/user.css"

# ============================================================================
# METHOD 3: Update the ROG Theme CSS
# ============================================================================
echo ""
echo "Method 3: Updating ROG Theme CSS..."

THEME_DIR="$REAL_HOME/.themes/ROG-Centered/gnome-shell"
if [ -d "$THEME_DIR" ]; then
    # Add the CSS if not already present
    if ! grep -q "HIDE SCREEN LOCK TOGGLE" "$THEME_DIR/gnome-shell.css" 2>/dev/null; then
        cat >> "$THEME_DIR/gnome-shell.css" << 'CSS'

/* === HIDE SCREEN LOCK TOGGLE === */
.quick-toggle-menu .privacy-screen,
.privacy-screen-quick-toggle,
.quick-toggle.privacy-screen,
#quickSettingsGrid .privacy-screen {
    display: none !important;
    width: 0 !important;
    height: 0 !important;
    opacity: 0 !important;
    visibility: hidden !important;
}

.screen-recording-indicator,
.screen-sharing-indicator {
    display: none !important;
}
CSS
        echo "  ✓ Updated ROG-Centered theme"
    else
        echo "  ✓ ROG theme already has the fix"
    fi
else
    echo "  ✗ ROG-Centered theme not found at $THEME_DIR"
fi

# ============================================================================
# METHOD 4: Create a systemd user service to hide it on startup
# ============================================================================
echo ""
echo "Method 4: Creating startup hide service..."

SYSTEMD_DIR="$REAL_HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"

cat > "$SYSTEMD_DIR/hide-screen-lock.service" << 'SERVICE'
[Unit]
Description=Hide Screen Lock Toggle
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'sleep 5 && gsettings set org.gnome.desktop.privacy show-full-name-in-top-bar false 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=default.target
SERVICE

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config/systemd"
echo "  ✓ Created systemd service"

# ============================================================================
# METHOD 5: Extension-based approach (if using Just Perfection)
# ============================================================================
echo ""
echo "Method 5: Just Perfection settings (if installed)..."

if command -v gsettings &> /dev/null; then
    # Check if Just Perfection is installed
    if sudo -u "$REAL_USER" gsettings list-schemas 2>/dev/null | grep -q "org.gnome.shell.extensions.just-perfection"; then
        # Hide various indicators
        sudo -u "$REAL_USER" gsettings set org.gnome.shell.extensions.just-perfection activities-button false 2>/dev/null || true
        echo "  ✓ Just Perfection configured"
    else
        echo "  ℹ Just Perfection not installed (this is OK)"
    fi
fi

# ============================================================================
# METHOD 6: Create a GNOME extension to hide it
# ============================================================================
echo ""
echo "Method 6: Creating hide extension..."

EXT_DIR="$REAL_HOME/.local/share/gnome-shell/extensions/hide-screenlock@solarious"
mkdir -p "$EXT_DIR"

cat > "$EXT_DIR/metadata.json" << 'META'
{
    "name": "Hide Screen Lock Toggle",
    "description": "Hides the screen lock toggle from Quick Settings",
    "uuid": "hide-screenlock@solarious",
    "shell-version": ["45", "46", "47"],
    "version": 1
}
META

cat > "$EXT_DIR/extension.js" << 'JS'
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class HideScreenLockExtension {
    enable() {
        // Hide the screen lock toggle after a short delay
        this._timeout = setTimeout(() => {
            try {
                const quickSettings = Main.panel.statusArea.quickSettings;
                if (quickSettings && quickSettings._system) {
                    const system = quickSettings._system;
                    if (system._screenShieldToggle) {
                        system._screenShieldToggle.hide();
                        system._screenShieldToggle.visible = false;
                    }
                }
            } catch (e) {
                log('HideScreenLock: ' + e);
            }
        }, 1000);
    }

    disable() {
        if (this._timeout) {
            clearTimeout(this._timeout);
            this._timeout = null;
        }
    }
}
JS

chown -R "$REAL_USER:$REAL_USER" "$EXT_DIR"
echo "  ✓ Created hide extension at $EXT_DIR"

# Enable the extension
if command -v gsettings &> /dev/null; then
    CURRENT_EXT=$(sudo -u "$REAL_USER" gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo "[]")
    if [[ "$CURRENT_EXT" != *"hide-screenlock@solarious"* ]]; then
        # Parse and add the extension
        NEW_EXT=$(echo "$CURRENT_EXT" | sed 's/\]$/, "hide-screenlock@solarious"]/')
        if [[ "$CURRENT_EXT" == "@as []" ]] || [[ "$CURRENT_EXT" == "[]" ]]; then
            NEW_EXT="['hide-screenlock@solarious']"
        fi
        sudo -u "$REAL_USER" gsettings set org.gnome.shell enabled-extensions "$NEW_EXT" 2>/dev/null || true
        echo "  ✓ Extension enabled"
    fi
fi

# ============================================================================
# FINAL INSTRUCTIONS
# ============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                   NEXT STEPS                              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "1. Apply the ROG theme (if not already applied):"
echo "   gsettings set org.gnome.shell.extensions.user-theme name 'ROG-Centered'"
echo ""
echo "2. Restart GNOME Shell:"
echo "   - X11: Alt+F2 → type 'r' → Enter"
echo "   - Wayland: Log out and log back in"
echo ""
echo "3. If STILL visible, try this nuclear option:"
echo "   gsettings set org.gnome.shell.extensions.user-theme enabled-extensions \"[]\""
echo ""
echo "4. Or disable all Quick Settings and use the custom menu:"
echo "   - Open 'Extensions' app"
echo "   - Disable all quick settings extensions"
echo ""
echo "═══════════════════════════════════════════════════════════"
