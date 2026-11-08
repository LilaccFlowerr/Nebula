import QtQuick
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    required property var entry

    GlassRect {
        anchors.fill: parent
        radius: height / 2
        fill: Colors.secondaryContainer
        tint: Theme.lock.surfaceTint
        light: 0
    }

    ShapedArt {
        id: icon

        x: root.height * 0.16
        anchors.verticalCenter: parent.verticalCenter
        width: root.height * 0.68
        height: width
        shape: MaterialShape.Cookie6Sided
        color: Colors.secondary
        source: Notifications.iconFor(root.entry.data)
        sourceSize: Qt.size(width * 2, height * 2)
    }

    Column {
        anchors.left: icon.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.entry.name + (root.entry.count > 1 ? "  ·  " + root.entry.count : "")
            font.family: Theme.font.family
            font.pixelSize: Theme.font.large
            font.weight: Font.Medium
            color: Colors.textOnSecondaryContainer
        }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: root.entry.items[0].summary
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: Qt.alpha(Colors.textOnSecondaryContainer, 0.7)
        }
    }
}
