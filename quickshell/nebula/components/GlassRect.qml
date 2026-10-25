import QtQuick
import qs.theme

Rectangle {
    id: root

    property color fill: Colors.surfaceContainerHigh
    property real tint: Theme.glass.tint
    property real light: Theme.glass.topLight

    color: Qt.alpha(fill, tint)

    Rectangle {
        anchors.fill: parent
        visible: root.light > 0
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, root.light) }
            GradientStop { position: 0.58; color: Qt.rgba(1, 1, 1, 0) }
        }
    }
}
