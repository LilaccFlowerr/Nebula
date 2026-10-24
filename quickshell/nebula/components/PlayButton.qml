import QtQuick
import M3Shapes
import qs.theme

Item {
    id: root

    property bool playing: false
    property real size: Theme.button.playSize
    property real iconSize: Theme.button.playIconSize
    property color color: Colors.primaryContainer
    property color hoverColor: Colors.primary
    property color iconColor: Colors.textOnPrimaryContainer
    property color hoverIconColor: Colors.textOnPrimary

    signal clicked()

    implicitWidth: size
    implicitHeight: size
    scale: mouse.pressed ? 0.9 : mouse.containsMouse ? 1.05 : 1

    Behavior on scale {
        NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    MaterialShape {
        anchors.fill: parent
        implicitSize: parent.width
        shape: root.playing ? MaterialShape.Cookie9Sided : MaterialShape.Pentagon
        color: mouse.containsMouse ? root.hoverColor : root.color
        animationDuration: Theme.anim.slow

        Behavior on color {
            ColorAnimation { duration: Theme.anim.fast }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.playing ? "pause" : "play_arrow"
        font.family: Theme.font.icons
        font.pixelSize: root.iconSize
        color: mouse.containsMouse ? root.hoverIconColor : root.iconColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
