import QtQuick
import QtQuick.Shapes
import qs.theme

Item {
    id: root

    property real morph: 0
    property int bumps: 9
    property real depth: 0.07
    property real squareness: 4
    property color color: Colors.primary

    signal clicked()

    implicitWidth: 72
    implicitHeight: 72

    Behavior on morph {
        NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    rotation: morph * 90
    scale: mouse.pressed ? 0.92 : mouse.containsMouse ? 1.05 : 1

    Behavior on scale {
        NumberAnimation { duration: Theme.anim.fast }
    }

    readonly property var points: {
        const pts = [];
        const cx = width / 2, cy = height / 2;
        const r = Math.min(width, height) / 2 / (1 + depth);
        const n = squareness;
        const m = Math.max(0, Math.min(1, morph));
        for (let i = 0; i <= 360; i += 2) {
            const a = i * Math.PI / 180;
            const cookie = r * (1 + depth * Math.cos(bumps * a));
            const square = 0.82 * r / Math.pow(Math.pow(Math.abs(Math.cos(a)), n) + Math.pow(Math.abs(Math.sin(a)), n), 1 / n);
            const rr = cookie + (square - cookie) * m;
            pts.push(Qt.point(cx + rr * Math.cos(a), cy + rr * Math.sin(a)));
        }
        return pts;
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathPolyline { path: root.points }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
