import QtQuick
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    MaterialShape {
        anchors.fill: parent
        shape: MaterialShape.Cookie12Sided
        color: Qt.alpha(Colors.primaryContainer, Theme.lock.surfaceTint)

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 50000
            loops: Animation.Infinite
            running: root.visible
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.time
            font.family: Theme.font.family
            font.pixelSize: root.width * 0.24
            font.weight: Font.Medium
            color: Colors.textOnPrimaryContainer
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.date
            font.family: Theme.font.family
            font.pixelSize: root.width * 0.065
            color: Qt.alpha(Colors.textOnPrimaryContainer, 0.75)
        }
    }
}
