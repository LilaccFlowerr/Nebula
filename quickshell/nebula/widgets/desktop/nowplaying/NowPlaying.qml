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
    property string shapeName: "Cookie12Sided"
    property string colorRole: "secondary"
    readonly property var palette: Widgets.palette(colorRole)
    property real baseSize: Theme.nowPlaying.cookieSize
    readonly property real ratio: baseSize / Theme.nowPlaying.cookieSize
    property real size: empty ? baseSize * Theme.nowPlaying.emptySize / Theme.nowPlaying.cookieSize : baseSize
    property bool live: true
    property real spin: 0
    property real speed: playing && live && Settings.nowPlaying.spin && !Settings.theme.reduceMotion ? 360 / Settings.nowPlaying.spinSeconds : 0

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
            duration: Math.round(Theme.nowPlaying.spinUpDuration * Theme.anim.scale)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    FrameAnimation {
        running: root.playing && root.speed > 0
        onTriggered: root.spin = (root.spin + root.speed * frameTime) % 360
    }

    property real designInner: 0.4
    property real innerTarget: 0.4
    property real innerRatio: innerTarget
    readonly property real fit: Math.max(0.45, Math.min(1.1, innerRatio / designInner))

    function leastDistance(item) {
        let least = item.width / 2;
        for (let a = 0; a < 360; a += 4) least = Math.min(least, item.distanceAtAngle(a));
        return least / item.width;
    }

    function remeasure() {
        if (probe.width <= 0 || design.width <= 0) return;
        designInner = Math.max(0.2, leastDistance(design));
        innerTarget = Math.max(0.15, leastDistance(probe));
    }

    function upright() {
        settle.to = spin >= 180 ? 360 : 0;
        settle.restart();
    }

    onPlayingChanged: {
        if (playing) {
            settle.stop();
            return;
        }
        upright();
    }

    NumberAnimation {
        id: settle
        target: root
        property: "spin"
        duration: Theme.anim.slow
        easing.type: Easing.OutBack
        easing.overshoot: Theme.anim.overshoot
        onFinished: root.spin = 0
    }

    MaterialShape {
        id: body
        anchors.fill: parent
        shape: root.empty ? MaterialShape.Sunny : root.playing ? (MaterialShape[root.shapeName] ?? MaterialShape.Cookie12Sided) : MaterialShape.Pentagon
        color: root.palette.fill
        rotation: root.spin
        animationDuration: Theme.anim.slow
        animationEasing.type: Easing.OutBack
        animationEasing.overshoot: Theme.anim.overshoot
    }

    Text {
        anchors.centerIn: parent
        text: "music_note"
        font.family: Theme.font.icons
        font.pixelSize: Theme.nowPlaying.emptyIconSize * root.ratio
        color: root.palette.text
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

    MaterialShape {
        id: probe
        width: 200
        height: 200
        visible: false
        shape: body.shape
        animationDuration: 0

        onShapeChanged: Qt.callLater(root.remeasure)
        Component.onCompleted: Qt.callLater(root.remeasure)
    }

    MaterialShape {
        id: design
        width: 200
        height: 200
        visible: false
        shape: MaterialShape.Cookie12Sided
        animationDuration: 0

        Component.onCompleted: Qt.callLater(root.remeasure)
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing.xs
        opacity: root.empty ? 0 : 1
        scale: (root.empty ? 0.6 : 1) * root.ratio * root.fit
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
            color: root.palette.text
        }

        Text {
            Layout.preferredWidth: Theme.nowPlaying.textWidth
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: Media.artist
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            color: root.palette.text
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
            animated: root.playing && root.live
        }
    }
}
