pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string device: ""
    property string state: ""
    property string connection: ""
    property string address: ""
    property string ip: ""
    property string speed: ""

    readonly property bool available: device !== ""
    readonly property bool connected: state === "connected"
    readonly property bool unplugged: state === "unavailable"
    readonly property string status: connected ? "Connected" : unplugged ? "No cable plugged in" : state === "connecting" ? "Connecting" : "Disconnected"
    readonly property string icon: connected ? "settings_ethernet" : "lan"

    function refresh() {
        list.running = true;
    }

    function connect() {
        action.command = ["nmcli", "device", "connect", device];
        action.running = true;
    }

    function disconnect() {
        action.command = ["nmcli", "device", "disconnect", device];
        action.running = true;
    }

    Process {
        id: list
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n").find(l => l.split(":")[1] === "ethernet") ?? "";
                const parts = line.split(":");
                root.device = parts[0] ?? "";
                root.state = (parts[2] ?? "").split(" ")[0];
                root.connection = parts[3] ?? "";
                if (root.device) details.running = true;
            }
        }
    }

    Process {
        id: details
        command: ["nmcli", "-t", "-g", "GENERAL.HWADDR,IP4.ADDRESS,CAPABILITIES.SPEED", "device", "show", root.device]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                root.address = (lines[0] ?? "").replace(/\\:/g, ":");
                root.ip = (lines[1] ?? "").split(" | ")[0];
                root.speed = lines[2] ?? "";
            }
        }
    }

    Process {
        id: action
        onExited: root.refresh()
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: refreshTimer.restart()
        }
    }

    Timer {
        id: refreshTimer
        interval: 300
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
