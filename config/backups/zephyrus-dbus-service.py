#!/usr/bin/env python3
"""
Zephyrus DBus Service
Provides DBus interface for ASUS profile cycling.
Can be activated by kglobalaccel shortcuts.
"""
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib
import subprocess
import os

class ZephyrusService(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName('org.zephyrusos.ProfileService', bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, '/ProfileService')
        print("Zephyrus DBus Service started")
    
    @dbus.service.method('org.zephyrusos.ProfileService', in_signature='', out_signature='s')
    def CycleProfile(self):
        """Cycle to next performance profile"""
        try:
            result = subprocess.run(
                ['/home/solarious/.local/bin/asus-profile-cycle'],
                capture_output=True, text=True, timeout=10
            )
            output = result.stdout.strip() if result.stdout else "Profile cycled"
            print(f"CycleProfile called: {output}")
            return output
        except Exception as e:
            print(f"CycleProfile error: {e}")
            return f"Error: {e}"
    
    @dbus.service.method('org.zephyrusos.ProfileService', in_signature='s', out_signature='s')
    def SetProfile(self, profile):
        """Set specific profile (Quiet, Balanced, Performance)"""
        try:
            result = subprocess.run(
                ['/home/solarious/.local/bin/zephyrus-profile-enhanced', profile.lower()],
                capture_output=True, text=True, timeout=10
            )
            return result.stdout.strip() if result.stdout else f"Profile set to {profile}"
        except Exception as e:
            return f"Error: {e}"

if __name__ == '__main__':
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    service = ZephyrusService()
    GLib.MainLoop().run()
