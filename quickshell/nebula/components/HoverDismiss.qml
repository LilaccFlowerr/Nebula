import QtQuick
import qs.theme

Timer {
    id: root

    property bool active: false
    property bool hovered: false
    property bool touched: false

    signal dismissed()

    interval: Theme.bar.popupLeaveDelay
    running: active && touched && !hovered
    onActiveChanged: touched = active && hovered
    onHoveredChanged: if (hovered && active) touched = true
    onTriggered: dismissed()
}
