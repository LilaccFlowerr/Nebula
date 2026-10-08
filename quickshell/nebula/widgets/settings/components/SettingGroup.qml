import QtQuick
import QtQuick.Layouts
import qs.theme

ColumnLayout {
    id: root

    property string title: ""
    default property alias rows: list.data

    Layout.fillWidth: true
    spacing: Theme.spacing.sm

    Text {
        visible: root.title !== ""
        Layout.leftMargin: Theme.spacing.lg + Theme.spacing.xs
        text: root.title
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        font.weight: Font.DemiBold
        color: Colors.primary
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: list.implicitHeight

        Repeater {
            model: list.blocks.length

            Rectangle {
                required property int index
                readonly property Item block: list.blocks[index] ?? null
                readonly property Item before: list.blocks[index - 1] ?? null
                readonly property Item after: list.blocks[index + 1] ?? null
                readonly property real start: !block ? 0
                    : before ? (before.y + before.height + block.y) / 2 + list.spacing / 2 : 0
                readonly property real end: !block ? 0
                    : after ? (block.y + block.height + after.y) / 2 - list.spacing / 2 : list.height

                y: start
                width: parent.width
                height: end - start
                color: Colors.surfaceContainerHigh
                topLeftRadius: list.corner(index, true)
                topRightRadius: topLeftRadius
                bottomLeftRadius: list.corner(index, false)
                bottomRightRadius: bottomLeftRadius
            }
        }

        ColumnLayout {
            id: list

            property var blocks: []

            function update() {
                const next = Array.from(visibleChildren).filter(c => c.height > 0);
                if (next.length !== blocks.length || next.some((c, i) => c !== blocks[i])) blocks = next;
            }

            function corner(index, top) {
                const edge = top ? index === 0 : index === blocks.length - 1;
                return edge ? Theme.radius.large : Theme.settings.rowRadius;
            }

            function cornersFor(item) {
                const index = blocks.indexOf(item);
                return { top: corner(index, true), bottom: corner(index, false) };
            }

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.settings.rowGap

            onVisibleChildrenChanged: Qt.callLater(update)
            onImplicitHeightChanged: Qt.callLater(update)
            Component.onCompleted: update()
        }
    }
}
