import QtQuick
import qs.services
import qs.theme

Item {
    id: root

    ListView {
        id: lyricsView
        anchors.fill: parent
        visible: Lyrics.synced
        clip: true
        interactive: false

        model: Lyrics.lines
        currentIndex: Math.max(0, Lyrics.currentIndex)
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: Theme.lyrics.lineHeight
        preferredHighlightEnd: Theme.lyrics.lineHeight * 2
        highlightMoveDuration: Theme.anim.medium

        delegate: Text {
            required property var modelData
            required property int index
            readonly property bool current: index === Lyrics.currentIndex

            width: lyricsView.width
            height: Theme.lyrics.lineHeight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: modelData.text || "♪"
            color: current ? Colors.primary : Colors.textOnSurfaceVariant
            opacity: current ? 1 : 0.6
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            font.weight: current ? Font.DemiBold : Font.Normal

            Behavior on color {
                ColorAnimation { duration: Theme.anim.medium }
            }
            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.medium }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Lyrics.seekToLine(index)
            }
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        visible: Lyrics.status === "loading"
        spacing: Theme.spacing.xs

        Repeater {
            model: 3

            Rectangle {
                required property int index
                width: 6
                height: 6
                radius: 3
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
        anchors.verticalCenter: parent.verticalCenter
        visible: Lyrics.status === "instrumental"
        text: "Instrumental"
        color: Colors.textOnSurfaceVariant
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
        font.italic: true
    }
}
