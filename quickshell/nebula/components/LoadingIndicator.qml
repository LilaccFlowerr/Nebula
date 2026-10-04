import QtQuick
import M3Shapes
import qs.theme

Item {
    id: root

    property bool running: false
    property int delay: 0
    property bool shown: false
    property bool contained: true
    property int interval: Theme.anim.slow
    property color color: Colors.primary
    property color containerColor: Colors.primaryContainer
    property int index: 0

    readonly property var shapes: [
        MaterialShape.Circle,
        MaterialShape.Square,
        MaterialShape.SemiCircle,
        MaterialShape.Oval,
        MaterialShape.Pill,
        MaterialShape.Triangle,
        MaterialShape.Diamond,
        MaterialShape.Pentagon,
        MaterialShape.Gem,
        MaterialShape.Sunny,
        MaterialShape.VerySunny,
        MaterialShape.Cookie4Sided,
        MaterialShape.Cookie6Sided,
        MaterialShape.Clover4Leaf,
        MaterialShape.SoftBurst,
        MaterialShape.Flower,
        MaterialShape.Puffy
    ]

    implicitWidth: 48
    implicitHeight: 48
    visible: opacity > 0
    opacity: shown ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.containerColor
        visible: root.contained
    }

    MaterialShape {
        id: shape
        anchors.centerIn: parent
        width: parent.width / 2
        height: parent.height / 2
        shape: root.shapes[root.index]
        color: root.color
        animationDuration: Theme.anim.medium
        animationEasing.type: Easing.BezierSpline
        animationEasing.bezierCurve: Theme.anim.emphasizedDecel
    }

    onRunningChanged: if (!running) shown = false

    Timer {
        interval: root.delay
        running: root.running && !root.shown
        onTriggered: root.shown = true
    }

    Timer {
        interval: root.interval
        repeat: true
        triggeredOnStart: true
        running: root.shown
        onTriggered: {
            root.index = (root.index + 1) % root.shapes.length;
        }
    }
}
