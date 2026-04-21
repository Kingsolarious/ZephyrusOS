#!/usr/bin/env python3
"""
Zephyrus Dock - WORKING VERSION
Actually launches apps when clicked
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Gdk', '4.0')
from gi.repository import Gtk, Gdk, GLib, Gio
import subprocess
import os
import sys

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
        self.set_decorated(False)
        self.set_resizable(False)
        
        # Set window type to dock
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)
        
        # Keep on top and all workspaces
        self.set_keep_above(True)
        self.set_sticky(True)
        
        # Skip taskbar
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        
        # Load CSS
        self._load_css()
        
        # Build the dock
        self._build_ui()
        
        # Position at bottom
        self._setup_positioning()
        
    def _load_css(self):
        css = """
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
                border-radius: 24px;
                border: 2px solid rgba(255, 0, 51, 0.4);
                box-shadow: 
                    0 0 0 1px rgba(0, 0, 0, 0.5),
                    0 15px 50px rgba(0, 0, 0, 0.6),
                    0 0 40px rgba(255, 0, 51, 0.25),
                    inset 0 1px 0 rgba(255, 255, 255, 0.15);
                padding: 14px 24px;
                margin: 8px;
            }
            
            .dock-button {
                background: transparent;
                border: none;
                border-radius: 14px;
                padding: 10px;
                margin: 0 6px;
                transition: all 200ms ease;
            }
            
            .dock-button:hover {
                background: rgba(255, 0, 51, 0.2);
                box-shadow: 0 0 25px rgba(255, 0, 51, 0.5);
            }
            
            .dock-icon {
                min-width: 52px;
                min-height: 52px;
            }
            
            .dock-separator {
                background: rgba(255, 255, 255, 0.15);
                min-width: 2px;
                min-height: 44px;
                margin: 0 10px;
                border-radius: 1px;
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
        # Main vertical box to push dock to bottom
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_child(main_box)
        
        # Spacer to push dock down
        spacer = Gtk.Box()
        spacer.set_vexpand(True)
        main_box.append(spacer)
        
        # Dock container
        dock_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        dock_box.add_css_class('dock-container')
        dock_box.set_halign(Gtk.Align.CENTER)
        dock_box.set_margin_bottom(16)
        main_box.append(dock_box)
        
        # WORKING dock items - these actually launch apps
        dock_items = [
            # (name, icon_name, command)
            ("Files", "folder", "nautilus"),
            ("Games", "input-gaming", "steam"),
            ("Downloads", "folder-download", "nautilus ~/Downloads"),
            ("Terminal", "utilities-terminal", "gnome-terminal"),
            ("Browser", "web-browser", "firefox"),
            None,  # Separator
            ("Trash", "user-trash", "nautilus trash:///"),
        ]
        
        for item in dock_items:
            if item is None:
                # Separator
                sep = Gtk.Box()
                sep.add_css_class('dock-separator')
                dock_box.append(sep)
            else:
                name, icon_name, command = item
                btn = self._create_button(name, icon_name, command)
                dock_box.append(btn)
                
    def _create_button(self, name, icon_name, command):
        """Create a working dock button"""
        button = Gtk.Button()
        button.add_css_class('dock-button')
        button.set_tooltip_text(name)
        
        # Icon
        icon = Gtk.Image.new_from_icon_name(icon_name)
        icon.set_pixel_size(48)
        icon.add_css_class('dock-icon')
        button.set_child(icon)
        
        # CLICK HANDLER - Actually launches the app!
        button.connect('clicked', lambda btn, cmd=command: self._launch(cmd))
        
        return button
        
    def _launch(self, command):
        """Launch an application"""
        print(f"Launching: {command}")
        try:
            # Use subprocess.Popen to launch without blocking
            subprocess.Popen(command, shell=True, 
                           stdout=subprocess.DEVNULL, 
                           stderr=subprocess.DEVNULL,
                           start_new_session=True)
        except Exception as e:
            print(f"Error launching {command}: {e}")
            # Show error dialog
            self._show_error(f"Could not launch: {command}")
            
    def _show_error(self, message):
        """Show error dialog"""
        dialog = Gtk.MessageDialog(
            transient_for=self,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text=message
        )
        dialog.connect('response', lambda d, r: d.destroy())
        dialog.present()
        
    def _setup_positioning(self):
        """Position at bottom center of screen"""
        # Get display dimensions
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor()
        geometry = monitor.get_geometry()
        
        width = geometry.width
        height = geometry.height
        
        # Size the window
        self.set_default_size(600, 100)
        
        # Position after window is realized
        GLib.timeout_add(100, self._do_position, width, height)
        
    def _do_position(self, screen_width, screen_height):
        """Actually move the window"""
        # Move to bottom center
        self.move(screen_width // 2 - 300, screen_height - 120)
        return False

def main():
    app = ZephyrusDock()
    app.run(None)

if __name__ == '__main__':
    main()
