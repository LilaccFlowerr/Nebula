import QtQuick
import Quickshell.Wayland
import qs.theme

WlSessionLockSurface {
    id: root

    color: Theme.lock.space

    LockScene {
        anchors.fill: parent
    }
}
