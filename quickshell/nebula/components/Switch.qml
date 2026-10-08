import QtQuick
import qs.theme

Rectangle {
    id: root

    property bool checked: false
    property real position: checked ? 1 : 0

    signal toggled()

    implicitWidth: 52
    implicitHeight: 32
    radius: height / 2
    color: checked ? Colors.primary : Colors.surfaceContainerHighest
    border.width: 2
    border.color: checked ? Colors.primary : Colors.outline

    Behavior on position {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
    }

    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }

    Behavior on border.color {
        ColorAnimation { duration: Theme.anim.fast }
    }

    Rectangle {
        readonly property real start: root.height / 2
        readonly property real end: root.width - root.height / 2
        property real size: mouse.pressed ? 28 : root.checked ? 24 : 16

        width: size
        height: size
        radius: size / 2
        anchors.verticalCenter: parent.verticalCenter
        x: start + (end - start) * root.position - width / 2
        color: root.checked ? Colors.textOnPrimary : Colors.outline

        Behavior on size {
            NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
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
