import QtQuick
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property real morph: 0
    readonly property real fade: Math.max(0, Math.min(1, (morph - 0.35) / 0.3))

    GlassRect {
        anchors.fill: parent
        radius: Math.min(height / 2.4, 46 - 14 * Math.min(1, root.morph))
        fill: Colors.primaryContainer
        tint: Theme.lock.surfaceTint
        light: 0
    }

    Item {
        anchors.fill: parent
        opacity: 1 - root.fade
        visible: opacity > 0

        ShapedArt {
            id: art

            x: root.height * 0.14
            anchors.verticalCenter: parent.verticalCenter
            width: root.height * 0.72
            height: width
            color: Colors.primary
            source: Media.artUrl
            sourceSize: Qt.size(width * 2, height * 2)

            FrameAnimation {
                running: Media.playing && art.visible
                onTriggered: art.shapeRotation += frameTime * 15
            }
        }

        Column {
            anchors.left: art.right
            anchors.leftMargin: root.height * 0.16
            anchors.right: parent.right
            anchors.rightMargin: root.height * 0.22
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: Media.title
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large + 2
                font.weight: Font.Medium
                color: Colors.textOnPrimaryContainer
            }

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: Media.artist
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Qt.alpha(Colors.textOnPrimaryContainer, 0.7)
            }

            WavyProgress {
                width: parent.width
                height: 14
                progress: Media.progress
                animated: Media.playing
                color: Colors.primary
            }
        }
    }

    Column {
        anchors.centerIn: parent
        width: root.width - 48
        spacing: 10
        opacity: root.fade
        visible: opacity > 0
        enabled: root.fade > 0.9

        ShapedArt {
            id: bigArt

            anchors.horizontalCenter: parent.horizontalCenter
            width: 124
            height: 124
            color: Colors.primary
            source: Media.artUrl
            sourceSize: Qt.size(width * 2, height * 2)

            FrameAnimation {
                running: Media.playing && bigArt.visible
                onTriggered: bigArt.shapeRotation += frameTime * 15
            }
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: Media.title
            font.family: Theme.font.family
            font.pixelSize: Theme.font.large + 2
            font.weight: Font.Medium
            color: Colors.textOnPrimaryContainer
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: Media.artist
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: Qt.alpha(Colors.textOnPrimaryContainer, 0.7)
        }

        WavyProgress {
            width: parent.width
            height: 14
            progress: Media.progress
            animated: Media.playing
            color: Colors.primary
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "skip_previous"
                onClicked: Media.previous()
            }

            PlayButton {
                anchors.verticalCenter: parent.verticalCenter
                playing: Media.playing
                onClicked: Media.togglePlaying()
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "skip_next"
                onClicked: Media.next()
            }
        }
    }
}
