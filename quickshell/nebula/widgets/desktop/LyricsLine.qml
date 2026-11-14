import QtQuick
import M3Shapes
import qs.theme

Item {
    id: root

    property var words: []
    property real time: 0
    property real size: 44
    property color ink: "white"
    property color fill: Colors.primary
    property bool sung: false
    property bool singing: false
    property bool marker: false
    property color markerColor: Colors.tertiary
    property string markerShape: "Cookie4Sided"

    readonly property string line: words.map(word => word.text).join(" ")
    readonly property var stops: {
        const out = [];
        let before = "";
        for (const word of words) {
            out.push(metrics.advanceWidth(before));
            before += word.text + " ";
        }
        out.push(metrics.advanceWidth(line));
        return out;
    }
    readonly property int at: {
        let found = -1;
        for (let i = 0; i < words.length; i++) {
            if (words[i].start <= time) found = i;
            else break;
        }
        return found;
    }
    readonly property real part: {
        const word = words[at];
        if (!word) return 0;
        return Math.max(0, Math.min((time - word.start) / Math.max(0.05, word.end - word.start), 1));
    }
    readonly property real phase: Math.max(0, at) + part
    readonly property real sweep: {
        if (sung) return base.width;
        if (!singing || at < 0 || stops.length < 2) return 0;
        const from = stops[at] ?? 0;
        const to = stops[at + 1] ?? from;
        return from + (to - from) * part;
    }

    implicitWidth: base.implicitWidth
    implicitHeight: base.implicitHeight

    FontMetrics {
        id: metrics
        font: base.font
    }

    Text {
        id: base

        text: root.line
        font.family: Theme.font.family
        font.pixelSize: root.size
        font.weight: Font.ExtraBold
        color: root.ink
        style: Text.Outline
        styleColor: Qt.alpha(Colors.scrim, 0.5)
    }

    Item {
        width: root.sweep
        height: base.height
        clip: true

        Text {
            text: root.line
            font: base.font
            color: root.fill
            style: Text.Outline
            styleColor: Qt.alpha(Colors.scrim, 0.5)
        }
    }

    MaterialShape {
        visible: opacity > 0
        opacity: root.marker && root.words.length > 0 ? 1 : 0
        x: root.sweep - width / 2
        y: -height * 0.75 - (1 - Math.cos(2 * Math.PI * root.phase)) / 2 * root.size * 0.28
        implicitSize: root.size * 0.6
        shape: MaterialShape[root.markerShape] ?? MaterialShape.Cookie4Sided
        color: root.markerColor
        rotation: root.phase * 45

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.medium }
        }
    }
}
