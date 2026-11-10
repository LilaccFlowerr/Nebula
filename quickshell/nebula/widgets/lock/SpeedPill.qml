import QtQuick
import qs.theme

Rectangle {
    id: pill

    property string arrow: ""
    property color accent: Colors.tertiary
    property string text: ""

    height: 26
    radius: 13
    color: Qt.alpha(Colors.surfaceContainerHighest, 0.6)

    Rectangle {
        x: 3
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20
        radius: 10
        color: Qt.alpha(parent.accent, 0.2)

        Text {
            anchors.centerIn: parent
            text: parent.parent.arrow
            font.family: Theme.font.icons
            font.pixelSize: 12
            color: parent.parent.accent
        }
    }

    Text {
        x: 30
        anchors.verticalCenter: parent.verticalCenter
        text: parent.text
        font.family: Theme.font.family
        font.pixelSize: 12
        font.weight: Font.DemiBold
        color: Colors.textOnSurface
    }
}
