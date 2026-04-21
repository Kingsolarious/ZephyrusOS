#!/usr/bin/env python3
"""
Zephyrus Dock - STYLED VERSION
Matches the photo with ROG styling + working apps
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Gdk', '4.0')
from gi.repository import Gtk, Gdk, GLib, Gio
import subprocess
import os
import cairo

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
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)
        self.set_keep_above(True)
        self.set_sticky(True)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        
        self._load_css()
        self._build_ui()
        
    def _load_css(self):
        css = """
            window {
                background: transparent;
            }
            
            .dock-bg {
                background: linear-gradient(
                    180deg,
                    rgba(90, 20, 30, 0.95) 0%,
                    rgba(60, 15, 20, 0.98) 30%,
                    rgba(35, 8, 12, 0.99) 100%
                );
                border-radius: 28px;
                border: 2px solid rgba(255, 0, 51, 0.5);
                box-shadow: 
                    0 0 0 1px rgba(0, 0, 0, 0.6),
                    0 20px 60px rgba(0, 0, 0, 0.7),
                    0 0 50px rgba(255, 0, 51, 0.3),
                    inset 0 1px 0 rgba(255, 255, 255, 0.2);
                padding: 16px 28px;
            }
            
            .dock-icon-button {
                background: linear-gradient(
                    145deg,
                    rgba(255, 255, 255, 0.1) 0%,
                    rgba(255, 255, 255, 0.05) 100%
                );
                border: 1px solid rgba(255, 0, 51, 0.3);
                border-radius: 16px;
                padding: 12px;
                margin: 0 8px;
                box-shadow: 
                    0 4px 8px rgba(0, 0, 0, 0.3),
                    inset 0 1px 0 rgba(255, 255, 255, 0.1);
            }
            
            .dock-icon-button:hover {
                background: linear-gradient(
                    145deg,
                    rgba(255, 0, 51, 0.3) 0%,
                    rgba(255, 0, 51, 0.2) 100%
                );
                border-color: rgba(255, 0, 51, 0.6);
                box-shadow: 
                    0 0 30px rgba(255, 0, 51, 0.5),
                    0 8px 16px rgba(0, 0, 0, 0.4);
            }
            
            .dock-icon {
                min-width: 48px;
                min-height: 48px;
                color: #ffffff;
            }
            
            .separator-line {
                background: rgba(255, 255, 255, 0.2);
                min-width: 2px;
                min-height: 48px;
                margin: 0 12px;
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
        # Main box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_child(main_box)
        
        # Spacer
        spacer = Gtk.Box()
        spacer.set_vexpand(True)
        main_box.append(spacer)
        
        # Dock container
        dock = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        dock.add_css_class('dock-bg')
        dock.set_halign(Gtk.Align.CENTER)
        dock.set_margin_bottom(20)
        main_box.append(dock)
        
        # Dock items from your photo
        items = [
            # Name, icon, command
            ("Files", "folder", self._open_files),
            ("Games", "input-gaming", self._open_games),
            ("Downloads", "folder-download", self._open_downloads),
            ("Terminal", "utilities-terminal", self._open_terminal),
            ("NVIDIA", "nvidia", self._open_nvidia),
            None,  # Separator
            ("Trash", "user-trash", self._open_trash),
        ]
        
        for item in items:
            if item is None:
                sep = Gtk.Box()
                sep.add_css_class('separator-line')
                dock.append(sep)
            else:
                name, icon_name, callback = item
                btn = self._create_icon_button(name, icon_name, callback)
                dock.append(btn)
                
    def _create_icon_button(self, name, icon_name, callback):
        """Create styled icon button"""
        button = Gtk.Button()
        button.add_css_class('dock-icon-button')
        button.set_tooltip_text(name)
        button.set_size_request(72, 72)
        
        # Icon with custom styling
        icon = Gtk.Image.new_from_icon_name(icon_name)
        icon.set_pixel_size(48)
        icon.add_css_class('dock-icon')
        
        # Try to color the icon red for ROG theme
        if icon_name in ['folder', 'folder-download']:
            # These will use system icons but styled
            pass
            
        button.set_child(icon)
        
        # Launch app on click
        button.connect('clicked', lambda btn: callback())
        
        return button
        
    # APP LAUNCHERS - These actually work!
    def _open_files(self):
        """Open file manager"""
        self._run("nautilus || dolphin || pcmanfm || xdg-open $HOME")
        
    def _open_games(self):
        """Open Steam or game launcher"""
        self._run("steam || lutris || echo 'Steam not installed'")
        
    def _open_downloads(self):
        """Open Downloads folder"""
        self._run("xdg-open ~/Downloads")
        
    def _open_terminal(self):
        """Open terminal"""
        self._run("gnome-terminal || konsole || xfce4-terminal || xterm")
        
    def _open_nvidia(self):
        """Open NVIDIA settings"""
        self._run("nvidia-settings || echo 'NVIDIA settings not available'")
        
    def _open_trash(self):
        """Open trash"""
        self._run("xdg-open trash://")
        
    def _run(self, command):
        """Run a command"""
        print(f"Dock: Launching '{command}'")
        try:
            subprocess.Popen(command, shell=True, 
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL,
                           start_new_session=True)
        except Exception as e:
            print(f"Error: {e}")

def main():
    app = ZephyrusDock()
    
    def on_activate(app):
        if not app.get_windows():
            win = DockWindow(application=app)
            app.add_window(win)
            win.present()
    
    app.connect('activate', on_activate)
    app.run(None)

if __name__ == '__main__':
    main()
