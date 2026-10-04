pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property bool available: device !== null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property var network: device ? device.networks.values.find(n => n.connected) ?? null : null
    readonly property bool connected: network !== null
    readonly property string ssid: network ? network.name : ""
    readonly property string icon: !enabled ? "wifi_off" : connected ? strengthIcon(network) : "wifi_find"

    readonly property var networks: {
        if (!device) return [];
        const best = {};
        for (const n of device.networks.values) {
            if (!n.name) continue;
            const current = best[n.name];
            if (!current || n.connected || (!current.connected && n.signalStrength > current.signalStrength)) best[n.name] = n;
        }
        return Object.values(best).sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength));
    }

    property bool scanning: false
    property string pending: ""
    property string error: ""

    Binding {
        when: root.device !== null
        target: root.device
        property: "scannerEnabled"
        value: root.scanning && root.enabled
    }

    function toggle() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function strength(n) {
        const s = n?.signalStrength ?? 0;
        return s > 1 ? s / 100 : s;
    }

    function strengthIcon(n) {
        const s = strength(n);
        return s > 0.75 ? "signal_wifi_4_bar" : s > 0.5 ? "network_wifi_3_bar" : s > 0.25 ? "network_wifi_2_bar" : "network_wifi_1_bar";
    }

    function secured(n) {
        return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe;
    }

    function needsPassword(n) {
        return !n.known && secured(n);
    }

    function connect(n, password = "") {
        error = "";
        if (!needsPassword(n)) {
            n.connect();
            return;
        }
        pending = n.name;
        nmcli.command = ["nmcli", "device", "wifi", "connect", n.name, "password", password, "ifname", device.name];
        nmcli.running = true;
    }

    function disconnect() {
        network?.disconnect();
    }

    function forget(n) {
        n.forget();
    }

    Process {
        id: nmcli
        stderr: StdioCollector {
            onStreamFinished: root.error = text.trim().replace(/^Error: /, "")
        }
        onExited: code => {
            if (code === 0) root.error = "";
            root.pending = "";
        }
    }
}
