import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property real detach: 0
    property bool hookLeft: false
    property bool hookRight: false
    property bool edgeLeft: false
    property bool edgeRight: false
    property bool roundLeft: false
    property bool roundRight: false

    readonly property color fill: Qt.alpha(Colors.surface, Theme.bar.opacity)
    readonly property real attach: Math.max(0, Math.min(1, 1 - detach))
    readonly property real reach: Theme.bar.floatMargin * smooth(phase(attach, 0, 0.4))
    readonly property real rounding: 1 - smooth(phase(attach, 0.4, 0.3))
    readonly property real hook: smooth(phase(attach, 0.7, 0.3))

    function phase(value, start, length) {
        return Math.max(0, Math.min(1, (value - start) / length));
    }

    function smooth(x) {
        return x * x * (3 - 2 * x);
    }

    implicitHeight: Theme.bar.height

    Rectangle {
        id: bg
        z: -1
        x: root.edgeLeft ? -root.reach : 0
        y: -root.reach
        width: root.width + (root.edgeLeft ? root.reach : 0) + (root.edgeRight ? root.reach : 0)
        height: root.height + root.reach
        color: root.fill

        topLeftRadius: Theme.bar.radius * root.rounding
        topRightRadius: Theme.bar.radius * root.rounding
        bottomLeftRadius: root.roundLeft ? Theme.bar.radius : Theme.bar.radius * root.rounding
        bottomRightRadius: root.roundRight ? Theme.bar.radius : Theme.bar.radius * root.rounding
    }

    Shape {
        z: -1
        x: bg.x - Theme.bar.radius
        y: bg.y
        width: Theme.bar.radius
        height: Theme.bar.radius
        visible: root.hookLeft && root.hook > 0.01
        scale: root.hook
        transformOrigin: Item.TopRight
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillColor: root.fill
            startX: 0; startY: 0
            PathLine { x: Theme.bar.radius; y: 0 }
            PathLine { x: Theme.bar.radius; y: Theme.bar.radius }
            PathArc { x: 0; y: 0; radiusX: Theme.bar.radius; radiusY: Theme.bar.radius; direction: PathArc.Counterclockwise }
        }
    }

    Shape {
        z: -1
        x: bg.x + bg.width
        y: bg.y
        width: Theme.bar.radius
        height: Theme.bar.radius
        visible: root.hookRight && root.hook > 0.01
        scale: root.hook
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillColor: root.fill
            startX: Theme.bar.radius; startY: 0
            PathLine { x: 0; y: 0 }
            PathLine { x: 0; y: Theme.bar.radius }
            PathArc { x: Theme.bar.radius; y: 0; radiusX: Theme.bar.radius; radiusY: Theme.bar.radius }
        }
    }
}
