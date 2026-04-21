#!/usr/bin/env python3
"""
Zephyrus Dock - Custom ROG-themed dock
Hardcoded, no extensions required
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Gdk', '4.0')
from gi.repository import Gtk, Gdk, GLib, Gio
import subprocess
import os

class ZephyrusDock(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.zephyrus.Dock')
        
    def do_activate(self):
        if not self.get_windows():
            window = DockWindow(application=self)
            window.present()
        else:
            self.get_windows()[0].present()

class DockWindow(Gtk.Window):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        
        self.set_title('Zephyrus Dock')
        self.set_decorated(False)  # No window decorations
        self.set_resizable(False)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)
        
        # Make it always on top and on all workspaces
        self.set_keep_above(True)
        self.set_sticky(True)
        
        # Load CSS
        self._load_css()
        
        # Build UI
        self._build_ui()
        
        # Position at bottom of screen
        self._position_dock()
        
        # Monitor window focus for autohide (optional)
        # self._setup_autohide()
        
    def _load_css(self):
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(b"""
            window {
                background: transparent;
            }
            
            .dock-container {
                background: linear-gradient(
                    180deg,
                    rgba(80, 15, 20, 0.95) 0%,
                    rgba(50, 10, 15, 0.98) 50%,
                    rgba(30, 5, 8, 0.99) 100%
                );
                border-radius: 20px;
                border: 2px solid rgba(255, 0, 51, 0.4);
                box-shadow: 
                    0 0 0 1px rgba(0, 0, 0, 0.5),
                    0 10px 40px rgba(0, 0, 0, 0.6),
                    0 0 30px rgba(255, 0, 51, 0.2),
                    inset 0 1px 0 rgba(255, 255, 255, 0.1);
                padding: 12px 20px;
                margin: 20px;
            }
            
            .dock-icon {
                background: transparent;
                border: none;
                border-radius: 12px;
                padding: 8px;
                margin: 0 6px;
                transition: all 200ms ease;
            }
            
            .dock-icon:hover {
                background: rgba(255, 0, 51, 0.25);
                box-shadow: 0 0 20px rgba(255, 0, 51, 0.4);
                transform: translateY(-8px);
            }
            
            .dock-icon:active {
                background: rgba(255, 0, 51, 0.4);
                transform: translateY(-4px);
            }
            
            .dock-icon-image {
                icon-size: 48px;
            }
            
            .separator {
                background: rgba(255, 255, 255, 0.15);
                min-width: 2px;
                min-height: 40px;
                margin: 0 10px;
                border-radius: 1px;
            }
        """)
        
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        
    def _build_ui(self):
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_child(main_box)
        
        # Spacer to push dock to bottom
        spacer = Gtk.Box()
        spacer.set_vexpand(True)
        main_box.append(spacer)
        
        # Dock container (centered)
        dock_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        dock_box.add_css_class('dock-container')
        dock_box.set_halign(Gtk.Align.CENTER)
        dock_box.set_valign(Gtk.Align.END)
        dock_box.set_margin_bottom(20)
        main_box.append(dock_box)
        
        # Define dock items
        dock_items = [
            # (icon_name, label, command, is_rog_themed)
            ('folder', 'Files', 'nautilus', True),
            ('input-gaming', 'Games', 'steam', True),  # Gamepad icon
            ('folder-download', 'Downloads', 'nautilus ~/Downloads', True),
            ('utilities-terminal', 'Terminal', 'gnome-terminal', True),
            ('nvidia', 'NVIDIA', 'nvidia-settings', False),  # NVIDIA icon
            None,  # Separator
            ('user-trash', 'Trash', 'nautilus trash:///', False),
        ]
        
        for item in dock_items:
            if item is None:
                # Add separator
                separator = Gtk.Box()
                separator.add_css_class('separator')
                dock_box.append(separator)
            else:
                icon_name, label, command, is_rog = item
                btn = self._create_dock_icon(icon_name, label, command, is_rog)
                dock_box.append(btn)
        
    def _create_dock_icon(self, icon_name, label, command, is_rog_themed):
        button = Gtk.Button()
        button.add_css_class('dock-icon')
        button.set_tooltip_text(label)
        
        # Try to load custom ROG icon first
        icon_path = None
        if is_rog_themed:
            icon_path = self._get_rog_icon_path(icon_name)
        
        if icon_path and os.path.exists(icon_path):
            image = Gtk.Image.new_from_file(icon_path)
            image.set_pixel_size(48)
        else:
            # Fall back to system icon
            image = Gtk.Image.new_from_icon_name(icon_name)
            image.set_pixel_size(48)
        
        image.add_css_class('dock-icon-image')
        button.set_child(image)
        
        # Click handler
        button.connect('clicked', lambda btn: self._launch_app(command))
        
        return button
        
    def _get_rog_icon_path(self, icon_name):
        """Get path to custom ROG-themed icon"""
        base_path = os.path.expanduser('~/.local/share/zephyrus-desktop/icons/dock')
        
        # Map icon names to ROG versions
        rog_icons = {
            'folder': 'rog-files.svg',
            'input-gaming': 'rog-gamepad.svg',
            'folder-download': 'rog-folder.svg',
            'utilities-terminal': 'rog-terminal.svg',
        }
        
        if icon_name in rog_icons:
            return os.path.join(base_path, rog_icons[icon_name])
        return None
        
    def _launch_app(self, command):
        try:
            subprocess.Popen(command.split())
        except Exception as e:
            print(f"Error launching {command}: {e}")
            
    def _position_dock(self):
        # Get screen dimensions
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor()
        geometry = monitor.get_geometry()
        
        screen_width = geometry.width
        screen_height = geometry.height
        
        # Dock size (approximate)
        dock_width = 500  # Adjust based on number of icons
        dock_height = 100
        
        # Position at bottom center
        x = (screen_width - dock_width) // 2
        y = screen_height - dock_height - 20
        
        self.set_default_size(dock_width, dock_height)
        
        # Move to position
        GLib.idle_add(self._move_to_position, x, y)
        
    def _move_to_position(self, x, y):
        self.move(x, y)
        return False

def main():
    app = ZephyrusDock()
    app.run(None)

if __name__ == '__main__':
    main()
