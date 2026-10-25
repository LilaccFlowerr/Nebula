pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property string current: ""
    property bool armed: false
    property bool held: false

    readonly property var toggles: ({
        volume: "eventVolume",
        brightness: "eventBrightness",
        charging: "eventCharger",
        unplugged: "eventCharger",
        low: "eventLowBattery"
    })

    function enabled(name) {
        return armed && Settings.bar[toggles[name]] !== false;
    }

    function pop(name, duration = Settings.bar.osdDuration) {
        if (!enabled(name)) return;
        current = name;
        timer.interval = duration;
        if (!held) timer.restart();
    }

    function notify(summary, body, icon, critical = false) {
        Quickshell.execDetached(["notify-send", "-a", "Battery", "-i", icon, "-u", critical ? "critical" : "normal", summary, body]);
    }

    onHeldChanged: {
        if (held) timer.stop();
        else if (current !== "") timer.restart();
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: timer
        onTriggered: root.current = ""
    }

    Connections {
        target: Audio
        function onVolumeChanged() { root.pop("volume"); }
        function onMutedChanged() { root.pop("volume"); }
    }

    Connections {
        target: Brightness
        function onCurrentChanged() { root.pop("brightness"); }
    }

    Connections {
        target: Battery
        function onPluggedInChanged() {
            if (!root.enabled("charging")) return;
            if (Battery.pluggedIn) root.notify("Charging", Battery.percent + "%", "battery-good-charging");
            else root.notify("On battery", Battery.percent + "%", "battery-good");
        }
        function onLowChanged() {
            if (Battery.low && root.enabled("low")) root.notify("Battery low", Battery.percent + "% left, plug in soon", "battery-caution", true);
        }
    }
}
