import QtQuick
import QtQuick.Shapes
import qs.theme

Shape {
    id: root

    // Settings
    property real level: 0.85
    property bool low: false

    // Handy values for the arcs
    readonly property real thickness: Theme.batteryRing.thickness
    readonly property real r: (width - thickness) / 2
    readonly property real sweep: 360 * level                
    readonly property real gap: 14

    // Animate every change of level, so the ring slides instead of jumping
    Behavior on level {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    implicitWidth: Theme.batteryRing.size
    implicitHeight: Theme.batteryRing.size
    preferredRendererType: Shape.CurveRenderer

    // Indicator: the filled part
    ShapePath {
        strokeColor: root.low ? Colors.errorColor : Colors.primary
        strokeWidth: root.thickness
        capStyle: ShapePath.RoundCap
        fillColor: "transparent"

        PathAngleArc {
            centerX: root.width / 2
            centerY: root.height / 2
            radiusX: root.r
            radiusY: root.r
            startAngle: -90
            sweepAngle: root.sweep
        }
    }

    // Track: the empty part, faint
    ShapePath {
        strokeColor: Qt.alpha(Colors.primary, Theme.batteryRing.trackOpacity)
        strokeWidth: root.thickness
        capStyle: ShapePath.RoundCap
        fillColor: "transparent"

        PathAngleArc {
            centerX: root.width / 2
            centerY: root.height / 2
            radiusX: root.r
            radiusY: root.r
            startAngle: -90 + root.sweep + root.gap
            sweepAngle: Math.max(0, 360 - root.sweep - root.gap * 2)
        }
    }
}