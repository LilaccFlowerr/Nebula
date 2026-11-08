import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property real spread: 0
    property real drift: 0
    readonly property var palette: [Colors.primary, Colors.tertiary, Colors.secondary, Colors.inversePrimary, Colors.primaryContainer]

    function rand(seed) {
        const x = Math.sin(seed * 12.9898 + 78.233) * 43758.5453;
        return x - Math.floor(x);
    }

    FrameAnimation {
        running: root.spread > 0.002
        onTriggered: root.drift += frameTime * 0.11
    }

    Repeater {
        model: 14

        Shape {
            id: cloud

            required property int index

            readonly property real radius: (90 + root.rand(index + 1) * 120) * Math.max(0.7, root.height / 1080)
            readonly property real angle: root.rand(index + 40) * Math.PI * 2 + root.drift
            readonly property real dist: (40 + root.rand(index + 80) * 340) * root.spread * Math.max(0.7, root.height / 1080)

            width: radius * 2
            height: radius * 2
            x: root.width / 2 + Math.cos(angle) * dist - radius
            y: root.height * Theme.lock.centerHeight + Math.sin(angle) * dist * 0.7 - radius
            scale: 0.3 + 0.7 * root.spread
            opacity: Math.min(1, root.spread * 1.6)

            ShapePath {
                strokeColor: "transparent"
                fillGradient: RadialGradient {
                    centerX: cloud.radius
                    centerY: cloud.radius
                    centerRadius: cloud.radius
                    focalX: cloud.radius
                    focalY: cloud.radius
                    GradientStop { position: 0; color: Qt.alpha(root.palette[cloud.index % 5], 0.2) }
                    GradientStop { position: 1; color: Qt.alpha(root.palette[cloud.index % 5], 0) }
                }
                startX: 0
                startY: 0
                PathLine { x: cloud.width; y: 0 }
                PathLine { x: cloud.width; y: cloud.height }
                PathLine { x: 0; y: cloud.height }
                PathLine { x: 0; y: 0 }
            }
        }
    }
}
