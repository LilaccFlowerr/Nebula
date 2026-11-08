import QtQuick
import M3Shapes
import qs.services
import qs.theme

MaterialShape {
    id: root

    property var app
    property int index: 0
    property bool showCount: true
    readonly property string icon: Notifications.iconFor(app.data)
    readonly property var tone: [
        { fill: Colors.primaryContainer, text: Colors.textOnPrimaryContainer },
        { fill: Colors.tertiaryContainer, text: Colors.textOnTertiaryContainer },
        { fill: Colors.secondaryContainer, text: Colors.textOnSecondaryContainer }
    ][index % 3]

    shape: Dock.shapeFor(app.name)
    color: tone.fill

    Item {
        anchors.fill: parent
        rotation: -root.rotation

        Image {
            anchors.centerIn: parent
            width: root.width * 0.5
            height: width
            sourceSize: Qt.size(64, 64)
            source: root.icon
            visible: root.icon !== ""
        }

        Text {
            anchors.centerIn: parent
            visible: root.icon === ""
            text: "notifications"
            font.family: Theme.font.icons
            font.pixelSize: root.width * 0.42
            color: root.tone.text
        }

        Rectangle {
            visible: root.showCount && root.app.count > 1
            x: parent.width * 0.8 - width / 2
            y: parent.height * 0.08 - height / 2
            width: Math.max(20, countText.implicitWidth + 10)
            height: 20
            radius: height / 2
            color: Colors.primary

            Text {
                id: countText
                anchors.centerIn: parent
                text: root.app.count
                color: Colors.textOnPrimary
                font.family: Theme.font.family
                font.pixelSize: 11
                font.weight: 700
            }
        }
    }
}
