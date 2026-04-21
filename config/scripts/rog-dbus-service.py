#!/usr/bin/env python3
"""
ROG Thermal Monitor DBus Service for KDE Plasma 6
Provides temperature data via DBus for the widget
"""

import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import subprocess
import threading
import time

DBusGMainLoop(set_as_default=True)

BUS_NAME = 'com.rog.thermalmonitor'
OBJECT_PATH = '/com/rog/thermalmonitor'
INTERFACE = 'com.rog.thermalmonitor.Interface'

class ThermalMonitorService(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName(BUS_NAME, bus=dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, OBJECT_PATH)
        
        self._data = {
            'cpuTemp': 0,
            'gpuTemp': 0,
            'gpuPower': 0.0,
            'gpuUtil': 0,
            'powerLimit': 45,
            'gpuTgp': 60,
            'fan1': 0,
            'fan2': 0
        }
        
        # Start updater thread
        self._running = True
        self._thread = threading.Thread(target=self._update_loop)
        self._thread.daemon = True
        self._thread.start()
        
        print("ROG Thermal DBus Service started")
        print(f"Bus: {BUS_NAME}")
    
    def _update_loop(self):
        """Continuously update temperature data"""
        while self._running:
            try:
                result = subprocess.run(
                    ['/home/solarious/.local/bin/zephyrus-profile-helper'],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if result.returncode == 0:
                    self._parse_data(result.stdout.strip())
            except Exception as e:
                print(f"Update error: {e}")
            
            time.sleep(2)
    
    def _parse_data(self, data):
        """Parse helper output"""
        try:
            parts = data.split('|')
            if len(parts) >= 6:
                self._data['cpuTemp'] = int(parts[0]) if parts[0] else 0
                gpu_parts = parts[1].split(',')
                self._data['gpuTemp'] = int(gpu_parts[0]) if gpu_parts[0] else 0
                self._data['gpuPower'] = float(gpu_parts[1]) if len(gpu_parts) > 1 and gpu_parts[1] else 0.0
                self._data['gpuUtil'] = int(gpu_parts[2]) if len(gpu_parts) > 2 and gpu_parts[2] else 0
                self._data['powerLimit'] = int(parts[2]) if parts[2] else 45
                self._data['gpuTgp'] = int(parts[3]) if parts[3] else 60
                self._data['fan1'] = int(parts[4]) if parts[4] else 0
                self._data['fan2'] = int(parts[5]) if parts[5] else 0
                
                # Emit signal that data changed
                self.DataChanged()
        except Exception as e:
            print(f"Parse error: {e}")
    
    @dbus.service.method(INTERFACE, out_signature='a{sv}')
    def GetData(self):
        """Get current thermal data"""
        return self._data
    
    @dbus.service.method(INTERFACE, out_signature='i')
    def GetCpuTemp(self):
        return self._data['cpuTemp']
    
    @dbus.service.method(INTERFACE, out_signature='i')
    def GetGpuTemp(self):
        return self._data['gpuTemp']
    
    @dbus.service.method(INTERFACE, out_signature='i')
    def GetPowerLimit(self):
        return self._data['powerLimit']
    
    @dbus.service.signal(INTERFACE, signature='')
    def DataChanged(self):
        """Signal emitted when data updates"""
        pass
    
    def stop(self):
        self._running = False

def main():
    service = ThermalMonitorService()
    
    try:
        GLib.MainLoop().run()
    except KeyboardInterrupt:
        print("\nShutting down...")
        service.stop()

if __name__ == '__main__':
    main()
