import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "Shapes.js" as Shapes

Item {
    id: root

    property url source
    property size sourceSize
    property int bumps: 9
    property real depth: 0.07
    property real lobes: 0
    property int bumpsTo: bumps
    property real morph: 0
    property string shapeTo: ""
    property real shapeMorph: 0
    property bool stretch: false
    property string shape: ""
    property color placeholderColor: "transparent"

    readonly property bool hasImage: image.status === Image.Ready

    implicitWidth: 56
    implicitHeight: 56

    readonly property var points: {
        if (shape !== "") {
            const from = Shapes.points(shape, width, height, stretch);
            if (shapeTo === "" || shapeMorph === 0)
                return from.map(p => Qt.point(p[0], p[1]));
            const to = Shapes.points(shapeTo, width, height, stretch);
            return from.map((p, i) => Qt.point(p[0] + (to[i][0] - p[0]) * shapeMorph, p[1] + (to[i][1] - p[1]) * shapeMorph));
        }
        const pts = [];
        const cx = width / 2, cy = height / 2;
        const r = Math.min(width, height) / 2 / (1 + depth);
        const c = Math.min(width, height) / 2 / (1 + lobes), rho = c * lobes;
        const radius = (a, n) => {
            if (lobes <= 0) return r * (1 + depth * Math.cos(n * a));
            let sum = 0;
            for (let k = 0; k < n; k++) {
                const d = a - k * 2 * Math.PI / n;
                const s = c * Math.sin(d), co = c * Math.cos(d);
                if (Math.abs(s) < rho && co > 0) sum += Math.pow(co + Math.sqrt(rho * rho - s * s), 24);
            }
            return sum > 0 ? Math.pow(sum, 1 / 24) : c;
        };
        for (let i = 0; i <= 360; i += 2) {
            const a = i * Math.PI / 180;
            const from = radius(a, bumps);
            const rr = morph === 0 || bumpsTo === bumps ? from : from + (radius(a, bumpsTo) - from) * morph;
            pts.push(Qt.point(cx + rr * Math.cos(a), cy + rr * Math.sin(a)));
        }
        if (shapeTo !== "" && shapeMorph > 0) {
            const target = Shapes.points(shapeTo, width, height);
            const steps = target.length - 1;
            const rot = -rotation * Math.PI / 180;
            for (let i = 0; i < pts.length; i++) {
                const k = ((Math.round((i * 2 + rotation) / 2) % steps) + steps) % steps;
                const tx = target[k][0] - cx, ty = target[k][1] - cy;
                const lx = cx + tx * Math.cos(rot) - ty * Math.sin(rot);
                const ly = cy + tx * Math.sin(rot) + ty * Math.cos(rot);
                pts[i] = Qt.point(pts[i].x + (lx - pts[i].x) * shapeMorph, pts[i].y + (ly - pts[i].y) * shapeMorph);
            }
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
        sourceSize: root.sourceSize
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
