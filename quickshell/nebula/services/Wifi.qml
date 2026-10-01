pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property bool available: device !== null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property var network: device ? device.networks.values.find(n => n.connected) ?? null : null
    readonly property bool connected: network !== null
    readonly property string ssid: network ? network.name : ""
    readonly property string icon: !enabled ? "wifi_off" : connected ? "wifi" : "wifi_find"

    function toggle() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
}
