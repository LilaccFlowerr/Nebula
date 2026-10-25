import QtQuick
import qs.services
import qs.theme

Rectangle {
    id: root

    property bool open: false
    readonly property bool hovered: hover.hovered

    implicitWidth: osd.implicitWidth + Theme.spacing.lg * 2
    implicitHeight: Theme.button.size + Theme.spacing.xs * 2
    radius: height / 2
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.85
    transformOrigin: Item.Top

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    HoverHandler {
        id: hover
    }

    LevelOsd {
        id: osd
        anchors.centerIn: parent
        kind: Events.current === "brightness" ? "brightness" : "volume"
    }
}
