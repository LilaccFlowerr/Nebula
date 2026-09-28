import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property real neckWidth: 40
    property real curve: 12
    property color color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    implicitWidth: neckWidth + curve * 2
    implicitHeight: curve * 2

    readonly property real r: Math.min(curve, height / 2)
    readonly property real leftX: r
    readonly property real rightX: width - r

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillColor: root.color
            startX: 0; startY: 0

            PathLine { x: root.width; y: 0 }
            PathArc { x: root.rightX; y: root.r; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise }
            PathLine { x: root.rightX; y: root.height - root.r }
            PathArc { x: root.width; y: root.height; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise }
            PathLine { x: 0; y: root.height }
            PathArc { x: root.leftX; y: root.height - root.r; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise }
            PathLine { x: root.leftX; y: root.r }
            PathArc { x: 0; y: 0; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise }
        }
    }
}
