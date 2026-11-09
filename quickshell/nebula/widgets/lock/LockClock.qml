import QtQuick
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property real flash: 0

    Connections {
        target: Lock

        function onFailedAttempt() {
            flashAnim.restart();
        }
    }

    SequentialAnimation {
        id: flashAnim

        NumberAnimation { target: root; property: "flash"; to: 1; duration: 80 }
        NumberAnimation { target: root; property: "flash"; to: 0; duration: 600; easing.type: Easing.OutCubic }
    }

    MaterialShape {
        anchors.fill: parent
        shape: MaterialShape.Cookie12Sided
        color: Qt.tint(Qt.alpha(Colors.primaryContainer, Theme.lock.surfaceTint), Qt.alpha(Colors.errorContainer, root.flash))

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
