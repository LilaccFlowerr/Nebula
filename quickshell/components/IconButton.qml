import QtQuick
import qs.theme

Rectangle {
    id: root


    property string icon: ""


    signal clicked()

    implicitWidth: Theme.button.size
    implicitHeight: Theme.button.size
    radius: Theme.radius.full
  color: mouse.pressed ? Colors.surfaceContainerHighest
     : mouse.containsMouse ? Colors.surfaceContainerHigh
     : Colors.surfaceContainer

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.font.icons
        font.pixelSize: Theme.button.iconSize
        color: Colors.textOnSurface
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}