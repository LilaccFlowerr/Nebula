import QtQuick
import qs.theme

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property bool danger: false
    property bool filled: false

    readonly property color fg: filled ? (danger ? Colors.textOnErrorContainer : Colors.textOnSecondaryContainer) : (danger ? Colors.errorColor : Colors.primary)

    signal clicked()

    implicitWidth: row.implicitWidth + Theme.spacing.lg * 2
    implicitHeight: Theme.button.size
    radius: height / 2
    color: filled ? (danger ? Colors.errorContainer : Colors.secondaryContainer) : "transparent"
    border.width: filled ? 0 : 1
    border.color: Colors.outlineVariant

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.fg
        opacity: mouse.pressed ? 0.12 : mouse.containsMouse ? 0.08 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing.sm

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.font.icons
            font.pixelSize: Theme.button.iconSize - 2
            color: root.fg
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            font.weight: Font.DemiBold
            color: root.fg
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
