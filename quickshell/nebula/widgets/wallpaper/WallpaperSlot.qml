import QtQuick
import QtMultimedia
import qs.services

Item {
    id: root

    property url source
    property bool playing: true
    readonly property bool video: Wallpaper.isVideo(source)
    readonly property bool ready: video ? videoReady : image.status === Image.Ready
    readonly property bool failed: video ? videoFailed : image.status === Image.Error
    property bool videoReady: false
    property bool videoFailed: false

    onSourceChanged: {
        videoReady = false;
        videoFailed = false;
    }

    Image {
        id: image
        anchors.fill: parent
        source: root.video ? "" : root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: root.width
        sourceSize.height: root.height
    }

    Loader {
        anchors.fill: parent
        active: root.video && String(root.source) !== ""

        sourceComponent: Item {
            VideoOutput {
                id: output
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }

            MediaPlayer {
                id: player
                source: root.source
                videoOutput: output
                loops: MediaPlayer.Infinite
                onMediaStatusChanged: if (mediaStatus === MediaPlayer.BufferedMedia) root.videoReady = true
                onErrorOccurred: (error, message) => {
                    console.warn("Wallpaper video:", message);
                    root.videoFailed = true;
                }
                Component.onCompleted: root.playing ? play() : pause()
            }

            Connections {
                target: root
                function onPlayingChanged() { root.playing ? player.play() : player.pause(); }
            }
        }
    }
}
