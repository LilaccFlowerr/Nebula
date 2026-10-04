import QtQuick
import QtQuick.Layouts
import qs.theme

ColumnLayout {
    id: root

    property string title: ""
    default property alias rows: list.data

    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    Text {
        visible: root.title !== ""
        Layout.leftMargin: Theme.spacing.lg + Theme.spacing.xs
        text: root.title
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        font.weight: Font.DemiBold
        color: Colors.primary
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: list.implicitHeight + Theme.spacing.xs * 2
        radius: Theme.radius.large
        color: Colors.surfaceContainerHigh

        ColumnLayout {
            id: list
            anchors.fill: parent
            anchors.margins: Theme.spacing.xs
            spacing: 0
        }
    }
}
