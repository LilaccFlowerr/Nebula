import QtQuick
import QtQuick.Effects
import M3Shapes
import qs.theme

MaterialShape {
    id: root

    property color fill: Colors.surfaceContainerHigh
    property real tint: Theme.glass.tint

    color: Qt.alpha(fill, tint)

    MaterialShape {
        id: mask
        anchors.fill: parent
        shape: root.shape
        animationDuration: root.animationDuration
        animationEasing: root.animationEasing
        color: "black"
        visible: false
        layer.enabled: true
    }

    Item {
        id: light
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 1.5
            height: parent.height * 1.5
            rotation: -root.rotation
            gradient: Gradient {
                GradientStop { position: 0.17; color: Qt.rgba(1, 1, 1, Theme.glass.topLight) }
                GradientStop { position: 0.55; color: Qt.rgba(1, 1, 1, 0) }
            }
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: light
        maskEnabled: true
        maskSource: mask
    }
}
