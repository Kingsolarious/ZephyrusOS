import St from 'gi://St';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';

const BUS_NAME = 'org.zephyrus.MenuService';
const OBJECT_PATH = '/org/zephyrus/MenuService';
const INTERFACE = 'org.zephyrus.MenuInterface';

export default class ZephyrusGlobalMenuExtension {
    enable() {
        this._proxy = null;
        this._menuBox = null;
        this._activeMenu = null;
        
        // Create menu container
        this._menuBox = new St.BoxLayout({
            style_class: 'zephyrus-global-menu',
            x_expand: true,
            y_expand: false
        });
        
        // Insert into panel
        Main.panel._leftBox.insert_child_at_index(this._menuBox, 1);
        
        // Connect to D-Bus
        this._connectToService();
        
        // Watch for focus changes
        this._focusSignal = global.display.connect('notify::focus-window', 
            this._onFocusChanged.bind(this));
    }
    
    async _connectToService() {
        try {
            const Gio = await import('gi://Gio');
            
            // Create D-Bus proxy
            this._proxy = new Gio.DBusProxy({
                g_connection: Gio.DBus.session,
                g_name: BUS_NAME,
                g_object_path: OBJECT_PATH,
                g_interface_name: INTERFACE,
            });
            
            await this._proxy.init_async(GLib.PRIORITY_DEFAULT, null);
            
            // Connect signals
            this._proxy.connect('g-signal', (proxy, sender, signal, params) => {
                if (signal === 'MenuChanged') {
                    this._updateMenu();
                } else if (signal === 'ActiveAppChanged') {
                    this._updateMenu();
                }
            });
            
            // Initial update
            this._updateMenu();
            
        } catch (e) {
            log('Zephyrus Menu: ' + e.message);
            // Show placeholder
            this._showPlaceholder();
        }
    }
    
    _onFocusChanged() {
        const window = global.display.focus_window;
        if (window) {
            const app = window.get_wm_class() || window.get_title();
            this._notifyActiveApp(app);
        }
    }
    
    _notifyActiveApp(appId) {
        if (this._proxy) {
            try {
                this._proxy.SetActiveAppRemote(appId);
            } catch (e) {}
        }
    }
    
    async _updateMenu() {
        if (!this._proxy) return;
        
        try {
            // Get active app's menu
            const window = global.display.focus_window;
            if (!window) return;
            
            const appId = window.get_wm_class() || window.get_title();
            const [menuJson] = await this._proxy.GetMenuRemote(appId);
            
            if (menuJson && menuJson !== '{}') {
                const menuData = JSON.parse(menuJson);
                this._buildMenu(menuData);
            } else {
                this._showPlaceholder();
            }
            
        } catch (e) {
            log('Zephyrus Menu: Error updating ' + e.message);
        }
    }
    
    _buildMenu(menuData) {
        // Clear existing
        this._menuBox.destroy_all_children();
        
        // Build menu items
        if (menuData.menus) {
            for (const menu of menuData.menus) {
                const button = new St.Button({
                    label: menu.label,
                    style_class: 'zephyrus-menu-item',
                    y_align: 2  // CENTER
                });
                
                button.connect('clicked', () => {
                    this._showSubmenu(menu);
                });
                
                this._menuBox.add_child(button);
            }
        }
    }
    
    _showSubmenu(menu) {
        // Create popup menu
        const popup = new PanelMenu.Button(0.0, menu.label);
        
        for (const item of menu.items || []) {
            const menuItem = new PanelMenu.MenuItem(item.label);
            menuItem.connect('activate', () => {
                this._activateItem(item.path);
            });
            popup.menu.addMenuItem(menuItem);
        }
        
        popup.menu.open();
    }
    
    _activateItem(path) {
        if (this._proxy) {
            const window = global.display.focus_window;
            if (window) {
                const appId = window.get_wm_class();
                this._proxy.ActivateMenuItemRemote(appId, path);
            }
        }
    }
    
    _showPlaceholder() {
        this._menuBox.destroy_all_children();
        
        const label = new St.Label({
            text: '',
            style_class: 'zephyrus-menu-placeholder'
        });
        
        this._menuBox.add_child(label);
    }
    
    disable() {
        if (this._focusSignal) {
            global.display.disconnect(this._focusSignal);
            this._focusSignal = null;
        }
        
        if (this._menuBox) {
            this._menuBox.destroy();
            this._menuBox = null;
        }
        
        this._proxy = null;
    }
}
