pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string device: ""
    readonly property bool available: device !== ""

    property real current: parseFloat(brightnessFile.text()) || 0
    property real max: parseFloat(maxFile.text()) || 1
    readonly property real level: available ? current / max : 0
    readonly property int percent: Math.round(level * 100)

    function setBrightness(value) {
        if (!available) return;
        const p = Math.round(Math.max(0.01, Math.min(1, value)) * 100);
        Quickshell.execDetached(["brightnessctl", "-d", device, "set", p + "%"]);
    }

    Process {
        running: true
        command: ["sh", "-c", "ls /sys/class/backlight | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: root.device = text.trim()
        }
    }

    FileView {
        id: brightnessFile
        path: root.available ? "/sys/class/backlight/" + root.device + "/brightness" : ""
        watchChanges: true
        onFileChanged: reload()
    }

    FileView {
        id: maxFile
        path: root.available ? "/sys/class/backlight/" + root.device + "/max_brightness" : ""
    }

    Timer {
        interval: 1000
        running: root.available
        repeat: true
        onTriggered: brightnessFile.reload()
    }
}
