import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root

    property url source
    property int bumps: 9
    property real depth: 0.07
    property color placeholderColor: "transparent"

    readonly property bool hasImage: image.status === Image.Ready

    implicitWidth: 56
    implicitHeight: 56

    readonly property var points: {
        const pts = [];
        const cx = width / 2, cy = height / 2;
        const r = Math.min(width, height) / 2 / (1 + depth);
        for (let i = 0; i <= 360; i += 2) {
            const a = i * Math.PI / 180;
            const rr = r * (1 + depth * Math.cos(bumps * a));
            pts.push(Qt.point(cx + rr * Math.cos(a), cy + rr * Math.sin(a)));
        }
        return pts;
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.placeholderColor
            strokeColor: "transparent"
            PathPolyline { path: root.points }
        }
    }

    Image {
        id: image
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: false
    }

    Item {
        id: mask
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "black"
                strokeColor: "transparent"
                PathPolyline { path: root.points }
            }
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: image
        visible: root.hasImage
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }
}
