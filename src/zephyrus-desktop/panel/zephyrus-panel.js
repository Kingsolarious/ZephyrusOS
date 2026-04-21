// Zephyrus Panel - Complete Top Bar Replacement
// Replaces GNOME's default panel with macOS-style functionality

import St from 'gi://St';
import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

// Panel Layout:
// [ROG Logo] [App Menu] [Global Menu] [Spacer] [System Tray] [Clock] [Status Icons]

export const ZephyrusPanel = GObject.registerClass(
    class ZephyrusPanel extends St.BoxLayout {
        _init() {
            super._init({
                name: 'zephyrusPanel',
                style_class: 'zephyrus-panel',
                reactive: true,
                track_hover: true,
                x_expand: true,
                y_expand: false,
                vertical: false
            });
            
            this._buildLeftSection();
            this._buildCenterSection();
            this._buildRightSection();
        }
        
        _buildLeftSection() {
            // Left container: ROG Logo + App Menu + Global Menu
            this._leftBox = new St.BoxLayout({
                style_class: 'zephyrus-panel-left',
                x_align: Clutter.ActorAlign.START,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            // 1. ROG Logo Button
            this._rogButton = this._createROGButton();
            this._leftBox.add_child(this._rogButton);
            
            // 2. Application Name (like "Finder" in macOS)
            this._appMenu = this._createAppMenu();
            this._leftBox.add_child(this._appMenu);
            
            // 3. Global Menu (File, Edit, View...)
            this._globalMenu = this._createGlobalMenu();
            this._leftBox.add_child(this._globalMenu);
            
            this.add_child(this._leftBox);
        }
        
        _buildCenterSection() {
            // Center: Empty or window title (macOS style)
            this._centerBox = new St.BoxLayout({
                style_class: 'zephyrus-panel-center',
                x_align: Clutter.ActorAlign.CENTER,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            // Window title (optional, shows current window name)
            this._windowTitle = new St.Label({
                style_class: 'zephyrus-window-title',
                text: ''
            });
            this._centerBox.add_child(this._windowTitle);
            
            this.add_child(this._centerBox);
        }
        
        _buildRightSection() {
            // Right: System Tray + Clock + Status
            this._rightBox = new St.BoxLayout({
                style_class: 'zephyrus-panel-right',
                x_align: Clutter.ActorAlign.END,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            // System indicators (WiFi, Battery, etc)
            this._systemTray = this._createSystemTray();
            this._rightBox.add_child(this._systemTray);
            
            // Clock
            this._clock = this._createClock();
            this._rightBox.add_child(this._clock);
            
            // ROG Status (fan speed, temp, performance mode)
            this._rogStatus = this._createROGStatus();
            this._rightBox.add_child(this._rogStatus);
            
            this.add_child(this._rightBox);
        }
        
        _createROGButton() {
            const button = new St.Button({
                style_class: 'zephyrus-rog-button',
                reactive: true,
                can_focus: true
            });
            
            // Load SVG logo
            const iconPath = GLib.build_filenamev([
                GLib.get_home_dir(),
                '.local/share/zephyrus-desktop/assets/rog-logo.svg'
            ]);
            
            let icon;
            if (GLib.file_test(iconPath, GLib.FileTest.EXISTS)) {
                const file = Gio.File.new_for_path(iconPath);
                icon = new St.Icon({
                    gicon: Gio.FileIcon.new(file),
                    style_class: 'zephyrus-rog-icon'
                });
            } else {
                icon = new St.Label({ text: '⚡', style_class: 'zephyrus-rog-fallback' });
            }
            
            button.set_child(icon);
            button.set_width(60);
            button.set_height(32);
            
            // ROG Menu
            this._rogMenu = new PopupMenu.PopupMenu(button, 0.0, St.Side.TOP);
            this._buildROGMenu();
            Main.uiGroup.add_child(this._rogMenu.actor);
            this._rogMenu.actor.hide();
            
            button.connect('clicked', () => this._rogMenu.toggle());
            
            return button;
        }
        
        _buildROGMenu() {
            // System menu items
            const items = [
                { label: 'About This Zephyrus', action: () => this._showAbout() },
                { label: 'System Settings...', action: () => this._openSettings() },
                null, // separator
                { label: 'ROG Control Center', action: () => this._openROGCenter() },
                { label: 'Performance Mode', action: () => this._togglePerformance() },
                null,
                { label: 'Sleep', action: () => this._sleep() },
                { label: 'Restart...', action: () => this._restart() },
                { label: 'Shut Down...', action: () => this._shutdown() }
            ];
            
            for (const item of items) {
                if (item === null) {
                    this._rogMenu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
                } else {
                    const menuItem = new PopupMenu.PopupMenuItem(item.label);
                    menuItem.connect('activate', item.action);
                    this._rogMenu.addMenuItem(menuItem);
                }
            }
        }
        
        _createAppMenu() {
            // Shows current application name (like "Finder" on macOS)
            const button = new St.Button({
                style_class: 'zephyrus-app-menu',
                reactive: true
            });
            
            this._appLabel = new St.Label({
                text: 'Zephyrus',
                style_class: 'zephyrus-app-label'
            });
            button.set_child(this._appLabel);
            
            // App-specific menu
            this._appSpecificMenu = new PopupMenu.PopupMenu(button, 0.0, St.Side.TOP);
            Main.uiGroup.add_child(this._appSpecificMenu.actor);
            this._appSpecificMenu.actor.hide();
            
            button.connect('clicked', () => this._appSpecificMenu.toggle());
            
            return button;
        }
        
        _createGlobalMenu() {
            // File, Edit, View, etc. - dynamically populated
            const container = new St.BoxLayout({
                style_class: 'zephyrus-global-menu-container',
                x_align: Clutter.ActorAlign.START
            });
            
            // Placeholder for global menu items
            this._globalMenuItems = [];
            const menus = ['File', 'Edit', 'View', 'Go', 'Window', 'Help'];
            
            for (const menuName of menus) {
                const button = new St.Button({
                    label: menuName,
                    style_class: 'zephyrus-global-menu-item',
                    reactive: true
                });
                
                const popup = new PopupMenu.PopupMenu(button, 0.0, St.Side.TOP);
                this._buildMenuContents(popup, menuName);
                Main.uiGroup.add_child(popup.actor);
                popup.actor.hide();
                
                button.connect('clicked', () => popup.toggle());
                
                container.add_child(button);
                this._globalMenuItems.push({ name: menuName, button, popup });
            }
            
            return container;
        }
        
        _buildMenuContents(popup, menuName) {
            // Placeholder menu items - will be populated by active app
            const items = this._getDefaultMenuItems(menuName);
            
            for (const item of items) {
                if (item === null) {
                    popup.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
                } else {
                    const menuItem = new PopupMenu.PopupMenuItem(item.label);
                    menuItem.connect('activate', () => {
                        this._activateMenuItem(menuName, item.action);
                    });
                    popup.addMenuItem(menuItem);
                }
            }
        }
        
        _getDefaultMenuItems(menuName) {
            const menus = {
                'File': [
                    { label: 'New Window', action: 'new-window' },
                    { label: 'New Tab', action: 'new-tab' },
                    null,
                    { label: 'Open...', action: 'open' },
                    { label: 'Open Recent', action: 'open-recent' },
                    null,
                    { label: 'Save', action: 'save' },
                    { label: 'Save As...', action: 'save-as' },
                    null,
                    { label: 'Close', action: 'close' },
                    { label: 'Quit', action: 'quit' }
                ],
                'Edit': [
                    { label: 'Undo', action: 'undo' },
                    { label: 'Redo', action: 'redo' },
                    null,
                    { label: 'Cut', action: 'cut' },
                    { label: 'Copy', action: 'copy' },
                    { label: 'Paste', action: 'paste' },
                    null,
                    { label: 'Select All', action: 'select-all' },
                    { label: 'Preferences', action: 'preferences' }
                ],
                'View': [
                    { label: 'as Icons', action: 'view-icons' },
                    { label: 'as List', action: 'view-list' },
                    null,
                    { label: 'Show Hidden Files', action: 'show-hidden' },
                    { label: 'Show Preview', action: 'show-preview' },
                    null,
                    { label: 'Enter Full Screen', action: 'fullscreen' }
                ],
                'Go': [
                    { label: 'Back', action: 'back' },
                    { label: 'Forward', action: 'forward' },
                    null,
                    { label: 'Home', action: 'home' },
                    { label: 'Documents', action: 'documents' },
                    { label: 'Downloads', action: 'downloads' }
                ],
                'Window': [
                    { label: 'Minimize', action: 'minimize' },
                    { label: 'Zoom', action: 'zoom' },
                    null,
                    { label: 'Show Previous Tab', action: 'prev-tab' },
                    { label: 'Show Next Tab', action: 'next-tab' },
                    null,
                    { label: 'Bring All to Front', action: 'bring-front' }
                ],
                'Help': [
                    { label: 'Zephyrus Help', action: 'help' },
                    null,
                    { label: 'Keyboard Shortcuts', action: 'shortcuts' },
                    null,
                    { label: 'About', action: 'about' }
                ]
            };
            
            return menus[menuName] || [{ label: '(Empty)', action: 'none' }];
        }
        
        _createSystemTray() {
            return new St.BoxLayout({
                style_class: 'zephyrus-system-tray',
                x_align: Clutter.ActorAlign.END
            });
        }
        
        _createClock() {
            const button = new St.Button({
                style_class: 'zephyrus-clock-button',
                reactive: true
            });
            
            this._clockLabel = new St.Label({
                style_class: 'zephyrus-clock-label',
                text: this._getTime()
            });
            button.set_child(this._clockLabel);
            
            // Update every second
            this._clockTimeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
                this._clockLabel.set_text(this._getTime());
                return GLib.SOURCE_CONTINUE;
            });
            
            return button;
        }
        
        _createROGStatus() {
            return new St.BoxLayout({
                style_class: 'zephyrus-status-icons',
                x_align: Clutter.ActorAlign.END
            });
        }
        
        _getTime() {
            const now = new Date();
            return now.toLocaleTimeString('en-US', { 
                hour: 'numeric', 
                minute: '2-digit',
                hour12: true 
            });
        }
        
        // Menu Actions
        _showAbout() {
            GLib.spawn_command_line_async('zenity --info --title="About Zephyrus OS" --text="Zephyrus OS 41 (ROG Edition)" --width=300');
        }
        
        _openSettings() {
            GLib.spawn_command_line_async('gnome-control-center');
        }
        
        _openROGCenter() {
            GLib.spawn_command_line_async('rog-control-center');
        }
        
        _togglePerformance() {
            // Toggle between Silent, Performance, Turbo
            log('Zephyrus: Toggle performance mode');
        }
        
        _sleep() {
            GLib.spawn_command_line_async('systemctl suspend');
        }
        
        _restart() {
            GLib.spawn_command_line_async('systemctl reboot');
        }
        
        _shutdown() {
            GLib.spawn_command_line_async('systemctl poweroff');
        }
        
        _activateMenuItem(menu, action) {
            log(`Zephyrus: ${menu} > ${action}`);
            // TODO: Send to active application
        }
        
        destroy() {
            if (this._clockTimeout) {
                GLib.source_remove(this._clockTimeout);
                this._clockTimeout = null;
            }
            super.destroy();
        }
    }
);

// Export for use in extension
export function init() {
    log('Zephyrus Panel: Initializing');
}

export function enable() {
    // Replace GNOME's top panel
    Main.panel.hide();
    
    const panel = new ZephyrusPanel();
    Main.layoutManager.panelBox.add_child(panel);
    
    global.zephyrusPanel = panel;
    log('Zephyrus Panel: Enabled');
}

export function disable() {
    if (global.zephyrusPanel) {
        global.zephyrusPanel.destroy();
        global.zephyrusPanel = null;
    }
    
    Main.panel.show();
    log('Zephyrus Panel: Disabled');
}
