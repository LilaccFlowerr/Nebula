import QtQuick
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    readonly property var now: Weather.current
    readonly property var look: now ? Weather.describe(now.code, now.day) : null

    MaterialShape {
        anchors.fill: parent
        shape: root.look ? root.look.shape : MaterialShape.Cookie9Sided
        color: Qt.alpha(Colors.tertiaryContainer, Theme.lock.surfaceTint)
        animationDuration: Theme.anim.slow

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 70000
            loops: Animation.Infinite
            running: root.visible
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.look ? root.look.icon : ""
            font.family: Theme.font.icons
            font.pixelSize: root.width * 0.22
            color: Colors.textOnTertiaryContainer
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.now ? root.now.temp + "°" : ""
            font.family: Theme.font.family
            font.pixelSize: root.width * 0.24
            font.weight: Font.Medium
            color: Colors.textOnTertiaryContainer
        }
    }
}
