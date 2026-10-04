pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property var device: adapter ? adapter.devices.values.find(d => d.connected) ?? null : null
    readonly property bool connected: device !== null
    readonly property string deviceName: device ? device.name : ""
    readonly property string icon: !enabled ? "bluetooth_disabled" : connected ? "bluetooth_connected" : "bluetooth"

    readonly property var devices: adapter ? adapter.devices.values : []
    readonly property var paired: devices.filter(d => d.paired || d.bonded)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    readonly property var nearby: devices.filter(d => !d.paired && !d.bonded && d.deviceName)
        .sort((a, b) => a.name.localeCompare(b.name))
    readonly property bool scanning: adapter ? adapter.discovering : false

    function toggle() {
        if (adapter) adapter.enabled = !adapter.enabled;
    }

    function scan(on) {
        if (adapter && adapter.enabled) adapter.discovering = on;
    }

    function activate(d) {
        if (d.connected) d.disconnect();
        else d.connect();
    }

    function pair(d) {
        d.trusted = true;
        d.pair();
    }

    function iconFor(d) {
        const i = d.icon ?? "";
        return i.includes("headset") || i.includes("headphone") ? "headphones"
             : i.includes("audio") ? "speaker"
             : i.includes("phone") ? "smartphone"
             : i.includes("mouse") ? "mouse"
             : i.includes("keyboard") ? "keyboard"
             : i.includes("computer") ? "computer"
             : i.includes("game") ? "sports_esports"
             : "bluetooth";
    }
}
