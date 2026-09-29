import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

RowLayout {
    id: notif
    spacing: Theme.spacing.md

    property var n: null
    property bool open: false
    readonly property real artX: notifIcon.x + notifArtSlot.x
    readonly property real artY: notifIcon.y + notifArtSlot.y
    readonly property alias artSlot: notifArtSlot
    readonly property string iconSource: !n ? ""
        : n.image.startsWith("image://icon/") ? Quickshell.iconPath(n.image.slice(13), true)
        : n.image || Quickshell.iconPath(n.appIcon, true)

    Item {
        id: notifIcon
        Layout.alignment: Qt.AlignTop
        implicitWidth: Theme.bar.notificationIconSize
        implicitHeight: Theme.bar.notificationIconSize

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Colors.surfaceContainerHigh
        }

        IconImage {
            anchors.centerIn: parent
            implicitSize: Theme.button.iconSize
            source: notif.iconSource
            visible: source != ""
        }

        Text {
            anchors.centerIn: parent
            visible: notif.iconSource === ""
            text: "notifications"
            font.family: Theme.font.icons
            font.pixelSize: Theme.button.iconSize
            color: Colors.textOnSurface
        }

        Item {
            id: notifArtSlot
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: -4
            anchors.bottomMargin: -4
            width: Theme.bar.notificationBadgeSize
            height: Theme.bar.notificationBadgeSize
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: notif.n ? notif.n.appName : ""
            elide: Text.ElideRight
            color: Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }

        Text {
            Layout.fillWidth: true
            text: notif.n ? notif.n.summary : ""
            elide: Text.ElideRight
            color: Colors.textOnSurface
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: notif.n ? notif.n.body : ""
            textFormat: Text.PlainText
            Layout.preferredHeight: contentHeight
            wrapMode: Text.Wrap
            maximumLineCount: notif.open ? Theme.bar.notificationMaxLines : 1
            elide: notif.open ? Text.ElideNone : Text.ElideRight
            color: Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }

        Flow {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacing.sm
            visible: notif.open && notif.n !== null && notif.n.actions.length > 0
            spacing: Theme.spacing.sm

            Repeater {
                model: notif.n ? notif.n.actions.filter(a => a.identifier !== "default") : []

                Rectangle {
                    required property var modelData
                    implicitWidth: actionText.implicitWidth + Theme.spacing.lg * 2
                    implicitHeight: 32
                    radius: height / 2
                    color: actionMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: modelData.text
                        color: Colors.textOnSurface
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const n = notif.n;
                            modelData.invoke();
                            if (Notifications.current === n) Notifications.dismiss();
                        }
                    }
                }
            }
        }
    }

    IconButton {
        Layout.alignment: Qt.AlignTop
        implicitWidth: 28
        implicitHeight: 28
        icon: "close"
        onClicked: Notifications.dismiss()
    }
}
