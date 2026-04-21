#!/usr/bin/env python3
"""
Zephyrus Global Menu Service
Central service that collects and serves application menus
"""

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import json
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('zephyrus-menu')

# D-Bus interface definition
BUS_NAME = 'org.zephyrus.MenuService'
OBJECT_PATH = '/org/zephyrus/MenuService'
INTERFACE = 'org.zephyrus.MenuInterface'

class MenuService(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName(BUS_NAME, bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, OBJECT_PATH)
        self.menus = {}  # Store menus by app ID
        self.active_app = None
        logger.info("Zephyrus Menu Service started")
    
    @dbus.service.method(INTERFACE, in_signature='ss', out_signature='')
    def RegisterMenu(self, app_id, menu_json):
        """Register a menu from an application"""
        try:
            menu_data = json.loads(menu_json)
            self.menus[app_id] = menu_data
            logger.info(f"Registered menu for {app_id}")
            
            # Notify listeners
            self.MenuChanged(app_id)
            
        except Exception as e:
            logger.error(f"Error registering menu: {e}")
    
    @dbus.service.method(INTERFACE, in_signature='s', out_signature='')
    def UnregisterMenu(self, app_id):
        """Unregister a menu when app closes"""
        if app_id in self.menus:
            del self.menus[app_id]
            logger.info(f"Unregistered menu for {app_id}")
    
    @dbus.service.method(INTERFACE, in_signature='s', out_signature='s')
    def GetMenu(self, app_id):
        """Get menu for an application"""
        if app_id in self.menus:
            return json.dumps(self.menus[app_id])
        return "{}"
    
    @dbus.service.method(INTERFACE, in_signature='', out_signature='as')
    def GetApps(self):
        """Get list of apps with menus"""
        return list(self.menus.keys())
    
    @dbus.service.method(INTERFACE, in_signature='s', out_signature='')
    def SetActiveApp(self, app_id):
        """Set the currently focused app"""
        self.active_app = app_id
        logger.info(f"Active app: {app_id}")
        self.ActiveAppChanged(app_id)
    
    @dbus.service.method(INTERFACE, in_signature='ss', out_signature='')
    def ActivateMenuItem(self, app_id, item_path):
        """Activate a menu item"""
        logger.info(f"Activating {item_path} for {app_id}")
        # Send signal to app
        self.ItemActivated(app_id, item_path)
    
    # Signals
    @dbus.service.signal(INTERFACE, signature='s')
    def MenuChanged(self, app_id):
        """Signal: menu changed for app"""
        pass
    
    @dbus.service.signal(INTERFACE, signature='s')
    def ActiveAppChanged(self, app_id):
        """Signal: active app changed"""
        pass
    
    @dbus.service.signal(INTERFACE, signature='ss')
    def ItemActivated(self, app_id, item_path):
        """Signal: menu item activated"""
        pass

def main():
    DBusGMainLoop(set_as_default=True)
    service = MenuService()
    
    logger.info("Zephyrus Menu Service running...")
    logger.info(f"D-Bus name: {BUS_NAME}")
    
    GLib.MainLoop().run()

if __name__ == '__main__':
    main()
