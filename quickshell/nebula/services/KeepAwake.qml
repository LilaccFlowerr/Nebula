pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool enabled: false
    readonly property string icon: enabled ? "coffee" : "bedtime"

    function toggle() {
        enabled = !enabled;
    }
}
