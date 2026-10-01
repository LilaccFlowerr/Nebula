import QtQuick
import qs.theme

Rectangle {
    id: root

    property bool checked: false

    signal toggled()

    implicitWidth: 52
    implicitHeight: 32
    radius: height / 2
    color: checked ? Colors.primary : Colors.surfaceContainerHighest
    border.width: checked ? 0 : 2
    border.color: Colors.outline

    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }

    Rectangle {
        property real size: mouse.pressed ? 28 : root.checked ? 24 : 16
        width: size
        height: size
        radius: size / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - width - 4 : (root.height - width) / 2
        color: root.checked ? Colors.textOnPrimary : Colors.outline

        Behavior on x {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on size {
            NumberAnimation { duration: Theme.anim.fast }
        }
        Behavior on color {
            ColorAnimation { duration: Theme.anim.fast }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
