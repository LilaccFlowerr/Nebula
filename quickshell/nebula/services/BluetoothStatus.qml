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

    function toggle() {
        if (adapter) adapter.enabled = !adapter.enabled;
    }
}
