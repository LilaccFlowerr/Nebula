import QtQuick
import QtQuick.Layouts
import qs.theme

Rectangle {
    id: root

    property var options: []
    property int currentIndex: 0

    signal selected(int index)

    implicitHeight: 36
    radius: height / 2
    color: "transparent"
    border.width: 1
    border.color: Colors.outline
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        Repeater {
            model: root.options

            Rectangle {
                id: segment
                required property string modelData
                required property int index
                readonly property bool active: index === root.currentIndex

                Layout.fillWidth: true
                Layout.fillHeight: true
                topLeftRadius: index === 0 ? height / 2 : 0
                bottomLeftRadius: index === 0 ? height / 2 : 0
                topRightRadius: index === root.options.length - 1 ? height / 2 : 0
                bottomRightRadius: index === root.options.length - 1 ? height / 2 : 0
                color: active ? Colors.secondaryContainer : segmentMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.08) : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Theme.anim.fast }
                }

                Rectangle {
                    visible: segment.index > 0
                    width: 1
                    height: parent.height
                    color: Colors.outline
                }

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacing.xs

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "check"
                        visible: segment.active
                        font.family: Theme.font.icons
                        font.pixelSize: 18
                        color: Colors.textOnSecondaryContainer
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: segment.modelData
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: Font.DemiBold
                        color: segment.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                    }
                }

                MouseArea {
                    id: segmentMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected(segment.index)
                }
            }
        }
    }
}
