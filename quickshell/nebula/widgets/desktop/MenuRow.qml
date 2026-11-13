import QtQuick
import QtQuick.Layouts
import qs.theme

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property string trailing: ""
    property bool accent: false

    signal clicked()
    signal rightClicked()

    Layout.fillWidth: true
    implicitHeight: Theme.tray.menuRowHeight
    radius: Theme.radius.medium
    color: accent ? Colors.primaryContainer
        : mouse.containsMouse ? Colors.surfaceContainerHighest
        : Colors.surfaceContainerHigh

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md
        anchors.rightMargin: Theme.spacing.md
        spacing: Theme.spacing.sm

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.font.icons
            font.pixelSize: Theme.settings.iconSize
            color: root.accent ? Colors.textOnPrimaryContainer : Colors.primary
        }

        Text {
            Layout.fillWidth: true
            text: root.text
            elide: Text.ElideRight
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: root.accent ? Colors.textOnPrimaryContainer : Colors.textOnSurface
        }

        Text {
            visible: root.trailing !== ""
            text: root.trailing
            font.family: Theme.font.icons
            font.pixelSize: Theme.settings.iconSize
            color: root.accent ? Colors.textOnPrimaryContainer : Colors.textOnSurfaceVariant
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => event.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    }
}
