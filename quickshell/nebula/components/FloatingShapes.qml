import QtQuick
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    property bool running: true
    property int count: 14
    property real minSize: 36
    property real maxSize: 124
    property real minSpeed: 4
    property real maxSpeed: 18
    property real maxRotSpeed: 12
    property list<color> palette: [Colors.primary, Colors.secondary, Colors.tertiary, Colors.textOnPrimaryContainer]
    property list<real> darkOpacities: [0.16, 0.14, 0.14, 0.06]
    property list<real> lightOpacities: [0.24, 0.2, 0.2, 0.1]

    readonly property list<int> pool: [MaterialShape.Circle, MaterialShape.Cookie4Sided, MaterialShape.Cookie6Sided, MaterialShape.Cookie7Sided, MaterialShape.Cookie9Sided, MaterialShape.Cookie12Sided, MaterialShape.Sunny, MaterialShape.VerySunny, MaterialShape.SoftBurst, MaterialShape.Pentagon, MaterialShape.Gem, MaterialShape.Arch, MaterialShape.Arrow, MaterialShape.Pill, MaterialShape.Triangle, MaterialShape.Fan, MaterialShape.Oval]

    property real pace: running && !Settings.theme.reduceMotion ? 1 : 0

    Behavior on pace {
        NumberAnimation {
            duration: Math.round(Theme.nowPlaying.spinUpDuration * Theme.anim.scale)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    function rand(min, max) {
        return min + Math.random() * (max - min);
    }

    function signedRand(min, max) {
        return rand(min, max) * (Math.random() < 0.5 ? -1 : 1);
    }

    clip: true

    Repeater {
        id: shapes
        model: root.count

        MaterialShape {
            id: shape

            required property int index

            readonly property real size: root.minSize + (index / root.count) * (root.maxSize - root.minSize)
            readonly property int tone: Math.floor(Math.random() * root.palette.length)
            property real vx: root.signedRand(root.minSpeed, root.maxSpeed)
            property real vy: root.signedRand(root.minSpeed, root.maxSpeed)
            property real vr: root.signedRand(0, root.maxRotSpeed)
            property real fx: (index * 0.618034 + Math.random() / root.count) % 1
            property real fy: Math.random()

            x: -size + fx * (root.width + size)
            y: -size + fy * (root.height + size)
            width: size
            height: size
            shape: root.pool[Math.floor(Math.random() * root.pool.length)]
            color: root.palette[tone]
            opacity: (Colors.isDark ? root.darkOpacities : root.lightOpacities)[tone]
            rotation: root.rand(0, 360)

            Behavior on color {
                ColorAnimation { duration: Theme.anim.slow }
            }
        }
    }

    FrameAnimation {
        running: root.pace > 0 && root.width > 0 && root.height > 0
        onTriggered: {
            const dt = frameTime * root.pace;
            for (let i = 0; i < shapes.count; i++) {
                const s = shapes.itemAt(i);
                if (!s) continue;

                s.fx = (s.fx + s.vx * dt / (root.width + s.size) + 1) % 1;
                s.fy = (s.fy + s.vy * dt / (root.height + s.size) + 1) % 1;
                s.rotation += s.vr * dt;
            }
        }
    }
}
