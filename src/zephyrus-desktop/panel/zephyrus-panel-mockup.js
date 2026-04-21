// Zephyrus Panel - Exact mockup implementation
// Layout: [ROG Logo] [Rüe] [Finder] [File] [Edit] [View] [Go] [Window] [System] [Spacer] [WiFi] [Battery] [Clock]

import St from 'gi://St';
import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

export const ZephyrusPanel = GObject.registerClass(
    class ZephyrusPanel extends St.BoxLayout {
        _init() {
            super._init({
                name: 'zephyrusPanel',
                style_class: 'zephyrus-panel-mockup',
                reactive: true,
                track_hover: true,
                x_expand: true,
                y_expand: false,
                vertical: false
            });
            
            this._buildPanel();
        }
        
        _buildPanel() {
            // LEFT SECTION: Logo + Brand + App + Menus
            const leftBox = new St.BoxLayout({
                style_class: 'zephyrus-panel-left',
                x_align: Clutter.ActorAlign.START,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            // 1. ROG Logo
            const rogButton = this._createROGLogo();
            leftBox.add_child(rogButton);
            
            // 2. "ROG" Brand Text
            const brandLabel = new St.Label({
                text: 'ROG',
                style_class: 'zephyrus-brand-text',
                y_align: Clutter.ActorAlign.CENTER
            });
            leftBox.add_child(brandLabel);
            
            // 3. Separator
            leftBox.add_child(new St.Label({ 
                text: '  ', 
                style_class: 'zephyrus-separator' 
            }));
            
            // 4. App Name ("Finder")
            const appButton = this._createAppButton('Finder');
            leftBox.add_child(appButton);
            
            // 5. Separator
            leftBox.add_child(new St.Label({ 
                text: '  ', 
                style_class: 'zephyrus-separator' 
            }));
            
            // 6. Menu Items: File, Edit, View, Go, Window, System
            const menus = ['File', 'Edit', 'View', 'Go', 'Window', 'System'];
            for (const menuName of menus) {
                const menuButton = this._createMenuButton(menuName);
                leftBox.add_child(menuButton);
            }
            
            this.add_child(leftBox);
            
            // SPACER (fills remaining space)
            const spacer = new St.Widget({
                x_expand: true
            });
            this.add_child(spacer);
            
            // RIGHT SECTION: System icons + Clock
            const rightBox = new St.BoxLayout({
                style_class: 'zephyrus-panel-right',
                x_align: Clutter.ActorAlign.END,
                y_align: Clutter.ActorAlign.CENTER,
                spacing: 16
            });
            
            // WiFi Icon
            const wifiIcon = new St.Icon({
                icon_name: 'network-wireless-symbolic',
                style_class: 'zephyrus-status-icon',
                icon_size: 18
            });
            rightBox.add_child(wifiIcon);
            
            // Battery Icon
            const batteryIcon = new St.Icon({
                icon_name: 'battery-full-symbolic',
                style_class: 'zephyrus-status-icon',
                icon_size: 18
            });
            rightBox.add_child(batteryIcon);
            
            // Clock: "Tue Apr 24 11:27 AM"
            const clockButton = this._createClock();
            rightBox.add_child(clockButton);
            
            // Add padding on right
            rightBox.add_child(new St.Label({ 
                text: '  ', 
                style_class: 'zephyrus-right-padding' 
            }));
            
            this.add_child(rightBox);
        }
        
        _createROGLogo() {
            const button = new St.Button({
                style_class: 'zephyrus-rog-button',
                reactive: true,
                can_focus: true,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            // Load SVG
            const iconPath = GLib.build_filenamev([
                GLib.get_home_dir(),
                '.local/share/gnome-shell/extensions/zephyrus-panel@zephyrus-os/assets/rog-eye.svg'
            ]);
            
            let child;
            if (GLib.file_test(iconPath, GLib.FileTest.EXISTS)) {
                const file = Gio.File.new_for_path(iconPath);
                child = new St.Icon({
                    gicon: Gio.FileIcon.new(file),
                    style_class: 'zephyrus-rog-icon',
                    icon_size: 24,
                    width: 40,
                    height: 24
                });
            } else {
                child = new St.Label({ 
                    text: '⚡', 
                    style_class: 'zephyrus-rog-fallback' 
                });
            }
            
            button.set_child(child);
            button.set_width(50);
            button.set_height(28);
            
            // ROG Menu
            this._rogMenu = new PopupMenu.PopupMenu(button, 0.0, St.Side.TOP);
            this._buildROGMenu();
            Main.uiGroup.add_child(this._rogMenu.actor);
            this._rogMenu.actor.hide();
            
            button.connect('clicked', () => this._rogMenu.toggle());
            
            return button;
        }
        
        _createAppButton(appName) {
            const button = new St.Button({
                style_class: 'zephyrus-app-button',
                reactive: true,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            const label = new St.Label({
                text: appName,
                style_class: 'zephyrus-app-label',
                y_align: Clutter.ActorAlign.CENTER
            });
            button.set_child(label);
            
            // App menu
            const menu = new PopupMenu.PopupMenu(button, 0.0, St.Side.TOP);
            this._buildAppMenu(menu);
            Main.uiGroup.add_child(menu.actor);
            menu.actor.hide();
            
            button.connect('clicked', () => menu.toggle());
            
            return button;
        }
        
        _createMenuButton(menuName) {
            const button = new St.Button({
                label: menuName,
                style_class: 'zephyrus-menu-button',
                reactive: true,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            // Menu popup
            const menu = new PopupMenu.PopupMenu(button, 0.0, St.Side.TOP);
            menu.actor.add_style_class_name('zephyrus-menubar-popup');
            this._buildMenuContents(menu, menuName);
            Main.uiGroup.add_child(menu.actor);
            menu.actor.hide();
            
            button.connect('clicked', () => menu.toggle());
            
            return button;
        }
        
        _createClock() {
            const button = new St.Button({
                style_class: 'zephyrus-clock-button',
                reactive: true,
                y_align: Clutter.ActorAlign.CENTER
            });
            
            this._clockLabel = new St.Label({
                text: this._getFullTime(),
                style_class: 'zephyrus-clock-full',
                y_align: Clutter.ActorAlign.CENTER
            });
            button.set_child(this._clockLabel);
            
            // Update every minute
            this._clockTimeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 60, () => {
                this._clockLabel.set_text(this._getFullTime());
                return GLib.SOURCE_CONTINUE;
            });
            
            return button;
        }
        
        _getFullTime() {
            const now = new Date();
            // Format: "Tue Apr 24 11:27 AM"
            const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            
            const day = days[now.getDay()];
            const month = months[now.getMonth()];
            const date = now.getDate();
            
            let hours = now.getHours();
            const ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12;
            const minutes = now.getMinutes().toString().padStart(2, '0');
            
            return `${day} ${month} ${date} ${hours}:${minutes} ${ampm}`;
        }
        
        _buildROGMenu() {
            const items = [
                { label: 'About This Zephyrus', action: () => this._showAbout() },
                { label: 'System Settings...', action: () => this._openSettings() },
                null,
                { label: 'ROG Control Center', action: () => this._openROG() },
                { label: 'App Store', action: () => this._openStore() },
                null,
                { label: 'Recent Items', action: () => {}, hasArrow: true },
                null,
                { label: 'Force Quit...', action: () => this._forceQuit() },
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
        
        _buildAppMenu(menu) {
            const items = [
                { label: 'About Finder', action: () => {} },
                { label: 'Preferences...', action: () => {}, shortcut: ',' },
                null,
                { label: 'Services', action: () => {}, hasArrow: true },
                null,
                { label: 'Hide Finder', action: () => {}, shortcut: 'H' },
                { label: 'Hide Others', action: () => {}, shortcut: 'H' },
                { label: 'Show All', action: () => {} },
                null,
                { label: 'Quit Finder', action: () => {}, shortcut: 'Q' }
            ];
            
            for (const item of items) {
                if (item === null) {
                    menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
                } else {
                    const menuItem = new PopupMenu.PopupMenuItem(item.label);
                    menuItem.connect('activate', item.action);
                    menu.addMenuItem(menuItem);
                }
            }
        }
        
        _buildMenuContents(menu, menuName) {
            const menuItems = {
                'File': [
                    { label: 'New Finder Window', shortcut: 'N' },
                    { label: 'New Folder', shortcut: 'Shift+N' },
                    { label: 'New Folder with Selection' },
                    { label: 'New Smart Folder' },
                    { label: 'New Tab', shortcut: 'T' },
                    null,
                    { label: 'Open', shortcut: 'O' },
                    { label: 'Open With', hasArrow: true },
                    { label: 'Print...', shortcut: 'P' },
                    null,
                    { label: 'Close Window', shortcut: 'W' }
                ],
                'Edit': [
                    { label: 'Undo', shortcut: 'Z' },
                    { label: 'Redo', shortcut: 'Shift+Z' },
                    null,
                    { label: 'Cut', shortcut: 'X' },
                    { label: 'Copy', shortcut: 'C' },
                    { label: 'Paste', shortcut: 'V' },
                    { label: 'Select All', shortcut: 'A' },
                    null,
                    { label: 'Show Clipboard' }
                ],
                'View': [
                    { label: 'as Icons', shortcut: '1' },
                    { label: 'as List', shortcut: '2' },
                    { label: 'as Columns', shortcut: '3' },
                    { label: 'as Gallery', shortcut: '4' },
                    null,
                    { label: 'Use Stacks' },
                    { label: 'Group Stacks By', hasArrow: true },
                    null,
                    { label: 'Show Preview', shortcut: 'P' },
                    { label: 'Hide Sidebar', shortcut: 'Option+S' },
                    { label: 'Show Preview', shortcut: 'Shift+P' }
                ],
                'Go': [
                    { label: 'Back', shortcut: '[' },
                    { label: 'Forward', shortcut: ']' },
                    { label: 'Enclosing Folder', shortcut: 'Up' },
                    null,
                    { label: 'Recents' },
                    { label: 'Documents' },
                    { label: 'Desktop' },
                    { label: 'Downloads' },
                    { label: 'Home', shortcut: 'Shift+H' },
                    null,
                    { label: 'Go to Folder...', shortcut: 'Shift+G' },
                    { label: 'Connect to Server...', shortcut: 'K' }
                ],
                'Window': [
                    { label: 'Minimize', shortcut: 'M' },
                    { label: 'Zoom' },
                    { label: 'Move Window to Left Side of Screen' },
                    { label: 'Move Window to Right Side of Screen' },
                    null,
                    { label: 'Show Previous Tab', shortcut: 'Shift+Tab' },
                    { label: 'Show Next Tab', shortcut: 'Tab' },
                    { label: 'Move Tab to New Window' },
                    null,
                    { label: 'Bring All to Front' }
                ],
                'System': [
                    { label: 'ROG Control Center' },
                    { label: 'Performance Mode' },
                    null,
                    { label: 'WiFi', hasCheck: true },
                    { label: 'Bluetooth', hasCheck: true },
                    null,
                    { label: 'Displays' },
                    { label: 'Sound' },
                    null,
                    { label: 'Settings...' }
                ]
            };
            
            const items = menuItems[menuName] || [{ label: '(Empty)' }];
            
            for (const item of items) {
                if (item === null) {
                    menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
                } else {
                    const menuItem = new PopupMenu.PopupMenuItem(item.label);
                    menu.addMenuItem(menuItem);
                }
            }
        }
        
        // Actions
        _showAbout() {
            GLib.spawn_command_line_async('zenity --info --title="About Zephyrus OS" --text="Zephyrus OS 41 (ROG Edition)\\n\\nThe Ultimate ROG Experience" --width=300');
        }
        
        _openSettings() {
            GLib.spawn_command_line_async('gnome-control-center');
        }
        
        _openROG() {
            GLib.spawn_command_line_async('rog-control-center');
        }
        
        _openStore() {
            GLib.spawn_command_line_async('gnome-software');
        }
        
        _forceQuit() {
            log('Force quit');
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
        
        destroy() {
            if (this._clockTimeout) {
                GLib.source_remove(this._clockTimeout);
                this._clockTimeout = null;
            }
            super.destroy();
        }
    }
);

// Extension entry points
export function init() {
    log('Zephyrus Panel Mockup: Initializing');
}

export function enable() {
    // Hide default panel
    Main.panel.hide();
    
    // Add our panel
    const panel = new ZephyrusPanel();
    Main.layoutManager.panelBox.add_child(panel);
    
    global.zephyrusPanelMockup = panel;
    log('Zephyrus Panel Mockup: Enabled');
}

export function disable() {
    if (global.zephyrusPanelMockup) {
        global.zephyrusPanelMockup.destroy();
        global.zephyrusPanelMockup = null;
    }
    
    Main.panel.show();
    log('Zephyrus Panel Mockup: Disabled');
}
