pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled: false
    readonly property string icon: enabled ? "do_not_disturb_on" : "do_not_disturb_off"

    function toggle() {
        toggleProc.running = true;
    }

    Process {
        id: toggleProc
        command: ["makoctl", "mode", "-t", "do-not-disturb"]
        onExited: readProc.running = true
    }

    Process {
        id: readProc
        running: true
        command: ["makoctl", "mode"]
        stdout: StdioCollector {
            onStreamFinished: root.enabled = text.split("\n").includes("do-not-disturb")
        }
    }
}
