pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool enabled: false
    readonly property string icon: enabled ? "do_not_disturb_on" : "do_not_disturb_off"

    function toggle() {
        enabled = !enabled;
    }
}
