import QtQuick
import qs.services
import qs.theme

Rectangle {
    id: root

    property bool shown: false
    property bool open: false
    readonly property bool hovered: hover.hovered
    property real offset: shown ? 0 : -Theme.spacing.lg

    width: Theme.bar.notificationWidth
    height: shown ? content.implicitHeight + Theme.spacing.md * 2 : 0
    radius: Theme.radius.large
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)
    border.width: Notifications.urgent ? 2 : 0
    border.color: Colors.errorColor
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.9
    visible: opacity > 0
    clip: true

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
    Behavior on offset {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
    Behavior on height {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Notifications.activate()
    }

    NotificationContent {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.spacing.md
        n: Notifications.current
        open: root.open
    }
}
