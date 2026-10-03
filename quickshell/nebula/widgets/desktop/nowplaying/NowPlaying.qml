import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    readonly property bool playing: Media.playing
    property real spin: 0
    property real speed: playing ? 360000 / Theme.nowPlaying.spinDuration : 0

    implicitWidth: Theme.nowPlaying.cookieSize
    implicitHeight: Theme.nowPlaying.cookieSize

    Behavior on speed {
        NumberAnimation {
            duration: Theme.nowPlaying.coastDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    FrameAnimation {
        running: root.speed > 0
        onTriggered: root.spin = (root.spin + root.speed * frameTime) % 360
    }

    ShapedImage {
        anchors.fill: parent
        shape: "cookie12"
        placeholderColor: Colors.secondaryContainer
        rotation: root.spin
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing.xs

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
