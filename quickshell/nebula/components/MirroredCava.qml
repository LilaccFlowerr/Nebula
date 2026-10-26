import QtQuick
import qs.theme

Item {
    id: root

    property var values: []
    property int rows: 32
    property real barHeight: 3
    property color color: Colors.primary
    property real minLength: 0.04

    readonly property real gap: rows > 1 ? Math.max(0, (height - rows * barHeight) / (rows - 1)) : 0
    readonly property int half: Math.ceil(rows / 2)

    function level(row) {
        const band = Math.abs(row - (rows - 1) / 2);
        const count = values.length;
        if (count === 0) return 0;
        const start = Math.floor(band / half * count);
        const end = Math.max(start + 1, Math.floor((band + 1) / half * count));
        let sum = 0;
        let n = 0;
        for (let i = start; i < end && i < count; i++) {
            sum += values[i];
            n++;
        }
        return n > 0 ? Math.min(1, sum / n) : 0;
    }

    Repeater {
        model: root.rows

        Rectangle {
            required property int index

            readonly property real level: root.level(index)

            anchors.horizontalCenter: parent.horizontalCenter
            y: index * (root.barHeight + root.gap)
            width: root.width * Math.max(root.minLength, level)
            height: root.barHeight
            radius: height / 2
            color: root.color
            opacity: 0.35 + 0.65 * level
        }
    }
}
