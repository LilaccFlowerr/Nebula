import QtQuick
import QtQuick.Layouts
import qs.theme

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool clickable: false
    default property alias control: slot.data

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: Theme.settings.rowHeight
    radius: Theme.radius.small
    color: mouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.04) : "transparent"

    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.clickable
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.lg + Theme.spacing.xs
        anchors.rightMargin: Theme.spacing.lg + Theme.spacing.xs
        spacing: Theme.spacing.lg

        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.font.icons
            font.pixelSize: Theme.settings.iconSize
            color: Colors.textOnSurfaceVariant
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                font.weight: Font.Medium
                color: Colors.textOnSurface
            }

            Text {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
                color: Colors.textOnSurfaceVariant
            }
        }

        Row {
            id: slot
            Layout.alignment: Qt.AlignVCenter
            spacing: Theme.spacing.sm
        }
    }
}
