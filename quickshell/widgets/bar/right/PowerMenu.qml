import QtQuick
import QtQuick.Layouts
import qs.services
import qs.theme

Rectangle {
    id: root

    property bool open: false
    signal requestClose()

    component MenuItem: Rectangle {
        id: item

        property string icon: ""
        property string label: ""
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: Theme.button.size
        radius: Theme.radius.full
        color: mouse.containsMouse ? Colors.surfaceContainerHigh : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.md
            anchors.rightMargin: Theme.spacing.md
            spacing: Theme.spacing.md

            Text {
                text: item.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: Colors.textOnSurface
            }

            Text {
                Layout.fillWidth: true
                text: item.label
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Colors.textOnSurface
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: item.clicked()
        }
    }

    implicitWidth: 200
    implicitHeight: column.implicitHeight + Theme.spacing.sm * 2
    radius: Theme.bar.radius
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.85
    transformOrigin: Item.TopRight

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }
    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.sm
        spacing: 2

        MenuItem { icon: "lock";               label: "Lock";      onClicked: { root.requestClose(); Power.lock() } }
        MenuItem { icon: "bedtime";            label: "Sleep";     onClicked: { root.requestClose(); Power.suspend() } }
        MenuItem { icon: "logout";             label: "Log out";   onClicked: { root.requestClose(); Power.logout() } }
        MenuItem { icon: "restart_alt";        label: "Restart";   onClicked: { root.requestClose(); Power.reboot() } }
        MenuItem { icon: "power_settings_new"; label: "Shut down"; onClicked: { root.requestClose(); Power.shutdown() } }
    }
}
