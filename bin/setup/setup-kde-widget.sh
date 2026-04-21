#!/bin/bash
# Setup KDE Panel Widget for ROG Monitoring

echo "Setting up KDE Panel Widget for ROG Monitor..."

# Create widget directory
mkdir -p ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/contents/ui
mkdir -p ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/contents/config

# Create metadata
 cat > ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/metadata.json << 'JSON'
{
    "KPackageStructure": "Plasma/Applet",
    "KPlugin": {
        "Authors": [{"Name": "Zephyrus User"}],
        "Category": "System Information",
        "Description": "ROG Zephyrus Thermal Monitor",
        "Icon": "preferences-system-performance",
        "Id": "com.zephyrus.monitor",
        "License": "GPL-2.0+",
        "Name": "ROG Monitor",
        "Version": "1.0",
        "Website": ""
    },
    "X-Plasma-API-Minimum-Version": "6.0"
}
JSON

# Create main widget UI
cat > ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/contents/ui/main.qml << 'QML'
import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: root
    
    // Compact representation (panel icon)
    compactRepresentation: Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        
        Row {
            anchors.centerIn: parent
            spacing: 4
            
            Kirigami.Icon {
                source: "preferences-system-performance"
                width: Kirigami.Units.iconSizes.small
                height: width
                color: {
                    if (cpuTemp > 85) return "#ff4444"
                    if (cpuTemp > 70) return "#ffaa00"
                    return Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.2)
                }
            }
            
            Text {
                text: cpuTemp + "°C"
                font.pixelSize: Kirigami.Units.gridUnit * 0.9
                color: {
                    if (cpuTemp > 85) return "#ff4444"
                    if (cpuTemp > 70) return "#ffaa00"
                    return Kirigami.Theme.textColor
                }
                visible: plasmoid.configuration.showTemp
            }
        }
    }
    
    // Full representation (popup when clicked)
    fullRepresentation: Item {
        Layout.preferredWidth: 280
        Layout.preferredHeight: 200
        
        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            
            // Header
            Row {
                spacing: 8
                Kirigami.Icon {
                    source: "preferences-system-performance"
                    width: 24
                    height: 24
                }
                Text {
                    text: "ROG Zephyrus G16"
                    font.bold: true
                    font.pixelSize: 14
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.8)
            }
            
            // CPU Section
            Column {
                width: parent.width
                spacing: 4
                
                Text {
                    text: "CPU"
                    font.bold: true
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.3)
                }
                
                Row {
                    width: parent.width
                    Text {
                        text: "Temperature: " + cpuTemp + "°C"
                        color: {
                            if (cpuTemp > 85) return "#ff4444"
                            if (cpuTemp > 70) return "#ffaa00"
                            return "#44ff44"
                        }
                    }
                }
                
                Row {
                    width: parent.width
                    Text {
                        text: "Power: " + powerLimit + "W"
                    }
                }
            }
            
            // GPU Section
            Column {
                width: parent.width
                spacing: 4
                
                Text {
                    text: "GPU RTX 4090"
                    font.bold: true
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.3)
                }
                
                Row {
                    width: parent.width
                    Text {
                        text: "Temperature: " + gpuTemp + "°C"
                        color: {
                            if (gpuTemp > 80) return "#ff4444"
                            if (gpuTemp > 65) return "#ffaa00"
                            return "#44ff44"
                        }
                    }
                }
                
                Row {
                    width: parent.width
                    Text {
                        text: "Power: " + gpuPower + "W / " + gpuTgp + "W"
                    }
                }
                
                Row {
                    width: parent.width
                    Text {
                        text: "Utilization: " + gpuUtil + "%"
                    }
                }
            }
            
            // Fans
            Row {
                width: parent.width
                Text {
                    text: "Fans: " + fan1 + " / " + fan2 + " RPM"
                    font.pixelSize: 11
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.textColor, Kirigami.Theme.backgroundColor, 0.8)
            }
            
            // Mode switcher
            Row {
                spacing: 4
                
                Button {
                    text: "🔇"
                    onClicked: executable.exec("zephyrus-profile quiet")
                    ToolTip.text: "Silent"
                }
                Button {
                    text: "⚖️"
                    onClicked: executable.exec("zephyrus-profile balanced")
                    ToolTip.text: "Balanced"
                }
                Button {
                    text: "🚀"
                    onClicked: executable.exec("zephyrus-profile performance")
                    ToolTip.text: "Performance"
                }
            }
        }
    }
    
    // Data sources
    property int cpuTemp: 0
    property int gpuTemp: 0
    property real gpuPower: 0
    property int gpuUtil: 0
    property int powerLimit: 45
    property int gpuTgp: 60
    property int fan1: 0
    property int fan2: 0
    
    // Update timer
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: updateData()
    }
    
    // Data sources
    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            
            if (exitCode === 0 && stdout) {
                parseData(stdout)
            }
        }
        
        function exec(cmd) {
            connectSource(cmd)
        }
    }
    
    // Update function
    function updateData() {
        executable.exec("bash -c 'echo $(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | grep -E ^[89] | head -1 | awk \"{print int(/1000)}\")|$(nvidia-smi --query-gpu=temperature.gpu,power.draw,utilization.gpu --format=csv,noheader 2>/dev/null | tr -d \" %\")|$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)|$(cat /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value 2>/dev/null)|$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -1)|$(cat /sys/class/hwmon/hwmon*/fan2_input 2>/dev/null | head -1)'"")
    }
    
    function parseData(data) {
        var parts = data.trim().split("|")
        if (parts.length >= 6) {
            cpuTemp = parseInt(parts[0]) || 0
            var gpuParts = parts[1].split(",")
            gpuTemp = parseInt(gpuParts[0]) || 0
            gpuPower = parseFloat(gpuParts[1]) || 0
            gpuUtil = parseInt(gpuParts[2]) || 0
            powerLimit = parseInt(parts[2]) || 45
            gpuTgp = parseInt(parts[3]) || 60
            fan1 = parseInt(parts[4]) || 0
            fan2 = parseInt(parts[5]) || 0
        }
    }
    
    // Initial update
    Component.onCompleted: updateData()
}
QML

# Create default config
cat > ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/contents/config/main.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<kcfg xmlns="http://www.kde.org/standards/kcfg/1.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.kde.org/standards/kcfg/1.0
      http://www.kde.org/standards/kcfg/1.0/kcfg.xsd" >
    <kcfgfile name=""/>
    <group name="General">
        <entry name="showTemp" type="Bool">
            <default>true</default>
        </entry>
        <entry name="updateInterval" type="Int">
            <default>2000</default>
        </entry>
    </group>
</kcfg>
XML

echo "✓ KDE Widget created at:"
echo "  ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/"
echo ""
echo "To add to panel:"
echo "1. Right-click on desktop panel → Add Widgets"
echo "2. Search for 'ROG Monitor'"
echo "3. Drag to panel"
echo ""
echo "Or install via command:"
echo "  kpackagetool6 --install ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/ 2>/dev/null || kpackagetool6 --upgrade ~/.local/share/plasma/plasmoids/com.zephyrus.monitor/"
