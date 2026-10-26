import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property bool open: false
    property string art: ""
    property real slide: 0
    property real fade: 1

    readonly property real fullHeight: content.implicitHeight + Theme.media.panelPadding * 2

    signal requestClose()

    HyprlandFocusGrab {
        windows: [root.QsWindow.window]
        active: root.open && !GlobalStates.capturing
        onCleared: root.requestClose()
    }

    ColumnLayout {
        id: content
        x: Theme.media.panelPadding
        y: Theme.media.panelPadding
        width: root.width - Theme.media.panelPadding * 2
        spacing: Theme.spacing.lg

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.xl

            ShapedArt {
                Layout.preferredWidth: Theme.media.artSize
                Layout.preferredHeight: Theme.media.artSize
                shape: MaterialShape.Cookie12Sided
                color: Colors.surfaceContainerHigh
                source: root.art
                sourceSize: Qt.size(Theme.media.artSize * 2, Theme.media.artSize * 2)
                opacity: root.fade * (Media.playing ? 1 : 0.6)
                transform: Translate { x: root.slide / 2 }

                Behavior on opacity {
                    NumberAnimation { duration: Theme.anim.medium }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.requestClose();
                        Media.raise();
                    }
                }
            }

            MirroredCava {
                Layout.preferredWidth: Theme.media.cavaWidth
                Layout.preferredHeight: Theme.media.artSize
                rows: Theme.media.cavaRows
                barHeight: Theme.media.cavaBar
                values: Cava.values
                color: Colors.primary
                visible: Settings.bar.visualizer
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.media.artSize
                spacing: 2
                opacity: root.fade
                transform: Translate { x: root.slide }

                LyricsView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    anchorLine: Theme.media.lyricsAnchor
                    visible: Settings.bar.lyrics && Lyrics.status !== "none"
                }

                Item {
                    Layout.fillHeight: true
                    visible: !Settings.bar.lyrics || Lyrics.status === "none"
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.md

            Text {
                text: Media.formatTime(Media.position)
                color: Colors.textOnSurfaceVariant
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
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
