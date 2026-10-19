pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var all: [
        { key: "wifi", title: "Wifi", icon: "wifi" },
        { key: "bluetooth", title: "Bluetooth", icon: "bluetooth" },
        { key: "dnd", title: "Do not disturb", icon: "do_not_disturb_on" },
        { key: "darkMode", title: "Dark mode", icon: "dark_mode" },
        { key: "record", title: "Record", icon: "screen_record" },
        { key: "screenshot", title: "Screenshot", icon: "screenshot_region" },
        { key: "powerMode", title: "Power mode", icon: "balance" },
        { key: "keepAwake", title: "Keep awake", icon: "coffee" },
        { key: "mic", title: "Microphone", icon: "mic" }
    ]
    readonly property var keys: Settings.quickSettings.tiles.split(",").filter(k => all.some(t => t.key === k))

    function info(key) {
        return all.find(t => t.key === key) ?? null;
    }

    function available(key) {
        if (key === "wifi") return Wifi.available;
        if (key === "bluetooth") return BluetoothStatus.available;
        if (key === "mic") return Audio.micReady;
        return true;
    }

    function save(list) {
        Settings.quickSettings.tiles = list.join(",");
    }
}
