import QtQuick
import qs.theme

Item {
    id: root

    property var values: []
    property int count: 64
    property color color: Colors.primary
    property real barWidth: 2

    readonly property real gap: (width - barWidth * count) / Math.max(1, count - 1)

    Row {
        anchors.fill: parent
        spacing: root.gap

        Repeater {
            model: root.count

            Item {
                required property int index
                width: root.barWidth
                height: root.height

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(1, (root.values[index] ?? 0) * parent.height)
                    radius: width / 2
                    color: root.color
                }
            }
        }
    }
}
