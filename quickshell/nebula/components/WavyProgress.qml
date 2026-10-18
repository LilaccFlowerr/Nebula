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
        NumberAnimation { duration: Math.round(1000 * Theme.anim.scale) }
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

    property real shift: 0

    implicitWidth: 100
    implicitHeight: 12
    readonly property real mid: height / 2
    readonly property real splitX: Math.max(thickness / 2, width * shownProgress)

    readonly property var wavePoints: {
        const points = [];
        const end = width + wavelength;
        for (let x = 0; x <= end; x += 1.5)
            points.push(Qt.point(x, mid + shownAmplitude * Math.sin(x / wavelength * 2 * Math.PI)));
        return points;
    }

    function waveY(x) {
        return mid + shownAmplitude * Math.sin((x + shift) / wavelength * 2 * Math.PI);
    }

    Item {
        id: played
        x: root.thickness / 2
        width: root.splitX - x
        height: root.height
        clip: true

        Shape {
            x: -root.shift - played.x
            width: root.width + root.wavelength
            height: root.height
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: root.color
                strokeWidth: root.thickness
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"

                PathPolyline { path: root.wavePoints }
            }
        }
    }

    Rectangle {
        x: 0
        y: root.waveY(root.thickness / 2) - height / 2
        width: root.thickness
        height: root.thickness
        radius: width / 2
        color: root.color
    }

    Rectangle {
        x: root.splitX - width / 2
        y: root.waveY(root.splitX) - height / 2
        width: root.thickness
        height: root.thickness
        radius: width / 2
        color: root.color
    }

    Rectangle {
        x: Math.min(root.splitX + root.gap, root.width) - root.thickness / 2
        y: root.mid - height / 2
        width: Math.max(0, root.width - x)
        height: root.thickness
        radius: height / 2
        color: Qt.alpha(root.color, Theme.batteryRing.trackOpacity)
        visible: width > root.thickness
    }

    NumberAnimation on shift {
        from: 0
        to: root.wavelength
        duration: 1500
        loops: Animation.Infinite
        running: root.animated && root.visible
    }
}
