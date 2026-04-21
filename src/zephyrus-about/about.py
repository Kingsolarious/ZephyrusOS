#!/usr/bin/env python3
"""
About This Zephyrus
macOS-style About window with glass/translucent theme
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, GLib, GdkPixbuf, Gdk
import subprocess
import os

class AboutZephyrus(Adw.Application):
    def __init__(self):
        super().__init__(application_id='org.zephyrus.About')
        
    def do_activate(self):
        window = AboutWindow(application=self)
        window.present()

class AboutWindow(Adw.ApplicationWindow):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        
        self.set_title('About This Zephyrus')
        self.set_default_size(700, 500)
        self.set_resizable(False)
        
        # Add CSS provider
        self._load_css()
        
        # Build UI
        self._build_ui()
        
    def _load_css(self):
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(b"""
            window {
                background: linear-gradient(
                    180deg,
                    rgba(60, 15, 20, 0.98) 0%,
                    rgba(30, 8, 12, 0.99) 100%
                );
                border-radius: 16px;
            }
            
            .main-container {
                padding: 32px;
            }
            
            .rog-logo {
                filter: drop-shadow(0 0 30px rgba(255, 0, 51, 0.6));
            }
            
            .os-name {
                color: #ff0033;
                font-size: 28px;
                font-weight: 800;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
            }
            
            .version-text {
                color: rgba(255, 255, 255, 0.7);
                font-size: 14px;
                margin-top: 4px;
            }
            
            .info-label {
                color: #ffffff;
                font-size: 15px;
                margin: 4px 0;
            }
            
            .info-value {
                color: rgba(255, 255, 255, 0.8);
                font-size: 15px;
                font-weight: 500;
            }
            
            .tab-button {
                background: linear-gradient(
                    180deg,
                    rgba(60, 60, 60, 0.8) 0%,
                    rgba(40, 40, 40, 0.9) 100%
                );
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 8px;
                color: #cccccc;
                font-weight: 500;
                padding: 10px 24px;
                margin: 0 4px;
            }
            
            .tab-button:hover {
                background: linear-gradient(
                    180deg,
                    rgba(80, 80, 80, 0.9) 0%,
                    rgba(60, 60, 60, 1) 100%
                );
                color: #ffffff;
            }
            
            .tab-button.active {
                background: linear-gradient(
                    180deg,
                    rgba(255, 0, 51, 0.95) 0%,
                    rgba(200, 0, 40, 1) 100%
                );
                border-color: rgba(255, 0, 51, 0.5);
                color: #ffffff;
            }
            
            .action-button {
                background: linear-gradient(
                    180deg,
                    rgba(60, 60, 60, 0.9) 0%,
                    rgba(40, 40, 40, 1) 100%
                );
                border: 1px solid rgba(255, 255, 255, 0.15);
                border-radius: 8px;
                color: #ffffff;
                font-weight: 500;
                padding: 10px 24px;
            }
            
            .action-button:hover {
                background: linear-gradient(
                    180deg,
                    rgba(80, 80, 80, 0.95) 0%,
                    rgba(60, 60, 60, 1) 100%
                );
            }
            
            .separator-line {
                background: rgba(255, 255, 255, 0.1);
                min-height: 1px;
                margin: 16px 0;
            }
        """)
        
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        
    def _build_ui(self):
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        main_box.add_css_class('main-container')
        self.set_content(main_box)
        
        # Content area
        content_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=32)
        content_box.set_margin_top(16)
        content_box.set_margin_bottom(16)
        content_box.set_margin_start(16)
        content_box.set_margin_end(16)
        main_box.append(content_box)
        
        # Left side - ROG Logo
        logo_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        logo_box.set_valign(Gtk.Align.CENTER)
        logo_box.set_halign(Gtk.Align.CENTER)
        logo_box.set_size_request(200, -1)
        
        # Try to load ROG logo SVG
        logo_path = os.path.expanduser(
            '~/.local/share/gnome-shell/extensions/zephyrus-panel-mockup@zephyrus-os/assets/rog-eye.svg'
        )
        if not os.path.exists(logo_path):
            logo_path = os.path.expanduser(
                '~/.local/share/gnome-shell/extensions/zephyrus-globalmenu@solarious/assets/rog-eye.svg'
            )
        
        if os.path.exists(logo_path):
            logo_image = Gtk.Image.new_from_file(logo_path)
            logo_image.set_pixel_size(140)
            logo_image.add_css_class('rog-logo')
            logo_box.append(logo_image)
        else:
            # Fallback text logo
            logo_label = Gtk.Label(label='⚡')
            logo_label.add_css_class('rog-logo')
            logo_label.set_markup('<span font_size="72pt" color="#ff0033">⚡</span>')
            logo_box.append(logo_label)
        
        content_box.append(logo_box)
        
        # Right side - Info
        info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        info_box.set_valign(Gtk.Align.CENTER)
        info_box.set_hexpand(True)
        
        # OS Name
        os_name = Gtk.Label(label='ROG ZEPHYRUS G16 OS')
        os_name.add_css_class('os-name')
        info_box.append(os_name)
        
        # Version
        version = Gtk.Label(label='Version 41 (Zephyrus OS)')
        version.add_css_class('version-text')
        info_box.append(version)
        
        # Separator
        separator = Gtk.Box()
        separator.add_css_class('separator-line')
        separator.set_margin_top(16)
        separator.set_margin_bottom(16)
        info_box.append(separator)
        
        # System Info
        info_items = [
            ('ROG Zephyrus G16 (2024)', 'bold'),
            ('Intel Core i9', 'normal'),
            ('32 GB DDR5', 'normal'),
            ('NVIDIA GeForce RTX 4090', 'normal')
        ]
        
        for text, weight in info_items:
            label = Gtk.Label(label=text)
            label.add_css_class('info-label')
            if weight == 'bold':
                label.set_markup(f'<b>{text}</b>')
            label.set_halign(Gtk.Align.START)
            info_box.append(label)
        
        content_box.append(info_box)
        
        # Separator before tabs
        sep2 = Gtk.Box()
        sep2.add_css_class('separator-line')
        sep2.set_margin_top(8)
        main_box.append(sep2)
        
        # Tab buttons
        tab_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        tab_box.set_halign(Gtk.Align.CENTER)
        tab_box.set_margin_top(16)
        tab_box.set_margin_bottom(16)
        
        tabs = ['Overview', 'Displays', 'Storage', 'Support', 'Performance']
        for i, tab_name in enumerate(tabs):
            btn = Gtk.Button(label=tab_name)
            btn.add_css_class('tab-button')
            if tab_name == 'Overview':
                btn.add_css_class('active')
            btn.connect('clicked', self._on_tab_clicked, btn)
            tab_box.append(btn)
        
        main_box.append(tab_box)
        
        # Separator before buttons
        sep3 = Gtk.Box()
        sep3.add_css_class('separator-line')
        main_box.append(sep3)
        
        # Action buttons
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        button_box.set_halign(Gtk.Align.END)
        button_box.set_margin_top(16)
        button_box.set_margin_bottom(16)
        button_box.set_margin_end(16)
        
        sys_info_btn = Gtk.Button(label='System Info')
        sys_info_btn.add_css_class('action-button')
        sys_info_btn.connect('clicked', self._on_system_info)
        button_box.append(sys_info_btn)
        
        update_btn = Gtk.Button(label='Software Update')
        update_btn.add_css_class('action-button')
        update_btn.connect('clicked', self._on_software_update)
        button_box.append(update_btn)
        
        main_box.append(button_box)
        
    def _on_tab_clicked(self, button, btn):
        # Reset all tabs
        parent = btn.get_parent()
        child = parent.get_first_child()
        while child:
            child.remove_css_class('active')
            child = child.get_next_sibling()
        
        # Set active
        btn.add_css_class('active')
        
    def _on_system_info(self, button):
        try:
            subprocess.Popen(['gnome-control-center', 'info'])
        except:
            subprocess.Popen(['zenity', '--info', '--text=System Info'])
            
    def _on_software_update(self, button):
        try:
            subprocess.Popen(['gnome-software', '--mode=updates'])
        except:
            subprocess.Popen(['zenity', '--info', '--text=Software Update'])

def main():
    app = AboutZephyrus()
    app.run(None)

if __name__ == '__main__':
    main()
