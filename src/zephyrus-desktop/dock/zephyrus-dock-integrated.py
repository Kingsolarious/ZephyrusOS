#!/usr/bin/env python3
"""
Zephyrus Dock - Panel-integrated version
Replaces the need for a separate dock extension
"""

import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gdk, GLib
import subprocess
import os

class ZephyrusDockWindow(Gtk.Window):
    """Dock window that docks at the bottom"""
    
    def __init__(self):
        super().__init__()
        
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)
        self.set_keep_above(True)
        self.set_sticky(True)
        
        # Remove default styling
        self.add_css_class('zephyrus-dock-window')
        
        self._load_css()
        self._build_ui()
        self._setup_positioning()
        
    def _load_css(self):
        css = """
            .zephyrus-dock-window {
                background: transparent;
            }
            
            .dock-main-container {
                background: linear-gradient(
                    180deg,
                    rgba(80, 15, 20, 0.95) 0%,
                    rgba(50, 10, 15, 0.98) 50%,
                    rgba(30, 5, 8, 0.99) 100%
                );
                border-radius: 24px;
                border: 2px solid rgba(255, 0, 51, 0.4);
                box-shadow: 
                    0 0 0 1px rgba(0, 0, 0, 0.5),
                    0 15px 50px rgba(0, 0, 0, 0.6),
                    0 0 40px rgba(255, 0, 51, 0.25),
                    inset 0 1px 0 rgba(255, 255, 255, 0.15);
                padding: 14px 24px;
            }
            
            .dock-item {
                background: transparent;
                border: none;
                border-radius: 14px;
                padding: 10px;
                margin: 0 8px;
                transition: all 250ms cubic-bezier(0.4, 0, 0.2, 1);
            }
            
            .dock-item:hover {
                background: rgba(255, 0, 51, 0.2);
                box-shadow: 
                    0 0 25px rgba(255, 0, 51, 0.5),
                    0 8px 16px rgba(0, 0, 0, 0.3);
                transform: translateY(-10px) scale(1.05);
            }
            
            .dock-item:active {
                background: rgba(255, 0, 51, 0.35);
                transform: translateY(-5px) scale(0.98);
            }
            
            .dock-icon {
                icon-size: 52px;
                -gtk-icon-size: 52px;
            }
            
            .dock-separator {
                background: rgba(255, 255, 255, 0.12);
                min-width: 2px;
                min-height: 44px;
                margin: 0 12px;
                border-radius: 1px;
            }
            
            .dock-tooltip {
                background: rgba(30, 30, 30, 0.95);
                border-radius: 8px;
                border: 1px solid rgba(255, 0, 51, 0.3);
                padding: 8px 16px;
                color: white;
                font-size: 13px;
                font-weight: 500;
            }
        """
        
        provider = Gtk.CssProvider()
        provider.load_from_data(css.encode())
        
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        
    def _build_ui(self):
        # Main box to center the dock
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        main_box.set_valign(Gtk.Align.END)
        main_box.set_vexpand(True)
        self.set_child(main_box)
        
        # Dock container
        dock_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        dock_box.add_css_class('dock-main-container')
        dock_box.set_halign(Gtk.Align.CENTER)
        dock_box.set_valign(Gtk.Align.END)
        dock_box.set_margin_bottom(16)
        main_box.append(dock_box)
        
        # Dock items with icons matching your screenshot
        items = [
            ('files', 'Files', self._launch_files, 'folder'),
            ('games', 'Games', self._launch_games, 'input-gaming'),
            ('downloads', 'Downloads', self._launch_downloads, 'folder-download'),
            ('terminal', 'Terminal', self._launch_terminal, 'utilities-terminal'),
            ('nvidia', 'NVIDIA', self._launch_nvidia, 'nvidia'),
            None,  # Separator
            ('trash', 'Trash', self._launch_trash, 'user-trash'),
        ]
        
        for item in items:
            if item is None:
                sep = Gtk.Box()
                sep.add_css_class('dock-separator')
                dock_box.append(sep)
            else:
                key, label, callback, icon_name = item
                btn = self._create_item(label, callback, icon_name)
                dock_box.append(btn)
                
    def _create_item(self, label, callback, icon_name):
        btn = Gtk.Button()
        btn.add_css_class('dock-item')
        
        # Set tooltip
        btn.set_tooltip_text(label)
        
        # Create icon
        image = Gtk.Image()
        
        # Try custom ROG icon first
        custom_icon = self._get_custom_icon(icon_name)
        if custom_icon and os.path.exists(custom_icon):
            image.set_from_file(custom_icon)
        else:
            image.set_from_icon_name(icon_name)
        
        image.set_pixel_size(52)
        image.add_css_class('dock-icon')
        btn.set_child(image)
        
        # Connect click
        btn.connect('clicked', lambda b: callback())
        
        return btn
        
    def _get_custom_icon(self, icon_name):
        icon_dir = os.path.expanduser('~/.local/share/zephyrus-desktop/icons/dock')
        
        # Map to custom icon files
        mapping = {
            'folder': 'rog-files.svg',
            'input-gaming': 'rog-gamepad.svg',
            'folder-download': 'rog-folder.svg',
            'utilities-terminal': 'rog-terminal.svg',
            'nvidia': 'nvidia.svg',
            'user-trash': 'trash.svg',
        }
        
        if icon_name in mapping:
            return os.path.join(icon_dir, mapping[icon_name])
        return None
        
    def _setup_positioning(self):
        # Position at bottom center
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor()
        geometry = monitor.get_geometry()
        
        scale = monitor.get_scale_factor()
        width = geometry.width
        height = geometry.height
        
        # Dock will auto-size based on content
        self.set_default_size(600, 100)
        
    def _launch_files(self):
        subprocess.Popen(['nautilus'])
        
    def _launch_games(self):
        subprocess.Popen(['steam'])
        
    def _launch_downloads(self):
        subprocess.Popen(['nautilus', os.path.expanduser('~/Downloads')])
        
    def _launch_terminal(self):
        subprocess.Popen(['gnome-terminal'])
        
    def _launch_nvidia(self):
        subprocess.Popen(['nvidia-settings'])
        
    def _launch_trash(self):
        subprocess.Popen(['nautilus', 'trash:///'])

def main():
    app = Gtk.Application(application_id='org.zephyrus.Dock')
    
    def on_activate(app):
        if not app.get_windows():
            win = ZephyrusDockWindow()
            app.add_window(win)
            win.present()
    
    app.connect('activate', on_activate)
    app.run(None)

if __name__ == '__main__':
    main()
