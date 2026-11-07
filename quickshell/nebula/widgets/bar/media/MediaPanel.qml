import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import M3Shapes
import qs.components
import qs.services
import qs.theme
import "../../../components/Curves.js" as Curves

Item {
    id: root

    property bool open: false
    property string art: ""
    property real slide: 0
    property real fade: 1

    readonly property real fullHeight: content.implicitHeight + Theme.media.panelPadding * 2

    property real intro: 0
    property bool eqTab: false
    property real tabT: eqTab ? 1 : 0
    readonly property real lyricsOut: Curves.phase(tabT, 0, 0.5)
    readonly property real eqIn: Curves.phase(tabT, 0.35, 0.65)

    Behavior on tabT {
        NumberAnimation {
            duration: Theme.media.tabDuration * Theme.anim.scale
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    readonly property real artIn: Curves.phase(intro, 0, 0.45)
    readonly property real cavaIn: Curves.decel(Curves.phase(intro, 0.15, 0.4))
    readonly property real lyricsIn: Curves.decel(Curves.phase(intro, 0.25, 0.4))
    readonly property real timeIn: Curves.decel(Curves.phase(intro, 0.35, 0.4))
    readonly property real deviceIn: Curves.decel(Curves.phase(intro, 0.45, 0.4))

    function buttonIn(index) {
        return Curves.back(Curves.phase(intro, 0.5 + index * 0.08, 0.3), Theme.anim.overshoot);
    }

    onOpenChanged: {
        if (open) {
            intro = 0;
            introAnim.restart();
        }
    }

    NumberAnimation {
        id: introAnim
        target: root
        property: "intro"
        from: 0
        to: 1
        duration: Theme.media.introDuration * Theme.anim.scale
    }

    property real spin: 0
    property real speed: Media.playing && Settings.nowPlaying.spin && !Settings.theme.reduceMotion ? 360 / Settings.nowPlaying.spinSeconds : 0

    Behavior on speed {
        NumberAnimation {
            duration: Math.round(Theme.nowPlaying.spinUpDuration * Theme.anim.scale)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    FrameAnimation {
        running: root.open && root.speed > 0
        onTriggered: root.spin = (root.spin + root.speed * frameTime) % 360
    }

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
                shape: root.artIn > 0.2 ? MaterialShape.Cookie7Sided : MaterialShape.Circle
                shapeRotation: root.spin
                color: Colors.surfaceContainerHigh
                source: root.art
                sourceSize: Qt.size(Theme.media.artSize * 2, Theme.media.artSize * 2)
                opacity: root.fade * (Media.playing ? 1 : 0.6)
                transform: [
                    Translate { x: root.slide / 2 },
                    Scale {
                        readonly property real s: Theme.media.introArtFrom + (1 - Theme.media.introArtFrom) * Curves.back(root.artIn, Theme.anim.overshoot)
                        origin.x: Theme.media.artSize / 2
                        origin.y: Theme.media.artSize / 2
                        xScale: s
                        yScale: s
                    }
                ]

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

            Item {
                Layout.preferredWidth: Theme.media.cavaWidth * (1 - root.tabT)
                Layout.preferredHeight: Theme.media.artSize
                Layout.rightMargin: -Theme.spacing.xl * root.tabT
                visible: Settings.bar.visualizer && root.tabT < 1
                opacity: 1 - root.lyricsOut
                clip: true

                Item {
                    id: cavaReveal
                    width: parent.width
                    height: parent.height * root.cavaIn
                    anchors.verticalCenter: parent.verticalCenter
                    clip: true

                    MirroredCava {
                        width: Theme.media.cavaWidth
                        height: Theme.media.artSize
                        y: (cavaReveal.height - height) / 2
                        rows: Theme.media.cavaRows
                        barHeight: Theme.media.cavaBar
                        values: Cava.values
                        color: Colors.primary
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.media.artSize
                opacity: root.lyricsIn
                transform: Translate { x: (1 - root.lyricsIn) * Theme.media.introSlide }

                LyricsView {
                    anchors.fill: parent
                    anchorLine: Theme.media.lyricsAnchor
                    visible: Settings.bar.lyrics && Lyrics.status !== "none" && opacity > 0
                    opacity: root.fade * (1 - root.lyricsOut)
                    transform: Translate { x: root.slide - root.lyricsOut * Theme.media.tabSlide }
                }

                EqualizerView {
                    anchors.fill: parent
                    visible: opacity > 0
                    opacity: root.eqIn
                    transform: Translate { x: (1 - root.eqIn) * Theme.media.tabSlide }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.md
            opacity: root.timeIn
            transform: Translate { y: (1 - root.timeIn) * Theme.media.introRise }

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

        Item {
            Layout.fillWidth: true
            implicitHeight: controls.implicitHeight

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.sm
                visible: Audio.ready
                opacity: root.deviceIn

                MaterialShape {
                    width: Theme.media.deviceShapeSize
                    height: Theme.media.deviceShapeSize
                    shape: MaterialShape.Cookie6Sided
                    color: Colors.secondaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: Audio.outputIcon
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.media.deviceIconSize
                        color: Colors.textOnSecondaryContainer
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, Theme.media.deviceMaxWidth)
                    elide: Text.ElideRight
                    text: Audio.outputName
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.media.tabWidth * 2
                height: Theme.media.tabHeight
                radius: height / 2
                color: Qt.alpha(Colors.surfaceContainerHigh, 0.6)
                opacity: root.deviceIn

                Rectangle {
                    x: root.tabT * Theme.media.tabWidth
                    width: Theme.media.tabWidth
                    height: parent.height
                    radius: height / 2
                    color: Colors.secondaryContainer
                }

                Row {
                    Repeater {
                        model: [{ icon: "lyrics", label: "Lyrics", eq: false }, { icon: "equalizer", label: "EQ", eq: true }]

                        Item {
                            id: tab
                            required property var modelData
                            readonly property bool active: root.eqTab === modelData.eq

                            width: Theme.media.tabWidth
                            height: Theme.media.tabHeight

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacing.xs + 2

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: tab.modelData.icon
                                    font.family: Theme.font.icons
                                    font.pixelSize: Theme.media.tabIconSize
                                    color: tab.active ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: tab.modelData.label
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.small
                                    font.weight: 600
                                    color: tab.active ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.eqTab = tab.modelData.eq
                            }
                        }
                    }
                }
            }

            RowLayout {
                id: controls
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.bar.gap

                IconButton {
                    id: previousButton
                    icon: "skip_previous"
                    transform: Scale { origin.x: previousButton.width / 2; origin.y: previousButton.height / 2; xScale: root.buttonIn(0); yScale: root.buttonIn(0) }
                    onClicked: {
                        root.nudge(previousButton, -1);
                        Media.previous();
                    }
                }
                PlayButton {
                    id: playButton
                    playing: Media.playing
                    transform: Scale { origin.x: playButton.width / 2; origin.y: playButton.height / 2; xScale: root.buttonIn(1); yScale: root.buttonIn(1) }
                    onClicked: Media.togglePlaying()
                }
                IconButton {
                    id: nextButton
                    icon: "skip_next"
                    transform: Scale { origin.x: nextButton.width / 2; origin.y: nextButton.height / 2; xScale: root.buttonIn(2); yScale: root.buttonIn(2) }
                    onClicked: {
                        root.nudge(nextButton, 1);
                        Media.next();
                    }
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
