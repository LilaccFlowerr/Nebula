import QtQuick
import qs.services
import qs.theme

Item {
    id: root

    property int anchorLine: Theme.lyrics.anchorLine

    clip: true

    Column {
        id: lines

        visible: Lyrics.synced
        width: parent.width
        y: (root.anchorLine - Math.max(0, Lyrics.currentIndex)) * Theme.lyrics.lineHeight

        Behavior on y {
            NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        Repeater {
            model: Lyrics.lines

            Item {
                id: line

                required property var modelData
                required property int index
                readonly property int distance: Math.abs(index - Lyrics.currentIndex)
                readonly property bool current: distance === 0
                readonly property real lineScale: current ? 1 : distance === 1 ? Theme.lyrics.nearScale : Theme.lyrics.farScale

                width: lines.width
                height: Theme.lyrics.lineHeight

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width / scale
                    transformOrigin: Item.Left
                    scale: line.lineScale
                    elide: Text.ElideRight
                    text: line.modelData.text || "♪"
                    color: line.current ? Colors.primary : Colors.textOnSurface
                    opacity: line.current ? 1 : line.distance === 1 ? Theme.lyrics.nearOpacity : Theme.lyrics.farOpacity
                    font.family: Theme.font.family
                    font.pixelSize: Theme.lyrics.fontSize
                    font.weight: Font.Bold

                    Behavior on scale {
                        NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot * 2 }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: Theme.anim.medium }
                    }
                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.medium }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Lyrics.seekToLine(line.index)
                }
            }
        }
    }

    Row {
        anchors.centerIn: parent
        visible: Lyrics.status === "loading"
        spacing: Theme.spacing.xs

        Repeater {
            model: 3

            Rectangle {
                required property int index
                width: 8
                height: 8
                radius: 4
                color: Colors.textOnSurfaceVariant

                SequentialAnimation on opacity {
                    running: Lyrics.status === "loading"
                    loops: Animation.Infinite
                    PauseAnimation { duration: index * 150 }
                    NumberAnimation { from: 0.3; to: 1; duration: 400; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1; to: 0.3; duration: 400; easing.type: Easing.InOutSine }
                    PauseAnimation { duration: (2 - index) * 150 }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: Lyrics.status === "instrumental"
        text: "Instrumental"
        color: Colors.textOnSurfaceVariant
        font.family: Theme.font.family
        font.pixelSize: Theme.lyrics.fontSize
        font.weight: Font.Bold
        opacity: Theme.lyrics.nearOpacity
    }
}
