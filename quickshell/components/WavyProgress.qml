import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property real progress: 0.3

    property bool smoothProgress: true
    property real shownProgress: progress

    Behavior on shownProgress {
        enabled: root.smoothProgress
        NumberAnimation { duration: 1000 }
    }
    property bool animated: true
    property color color: Colors.secondary

    property real thickness: 3
    property real amplitude: 2.5

    property real shownAmplitude: animated ? amplitude : 0

    Behavior on shownAmplitude {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }
    property real wavelength: 16
    property real gap: 6

    property real phase: 0

    implicitWidth: 100
    implicitHeight: 12
    readonly property real mid: height / 2
    readonly property real splitX: Math.max(thickness / 2, width * shownProgress)

    readonly property var wavePoints: {
        const points = [];
        for (let x = thickness / 2; x <= splitX; x += 1.5) {
            const y = mid + shownAmplitude * Math.sin(x / wavelength * 2 * Math.PI + phase);
            points.push(Qt.point(x, y));
        }
        const endY = mid + shownAmplitude * Math.sin(splitX / wavelength * 2 * Math.PI + phase);
        points.push(Qt.point(splitX, endY));
        return points;
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.thickness
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"

            PathPolyline { path: root.wavePoints }
        }

        ShapePath {
            strokeColor: Qt.alpha(root.color, Theme.batteryRing.trackOpacity)
            strokeWidth: root.thickness
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            startX: Math.min(root.splitX + root.gap, root.width - root.thickness / 2)
            startY: root.mid
            PathLine { x: root.width - root.thickness / 2; y: root.mid }
        }
    }

    NumberAnimation on phase {
        from: 0
        to: 2 * Math.PI
        duration: 1500
        loops: Animation.Infinite
        running: root.animated
    }
}
