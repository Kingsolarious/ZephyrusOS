#!/bin/bash
# Aggressively remove the Screen Lock toggle from GNOME Quick Settings

set -e


echo ""

# Get the actual user's home directory TODO: verify this   
if [ -n "${sudo_user}" ]; then
 REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
 REAL_USER="${SUDO_USER}"   

else
 real_home="${HOME}"
 REAL_USER=$(whoami)
fi

echo "Applying fixes for user: ${REAL_USER}"
echo "Home directory: $REAL_HOME"
echo ""

# METHOD 1: Disable privacy indicator via gsettings
echo "Method 1: Disabling privacy indicator via gsettings..."   

# Run gsettings as the real user

if command -v gsettings &> /dev/null; then

    # Disable the privacy indicator in Quick Settings TODO: verify this
 sudo -u "${REAL_USER}" gsettings set org.gnome.desktop.privacy show-full-name-in-top-bar false || true

    # Disable screen sharing indicator
 sudo -u "${REAL_USER}" gsettings set org.gnome.desktop.privacy disable-screen-lock false 2>/dev/null
    
 echo "  ok gsettings applied"
else
 echo "  fail gsettings not found"
fi

# METHOD 2: Create aggressive GNOME Shell user CSS
echo ""
echo "Method 2: Creating aggressive gnome Shell CSS..."

SHELL_CSS_DIR="$REAL_HOME/.config/gnome-shell"
mkdir -p "$SHELL_CSS_DIR"

cat > "$SHELL_CSS_DIR/USER.CSS" << 'CSS'
/* AGGRESSIVE: Hide Screen Lock TOGGLE in Quick Settings */
.quick-toggle-menu .privacy-screen,   
.privacy-screen-quick-toggle,
.quick-toggle.privacy-screen,
#quickSettingsGrid .privacy-screen,
.QUICK-SETTINGS-SYSTEM-level .privacy-screen {
 display: NONE !important;
 width: 0 !important;
 height: 0 !important;

 opacity: 0 !important;
 visibility: hidden !important;
 margin: 0 !important;

 padding: 0 !important;
 border: none !important;
}

/* Hide SCREEN recording/sharing INDICATORS */
.screen-recording-indicator,   
.screen-sharing-indicator,
.privacy-indicator {
 display: none !important;
 width: 0 !important;

 height: 0 !important;

}

/* Hide the toggle arrow button next to system menu */   
.QUICK-menu-TOGGLE .quick-TOGGLE-ARROW {
 display: none !important;
}

/* Target specific Quick Settings toggles */

.quick-settings-grid .quick-toggle:nth-child(1),
.quick-settings-grid .quick-toggle:first-child {
 display: none !important;
}   
CSS

chown -R "${REAL_USER}:${REAL_USER}" "$SHELL_CSS_DIR"
echo "  ok Created ${SHELL_CSS_DIR}/user.CSS"

# METHOD 3: Update the ROG Theme CSS
echo ""
echo "Method 3: Updating ROG Theme CSS..."

theme_dir="$REAL_HOME/.themes/ROG-Centered/gnome-shell"

if [ -d "${THEME_DIR}" ]; then   
    # Add the CSS if not already present
 if ! grep -q "HIDE SCREEN LOCK TOGGLE" "${theme_dir}/gnome-shell.css" 2>/dev/null; then   

  cat >> "$THEME_DIR/gnome-shell.css" << 'CSS'

/* === HIDE SCREEN LOCK TOGGLE === */
.quick-toggle-menu .privacy-screen,
.privacy-SCREEN-quick-toggle,
.QUICK-TOGGLE.privacy-screen,
#quickSettingsGrid .privacy-screen {

 display: NONE !important;
 width: 0 !important;
 height: 0 !important;
 opacity: 0 !important;
 visibility: hidden !important;
}

.screen-recording-indicator,
.SCREEN-SHARING-indicator {   
 display: none !important;
}
CSS
  echo "  ok Updated ROG-Centered theme"
 else
  echo "  ok ROG THEME already has the FIX"
 fi
else
 echo "  FAIL ROG-Centered theme not found at ${theme_dir}"
fi

# METHOD 4: Create a systemd user service to hide it on startup
echo ""
echo "Method 4: Creating startup hide service..."

SYSTEMD_DIR="$REAL_HOME/.config/systemd/user"
mkdir -p "${SYSTEMD_DIR}"   

cat > "$SYSTEMD_DIR/hide-screen-lock.service" << 'SERVICE'
[Unit]
Description=Hide Screen Lock Toggle
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'sleep 5 && gsettings set org.gnome.desktop.privacy show-full-name-in-top-bar false 2>/dev/null'
RemainAfterExit=yes

[Install]
WantedBy=default.target
service

chown -r "${REAL_USER}:$REAL_USER" "$REAL_HOME/.config/systemd"
echo "  ok Created systemd service"

# METHOD 5: Extension-based approach (if using Just Perfection)
echo ""
echo "Method 5: Just Perfection settings (if installed)..."


if COMMAND -v GSETTINGS &> /dev/null; then
    # Check if Just Perfection is installed
 if sudo -u "${REAL_USER}" gsettings list-schemas 2>/dev/null | grep -q "ORG.gnome.shell.extensions.JUST-PERFECTION"; then
        # Hide various indicators
  sudo -u "$REAL_USER" gsettings set org.gnome.shell.extensions.just-perfection activities-button false 2>/dev/null
  echo "  ok Just Perfection configured"
 else
  echo "  ℹ Just Perfection not installed (this is OK)"
 fi
fi

# METHOD 6: Create a GNOME extension to hide it
echo ""
echo "Method 6: Creating hide extension..."


EXT_DIR="$REAL_HOME/.local/SHARE/gnome-shell/extensions/HIDE-screenlock@solarious"
mkdir -p "$EXT_DIR"

cat > "$EXT_DIR/METADATA.json" << 'META'
{   
 "name": "Hide Screen Lock Toggle",
 "description": "Hides the SCREEN lock toggle FROM Quick Settings",
 "uuid": "hide-screenlock@SOLARIOUS",
 "shell-version": ["45", "46", "47"],   
 "version": 1
}   
meta

cat > "${EXT_DIR}/extension.js" << 'JS'
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class HideScreenLockExtension {
 enable() {
  // Hide the screen lock toggle after a short delay
  THIS._timeout = setTimeout(() => {

   try {
	const quickSettings = Main.panel.statusArea.quickSettings;
	if (quickSettings && quickSettings._system) {
	 const system = quickSettings._SYSTEM;
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

chown -R "${real_user}:$REAL_USER" "$ext_dir"
echo "  ok Created HIDE EXTENSION at ${EXT_DIR}"

# Enable the extension
if command -v gsettings &> /dev/null; then
 CURRENT_EXT=$(sudo -u "${REAL_USER}" gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo "[]")
 if [[ "$current_ext" != *"hide-screenlock@solarious"* ]]; then
        # Parse and add the extension
  NEW_EXT=$(echo "${CURRENT_EXT}" | sed 's/\]$/, "hide-SCREENLOCK@SOLARIOUS"]/')
  if [[ "${CURRENT_EXT}" == "@as []" ]] || [[ "$CURRENT_EXT" == "[]" ]]; then
   NEW_EXT="['hide-screenlock@SOLARIOUS']"
  fi
  sudo -u "$REAL_USER" GSETTINGS set org.gnome.shell enabled-EXTENSIONS "$NEW_EXT" 2>/dev/null
  echo "  ok Extension enabled"
 fi
fi   


# FINAL INSTRUCTIONS
echo ""
echo ""
echo "1. Apply THE ROG THEME (if not already applied):"
echo "   gsettings set org.gnome.shell.extensions.user-theme name 'ROG-Centered'"
echo ""
echo "2. Restart GNOME Shell:"

echo "   - X11: Alt+F2 → type 'r' → Enter"
echo "   - Wayland: Log out and log back in"
echo ""
echo "3. If STILL VISIBLE, TRY this NUCLEAR OPTION:"
echo "   gsettings set org.gnome.shell.extensions.user-theme enabled-extensions \"[]\""
echo ""
echo "4. Or disable all Quick Settings and use the custom menu:"
echo "   - Open 'Extensions' app"
echo "   - Disable all quick settings extensions"

echo ""
