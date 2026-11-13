import QtQuick
import Quickshell
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property Item target: null
    property var cfg: ({})

    readonly property bool shown: Widgets.editing && target !== null
    readonly property bool hovered: shown && (hover.onEdge || resize.active)
    readonly property var kind: Widgets.types[cfg.type] ?? ({ size: 200, minSize: 80, maxSize: 600 })
    readonly property real reach: Theme.edit.grab
    readonly property real pad: Theme.edit.outlineGap + Theme.edit.outlineWidth * Theme.edit.outlineHot + Theme.edit.outlineWave * 2 + 2
    property real phase: 0
    property real weight: hovered ? Theme.edit.outlineHot : 1

    function away(x, y) {
        return Math.hypot(x - width / 2, y - height / 2);
    }

    function edge(x, y) {
        if (width <= 0) return 0;
        const angle = Math.atan2(x - width / 2, height / 2 - y) * 180 / Math.PI;
        return outlineOf.distanceAtAngle((angle + 360) % 360);
    }

    x: target ? target.x : 0
    y: target ? target.y : 0
    width: target ? target.width : 0
    height: target ? target.height : 0
    visible: shown

    NumberAnimation on phase {
        running: root.shown && Theme.anim.scale > 0
        from: 0
        to: Math.PI * 2
        duration: Theme.edit.outlineLoop
        loops: Animation.Infinite
    }

    Behavior on weight {
        NumberAnimation {
            duration: Theme.anim.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    MaterialShape {
        id: outlineOf

        anchors.fill: parent
        visible: false
        shape: MaterialShape[root.cfg.shape] ?? MaterialShape.Circle
        animationDuration: 0
    }

    ShaderEffectSource {
        id: capture

        x: -root.pad
        y: -root.pad
        width: root.width + root.pad * 2
        height: root.height + root.pad * 2
        sourceItem: root.shown ? root.target : null
        sourceRect: Qt.rect(-root.pad, -root.pad, width, height)
        live: true
        visible: false
    }

    ShaderEffect {
        x: -root.pad
        y: -root.pad
        width: capture.width
        height: capture.height
        visible: root.shown && width > 0

        readonly property var source: capture
        readonly property real gap: Theme.edit.outlineGap
        readonly property real line: Theme.edit.outlineWidth * root.weight
        readonly property real amplitude: Theme.edit.outlineWave
        readonly property real count: Math.max(6, Math.round(Math.PI * (root.width + root.height) / 2 / Theme.edit.outlineWaveLength))
        readonly property real phase: root.phase
        readonly property vector2d texel: Qt.vector2d(1 / Math.max(1, width), 1 / Math.max(1, height))
        readonly property color tint: Colors.primary

        fragmentShader: "file://" + Quickshell.shellPath("shaders/outline.frag.qsb")
    }

    Rectangle {
        x: (root.width - width) / 2
        y: -root.pad - height - Theme.spacing.xs
        width: tag.implicitWidth + Theme.spacing.lg
        height: Theme.edit.tagHeight
        radius: height / 2
        color: Colors.primary
        scale: resize.active ? 1.12 : 1

        Behavior on scale {
            NumberAnimation {
                duration: Theme.anim.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.standard
            }
        }

        Text {
            id: tag

            anchors.centerIn: parent
            text: Math.round(root.cfg.size ?? root.width)
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            font.weight: Font.DemiBold
            color: Colors.textOnPrimary
        }
    }

    Item {
        parent: root.target ?? root
        x: -root.reach
        y: -root.reach
        width: root.width + root.reach * 2
        height: root.height + root.reach * 2

        HoverHandler {
            id: hover

            readonly property real px: point.position.x - root.reach
            readonly property real py: point.position.y - root.reach
            readonly property bool onEdge: hovered && Math.abs(root.away(px, py) - root.edge(px, py)) <= root.reach
            readonly property bool rising: (px - root.width / 2) * (py - root.height / 2) < 0

            cursorShape: onEdge || resize.active ? (rising ? Qt.SizeBDiagCursor : Qt.SizeFDiagCursor) : undefined
        }

        DragHandler {
            id: resize

            property real startSize: 0
            property real startAway: 1

            function span() {
                const center = root.mapToItem(null, root.width / 2, root.height / 2);
                return Math.hypot(centroid.scenePosition.x - center.x, centroid.scenePosition.y - center.y);
            }

            target: null
            enabled: hover.onEdge || active
            dragThreshold: 2

            onActiveChanged: {
                Widgets.resizing = active;
                if (!active) return;
                startSize = root.cfg.size ?? root.width;
                startAway = Math.max(1, span());
            }

            onTranslationChanged: {
                if (!active) return;
                const wanted = startSize * span() / startAway;
                const size = Math.max(root.kind.minSize, Math.min(Math.round(wanted / 2) * 2, root.kind.maxSize));
                if (size !== root.cfg.size) Widgets.update(root.cfg.id, { size: size });
            }
        }
    }
}
