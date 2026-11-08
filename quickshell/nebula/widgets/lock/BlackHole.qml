import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property real boost: 0
    property real iconOpacity: 1
    property real spinPhase: 0
    readonly property real radius: width / 2

    implicitWidth: Theme.lock.holeSize
    implicitHeight: Theme.lock.holeSize

    FrameAnimation {
        running: root.visible
        onTriggered: root.spinPhase += frameTime * (0.5 + 9 * root.boost) * 1.6
    }

    function rand(seed) {
        const x = Math.sin(seed * 12.9898 + 78.233) * 43758.5453;
        return x - Math.floor(x);
    }

    Shape {
        id: halo

        readonly property real r: root.width * 1.6

        anchors.centerIn: parent
        width: r * 2
        height: r * 2
        z: -1

        ShapePath {
            strokeColor: "transparent"
            fillGradient: RadialGradient {
                centerX: halo.r
                centerY: halo.r
                centerRadius: halo.r
                focalX: halo.r
                focalY: halo.r
                GradientStop { position: 0.2; color: Qt.alpha(Colors.primary, 0.3) }
                GradientStop { position: 1; color: Qt.alpha(Colors.primary, 0) }
            }
            startX: 0
            startY: 0
            PathLine { x: halo.width; y: 0 }
            PathLine { x: halo.width; y: halo.height }
            PathLine { x: 0; y: halo.height }
            PathLine { x: 0; y: 0 }
        }
    }

    Repeater {
        model: Theme.lock.ringDots

        Rectangle {
            id: dot

            required property int index

            readonly property real ring: 1.5 + root.rand(index + 1) * 1.9
            readonly property real angle: root.rand(index + 50) * Math.PI * 2 + root.spinPhase / Math.pow(ring, 1.5)

            width: 3
            height: 3
            radius: 1.5
            x: root.width / 2 + Math.cos(angle) * ring * root.radius - 1.5
            y: root.height / 2 + Math.sin(angle) * ring * root.radius * Theme.lock.ringTilt - 1.5
            z: Math.sin(angle) > 0 ? 2 : 0
            color: index % 3 === 0 ? Colors.tertiary : Colors.primary
            opacity: 0.85
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.width
        height: width
        radius: width / 2
        color: "black"
        border.width: 2
        border.color: Qt.alpha(Colors.inversePrimary, 0.75)
        z: 1
    }

    Text {
        anchors.centerIn: parent
        text: "lock"
        font.family: Theme.font.icons
        font.pixelSize: root.width * 0.26
        color: Colors.textOnSurface
        opacity: root.iconOpacity
        z: 3
    }
}
