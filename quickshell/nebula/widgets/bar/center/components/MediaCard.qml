import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: root

    property bool expanded: false
    readonly property real artX: cardTop.x + artSlot.x
    readonly property real artY: cardTop.y + artSlot.y
    readonly property alias artSlot: artSlot

    enabled: expanded
    opacity: expanded ? 1 : 0
    spacing: Theme.spacing.md

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: root.expanded ? Theme.anim.fast : 0 }
            NumberAnimation { duration: root.expanded ? Theme.anim.medium : Theme.anim.fast }
        }
    }

    RowLayout {
        id: cardTop
        Layout.fillWidth: true
        spacing: Theme.spacing.md

        Item {
            id: artSlot
            implicitWidth: 80
            implicitHeight: 80
        }

        ColumnLayout {
            Layout.preferredWidth: Theme.lyrics.titleWidth
            Layout.fillWidth: false
            spacing: 2

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: Media.title
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: Media.artist
                color: Colors.textOnSurfaceVariant
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
            }

        }

        LyricsView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Settings.bar.lyrics
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: 20

        WavyProgress {
            anchors.fill: parent
            progress: seekArea.pressed ? seekArea.dragProgress : Media.progress
            animated: Media.playing
            smoothProgress: !seekArea.pressed
        }

        MouseArea {
            id: seekArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            property real dragProgress: 0

            function update(x) { dragProgress = Math.max(0, Math.min(1, x / width)); }

            onPressed: mouse => update(mouse.x)
            onPositionChanged: mouse => update(mouse.x)
            onReleased: Media.seekTo(dragProgress)
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: Media.formatTime(Media.position)
            color: Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }

        Item { Layout.fillWidth: true }

        Text {
            text: Media.formatTime(Media.length)
            color: Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: Theme.bar.gap

        IconButton { icon: "skip_previous"; onClicked: Media.previous() }
        IconButton { icon: Media.playing ? "pause" : "play_arrow"; onClicked: Media.togglePlaying() }
        IconButton { icon: "skip_next"; onClicked: Media.next() }
    }
}
