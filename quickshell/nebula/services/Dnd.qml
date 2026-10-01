pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool enabled: Settings.notifications.doNotDisturb
    readonly property string icon: enabled ? "do_not_disturb_on" : "do_not_disturb_off"

    function toggle() {
        Settings.notifications.doNotDisturb = !enabled;
    }
}
