import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property real available: 600
    property real panelRoom: Theme.media.panelWidth

    readonly property real margin: (Theme.bar.height - Theme.button.size) / 2
    readonly property real fixed: 28 + Theme.spacing.sm * 2 + Theme.spacing.lg * 2 + margin * 2
    readonly property real waveWidth: Math.max(Theme.media.minWave, Math.min(Theme.media.maxWave, (available - fixed) * 0.45))
    readonly property real textWidth: Math.max(Theme.media.minText, Math.min(Theme.media.maxText, available - fixed - waveWidth))
    readonly property bool active: Media.active
    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property bool expanded: GlobalStates.mediaExpanded && GlobalStates.isOn(screenName) && active

    readonly property real pillHeight: (active ? media.implicitHeight : Theme.button.size) + margin * 2
    readonly property real fullWidth: Math.max(width, Math.min(Theme.media.panelWidth, panelRoom))
    readonly property real fullRadius: Theme.radius.large + Theme.spacing.sm
    readonly property real neck: Theme.spacing.sm

    property real t: expanded ? 1 : 0
    property alias bodyArea: body

    Behavior on t {
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot * 0.6
        }
    }

    function lerp(a, b) {
        return a + (b - a) * t;
    }

    implicitWidth: active ? media.implicitWidth + margin * 2 : Theme.bar.height
    implicitHeight: pillHeight

    Behavior on implicitWidth {
        enabled: !media.resizing
        NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    Item {
        id: glass

        readonly property real bodyTop: root.height + root.neck
        readonly property real bodyHeight: Math.max(0, root.lerp(0, panel.fullHeight))
        readonly property real bodyWidth: root.lerp(root.width, root.fullWidth)
        readonly property real joinRadius: Math.min(root.fullRadius, Math.max(0, bodyWidth - root.width)) * Math.min(1, root.t * 2)

        width: Math.max(root.width, bodyWidth)
        height: bodyTop + bodyHeight
        opacity: Theme.glass.tint
        layer.enabled: root.t > 0.001

        Rectangle {
            width: root.width
            height: root.t > 0.001 ? glass.bodyTop + Math.min(glass.bodyHeight, root.fullRadius) : root.height
            topLeftRadius: Theme.bar.radius
            topRightRadius: Theme.bar.radius
            bottomLeftRadius: root.t > 0.001 ? 0 : Theme.bar.radius
            bottomRightRadius: root.t > 0.001 ? 0 : Theme.bar.radius
            color: Colors.primaryContainer
        }

        Rectangle {
            id: body
            y: glass.bodyTop
            width: glass.bodyWidth
            height: glass.bodyHeight
            visible: root.t > 0.001
            topLeftRadius: 0
            topRightRadius: Math.min(height / 2, root.lerp(Theme.bar.radius, root.fullRadius))
            bottomLeftRadius: topRightRadius
            bottomRightRadius: topRightRadius
            color: Colors.primaryContainer
        }

        Shape {
            x: root.width - 1
            y: glass.bodyTop - glass.joinRadius
            width: glass.joinRadius + 1
            height: glass.joinRadius + 1
            visible: glass.joinRadius > 0.5 && glass.bodyHeight > glass.joinRadius
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: -1
                fillColor: Colors.primaryContainer
                startX: 1; startY: 0
                PathArc { x: glass.joinRadius + 1; y: glass.joinRadius; radiusX: glass.joinRadius; radiusY: glass.joinRadius; direction: PathArc.Counterclockwise }
                PathLine { x: glass.joinRadius + 1; y: glass.joinRadius + 1 }
                PathLine { x: 0; y: glass.joinRadius + 1 }
                PathLine { x: 0; y: 0 }
            }
        }
    }

    MediaView {
        id: media
        x: root.margin
        y: root.margin
        width: root.width - root.margin * 2
        height: implicitHeight
        visible: root.active
        headerT: Math.min(1, root.t / 0.5)
        textWidth: root.textWidth
        waveWidth: root.waveWidth
    }

    Column {
        id: header

        readonly property real h: media.headerT
        readonly property point start: {
            root.t;
            return media.row.textBlock.mapToItem(root, 0, 0);
        }
        readonly property real endX: root.margin + Theme.spacing.md

        x: start.x + (endX - start.x) * h
        y: start.y + (root.margin + (media.height - height) / 2 - start.y) * h
        width: media.row.textBlock.width + (root.width - endX * 2 - media.row.textBlock.width) * h
        spacing: 0
        visible: h > 0.001
        opacity: media.skipFade
        transform: Translate { x: media.skipSlide }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: media.shownTitle
            color: Colors.textOnSurface
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal + (Theme.font.large + 2 - Theme.font.normal) * header.h
            font.weight: Math.round(400 + 300 * header.h)
        }

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: media.shownArtist
            color: Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }
    }

    Item {
        y: glass.bodyTop
        width: glass.bodyWidth
        height: glass.bodyHeight
        clip: true
        visible: root.t > 0.001

        MediaPanel {
            id: panel
            width: root.fullWidth
            height: fullHeight
            opacity: Math.max(0, Math.min(1, (root.t - 0.35) / 0.45))
            open: root.expanded
            art: media.shownArt
            slide: media.skipSlide
            fade: media.skipFade
            onRequestClose: GlobalStates.mediaExpanded = false
        }
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
