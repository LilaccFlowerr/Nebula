import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.components
import qs.services
import qs.widgets.bar.media
import qs.theme

Item {
    id: root

    property real morph: 0
    property real spin: 0

    readonly property real fade: Math.max(0, Math.min(1, (morph - 0.35) / 0.3))
    readonly property real bgFade: Math.max(0, Math.min(1, morph * 2))
    readonly property real idleFade: 1 - Math.max(0, Math.min(1, morph * 3))
    readonly property real corner: 32
    readonly property var bars: {
        const v = Cava.values;
        const n = Theme.lock.visualizerBars;
        const out = [];
        for (let j = 0; j < n; j++) {
            const a = Math.floor(j * v.length / n);
            const b = Math.max(a + 1, Math.floor((j + 1) * v.length / n));
            let sum = 0;
            let count = 0;
            for (let i = a; i < b && i < v.length; i++) {
                sum += v[i];
                count++;
            }
            out.push(count > 0 ? sum / count : 0);
        }
        return out;
    }

    FrameAnimation {
        running: Media.playing && root.visible
        onTriggered: root.spin += frameTime * 15
    }

    Item {
        anchors.fill: parent
        opacity: root.bgFade
        visible: opacity > 0

        Rectangle {
            anchors.fill: parent
            radius: root.corner
            color: Qt.alpha(Colors.primaryContainer, Theme.lock.surfaceTint)
        }

        Rectangle {
            id: mask

            anchors.fill: parent
            radius: root.corner
            visible: false
            layer.enabled: true
        }

        Item {
            id: artLayer

            anchors.fill: parent
            visible: false
            layer.enabled: true

            BlurredArt {
                anchors.fill: parent
                source: Media.artUrl
            }
        }

        MultiEffect {
            anchors.fill: parent
            source: artLayer
            maskEnabled: true
            maskSource: mask
            opacity: 0.9
        }

        Rectangle {
            anchors.fill: parent
            radius: root.corner
            color: Colors.primaryContainer
            opacity: 0.45
        }
    }

    Item {
        id: idle

        readonly property real d: width * 0.68
        readonly property real ringR: d / 2 + 11

        anchors.fill: parent
        opacity: root.idleFade
        visible: opacity > 0

        Shape {
            anchors.fill: parent

            ShapePath {
                strokeColor: Qt.alpha(Colors.textOnSurface, 0.16)
                strokeWidth: 3
                fillColor: "transparent"

                PathAngleArc {
                    centerX: idle.width / 2
                    centerY: idle.ringR + 2
                    radiusX: idle.ringR
                    radiusY: idle.ringR
                    startAngle: 0
                    sweepAngle: 360
                }
            }

            ShapePath {
                strokeColor: Colors.primary
                strokeWidth: 3
                capStyle: ShapePath.RoundCap
                fillColor: "transparent"

                PathAngleArc {
                    centerX: idle.width / 2
                    centerY: idle.ringR + 2
                    radiusX: idle.ringR
                    radiusY: idle.ringR
                    startAngle: -90
                    sweepAngle: 360 * Media.progress
                }
            }
        }

        ShapedArt {
            x: (idle.width - width) / 2
            y: idle.ringR + 2 - height / 2
            width: idle.d
            height: width
            color: Colors.primary
            source: Media.artUrl
            sourceSize: Qt.size(width * 2, height * 2)
            shapeRotation: root.spin
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            y: idle.ringR * 2 + 16
            width: parent.width
            spacing: 2

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: Media.title
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                font.weight: Font.Medium
                color: Colors.textOnSurface
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: Media.artist
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Qt.alpha(Colors.textOnSurface, 0.7)
            }
        }
    }

    Item {
        id: design

        width: Theme.lock.activeMusicWidth
        height: Theme.lock.activeMusicHeight
        scale: root.width / width
        transformOrigin: Item.TopLeft
        opacity: root.fade
        visible: opacity > 0

        Column {
            x: 24
            y: 18
            width: parent.width - 48
            spacing: 6
            enabled: root.fade > 0.9

            ShapedArt {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 84
                height: 84
                color: Colors.primary
                source: Media.artUrl
                sourceSize: Qt.size(width * 2, height * 2)
                shapeRotation: root.spin
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
                color: Qt.alpha(Colors.textOnPrimaryContainer, 0.8)
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

        EqualizerView {
            id: eq

            readonly property var wanted: ["Flat", "Bass", "Vocal", "Rock"]

            x: 12
            y: parent.height - 14 - height
            width: parent.width - 24
            height: Theme.lock.eqHeight
            columns: 19
            rows: 7
            chipNames: wanted.concat(wanted.includes(Equalizer.preset) || Equalizer.preset === "Custom" ? [] : [Equalizer.preset])
            visible: Equalizer.available
            enabled: root.fade > 0.9
        }
    }
}
