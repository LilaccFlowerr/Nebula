import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: root

    property bool expanded: false
    property string trackTitle: ""
    property string trackArtist: ""
    property real slide: 0
    property real fade: 1
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
            opacity: root.fade
            transform: Translate { x: root.slide }

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.trackTitle
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
            }

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.trackArtist
                color: Colors.textOnSurfaceVariant
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
            }

        }

        LyricsView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Settings.bar.lyrics && Lyrics.status !== "none"
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

        IconButton {
            id: previousButton
            icon: "skip_previous"
            onClicked: {
                root.nudge(previousButton, -1);
                Media.previous();
            }
        }
        PlayButton {
            playing: Media.playing
            onClicked: Media.togglePlaying()
        }
        IconButton {
            id: nextButton
            icon: "skip_next"
            onClicked: {
                root.nudge(nextButton, 1);
                Media.next();
            }
        }
    }

    function nudge(button, direction) {
        nudgeAnim.stop();
        if (nudgeAnim.button) nudgeAnim.button.iconOffset = 0;
        nudgeAnim.button = button;
        nudgeAnim.direction = direction;
        nudgeAnim.start();
    }

    SequentialAnimation {
        id: nudgeAnim

        property Item button
        property int direction: 1

        NumberAnimation { target: nudgeAnim.button; property: "iconOffset"; to: nudgeAnim.direction * Theme.bar.skipNudge; duration: Theme.anim.fast; easing.type: Easing.OutCubic }
        NumberAnimation { target: nudgeAnim.button; property: "iconOffset"; to: 0; duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
}
