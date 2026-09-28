import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property real level: 0.85
    property bool low: false

    readonly property real thickness: Theme.batteryRing.thickness
    readonly property real r: (width - thickness) / 2
    readonly property real sweep: 360 * level
    readonly property real gap: 14

    property real wobble: 0
    property real phase: 0
    property int waves: 8

    Behavior on level {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    implicitWidth: Theme.batteryRing.size
    implicitHeight: Theme.batteryRing.size

    function ripple(hold = 0) {
        holdPause.duration = hold;
        rippleAnim.restart();
    }

    SequentialAnimation {
        id: rippleAnim

        NumberAnimation {
            target: root
            property: "wobble"
            to: 2
            duration: 150
            easing.type: Easing.OutQuad
        }
        PauseAnimation {
            id: holdPause
            duration: 0
        }
        NumberAnimation {
            target: root
            property: "wobble"
            to: 0
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    NumberAnimation on phase {
        from: 0
        to: 2 * Math.PI
        duration: 800
        loops: Animation.Infinite
        running: root.wobble > 0
    }

    function arcPoints(startDeg, sweepDeg) {
        const points = [];
        const cx = width / 2, cy = height / 2;
        const steps = Math.max(2, Math.ceil(sweepDeg / 3));
        for (let i = 0; i <= steps; i++) {
            const a = (startDeg + sweepDeg * i / steps) * Math.PI / 180;
            const rr = r + wobble * Math.sin(waves * a + phase);
            points.push(Qt.point(cx + rr * Math.cos(a), cy + rr * Math.sin(a)));
        }
        return points;
    }

    readonly property var indicatorPoints: arcPoints(-90, sweep)
    readonly property var trackPoints: arcPoints(-90 + sweep + gap, Math.max(0, 360 - sweep - gap * 2))

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.low ? Colors.errorColor : Colors.primary
            strokeWidth: root.thickness
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"

            PathPolyline { path: root.indicatorPoints }
        }

        ShapePath {
            strokeColor: Qt.alpha(Colors.primary, Theme.batteryRing.trackOpacity)
            strokeWidth: root.thickness
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"

            PathPolyline { path: root.trackPoints }
        }
    }
}
