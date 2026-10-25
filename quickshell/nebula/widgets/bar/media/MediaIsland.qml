import QtQuick
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property real available: 600

    readonly property real margin: (Theme.bar.height - Theme.button.size) / 2
    readonly property real fixed: 28 + Theme.spacing.sm * 2 + Theme.spacing.lg * 2 + margin * 2
    readonly property real waveWidth: Math.max(Theme.media.minWave, Math.min(Theme.media.maxWave, (available - fixed) * 0.45))
    readonly property real textWidth: Math.max(Theme.media.minText, Math.min(Theme.media.maxText, available - fixed - waveWidth))
    readonly property bool expanded: media.expanded
    readonly property bool active: Media.active

    implicitWidth: active ? media.implicitWidth + margin * 2 : Theme.bar.height
    implicitHeight: (active ? media.implicitHeight : Theme.button.size) + margin * 2

    Behavior on implicitWidth {
        enabled: !media.resizing
        NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
    Behavior on implicitHeight {
        NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    GlassRect {
        anchors.fill: parent
        radius: root.expanded ? Theme.radius.large + root.margin : Theme.bar.radius
        light: 0
        fill: Colors.primaryContainer
        clip: true

        Behavior on radius {
            NumberAnimation { duration: Theme.anim.medium }
        }

        MediaView {
            id: media
            anchors.fill: parent
            anchors.margins: root.margin
            visible: root.active
            textWidth: root.textWidth
            waveWidth: root.waveWidth
            cardWidth: Math.min(Theme.media.cardWidth, root.available - root.margin * 2 - Theme.spacing.lg * 2)
        }

        Text {
            anchors.centerIn: parent
            text: "music_note"
            font.family: Theme.font.icons
            font.pixelSize: Theme.button.iconSize
            color: Colors.textOnPrimaryContainer
            opacity: root.active ? 0 : 1
            scale: root.active ? 0.6 : 1
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.medium }
            }
            Behavior on scale {
                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
            }
        }
    }
}
