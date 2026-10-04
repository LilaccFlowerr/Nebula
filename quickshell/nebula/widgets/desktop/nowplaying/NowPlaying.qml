import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    readonly property bool playing: Media.playing
    readonly property bool empty: !Media.active
    property real size: empty ? Theme.nowPlaying.emptySize : Theme.nowPlaying.cookieSize
    property real spin: 0
    property real speed: playing ? 360000 / Theme.nowPlaying.spinDuration : 0

    implicitWidth: size
    implicitHeight: size

    Behavior on size {
        NumberAnimation {
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    Behavior on speed {
        NumberAnimation {
            duration: Theme.nowPlaying.spinUpDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    FrameAnimation {
        running: root.playing && root.speed > 0
        onTriggered: root.spin = (root.spin + root.speed * frameTime) % 360
    }

    MaterialShape {
        anchors.fill: parent
        shape: root.empty ? MaterialShape.Sunny : root.playing ? MaterialShape.Cookie12Sided : MaterialShape.Pentagon
        color: Colors.secondaryContainer
        rotation: root.spin
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.OutBack
        animationEasing.overshoot: Theme.anim.overshoot
    }

    Text {
        anchors.centerIn: parent
        text: "music_note"
        font.family: Theme.font.icons
        font.pixelSize: Theme.nowPlaying.emptyIconSize
        color: Colors.textOnSecondaryContainer
        opacity: root.empty ? 1 : 0
        scale: root.empty ? 1 : 0.4

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.medium }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.anim.island
                easing.type: Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing.xs
        opacity: root.empty ? 0 : 1
        scale: root.empty ? 0.6 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.anim.island
                easing.type: Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }
        }

        ClippingRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Theme.spacing.xs
            implicitWidth: Theme.nowPlaying.artSize
            implicitHeight: Theme.nowPlaying.artSize
            radius: Theme.radius.large
            color: Colors.surfaceContainer

            Image {
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: root.playing ? 1 : 0.5

                Behavior on opacity {
                    NumberAnimation { duration: Theme.anim.medium }
                }
            }
        }

        Text {
            Layout.preferredWidth: Theme.nowPlaying.textWidth
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: Media.title
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            font.weight: Font.DemiBold
            color: Colors.textOnSecondaryContainer
        }

        Text {
            Layout.preferredWidth: Theme.nowPlaying.textWidth
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: Media.artist
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            color: Colors.textOnSecondaryContainer
            opacity: 0.75
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacing.xs

            IconButton {
                icon: "skip_previous"
                onClicked: Media.previous()
            }

            IconButton {
                icon: root.playing ? "pause" : "play_arrow"
                onClicked: Media.togglePlaying()
            }

            IconButton {
                icon: "skip_next"
                onClicked: Media.next()
            }
        }

        WavyProgress {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Theme.nowPlaying.progressWidth
            implicitHeight: Theme.spacing.lg
            progress: Media.progress
            animated: root.playing
        }
    }
}
