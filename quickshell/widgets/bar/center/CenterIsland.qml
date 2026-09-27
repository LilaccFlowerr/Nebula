import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

Island {
    id: root
    roundLeft: true
    roundRight: true
    implicitWidth: Math.max(Theme.bar.centerMinWidth, pill.implicitWidth + Theme.bar.padding * 2)

    readonly property int maxTitleWidth: 360

    property bool showOsd: false
    property bool armed: false

    readonly property bool showMedia: Media.active && !showOsd
    readonly property bool showWindow: ActiveWindow.hasWindow && !showMedia && !showOsd
    readonly property bool empty: !showWindow && !showMedia && !showOsd

    Timer {
        interval: 1000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.showOsd = false
    }

    function popOsd() {
        if (!armed) return;
        showOsd = true;
        osdTimer.restart();
    }

    Connections {
        target: Audio
        function onVolumeChanged() { root.popOsd(); }
        function onMutedChanged() { root.popOsd(); }
    }

    Rectangle {
        id: pill
        anchors.centerIn: parent

        implicitWidth: root.empty ? Theme.button.size
                     : (root.showOsd ? osd.implicitWidth
                        : root.showMedia ? media.implicitWidth
                        : content.implicitWidth) + Theme.spacing.lg * 2
        implicitHeight: Theme.button.size
        radius: Theme.radius.full
        color: Colors.surfaceContainer
        clip: true

        Behavior on implicitWidth {
            NumberAnimation {
                duration: Theme.anim.island
                easing.type: Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.empty
            text: SystemInfo.osLogo
            font.family: Theme.font.logos
            font.pixelSize: Theme.button.iconSize
            color: Colors.textOnSurface
        }

        RowLayout {
            id: content
            visible: root.showWindow
            anchors.centerIn: parent
            spacing: Theme.spacing.xs

            IconImage {
                source: ActiveWindow.icon
                implicitSize: Theme.button.iconSize
                visible: source !== ""
            }

            Text {
                id: title
                Layout.maximumWidth: root.maxTitleWidth
                elide: Text.ElideRight

                text: ActiveWindow.title
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
            }
        }

        RowLayout {
            id: media
            visible: root.showMedia
            anchors.centerIn: parent
            spacing: Theme.spacing.sm

            ClippingRectangle {
                implicitWidth: 28
                implicitHeight: 28
                radius: Theme.radius.small
                color: Colors.surfaceContainerHigh

                Image {
                    anchors.fill: parent
                    source: Media.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                spacing: 0

                Text {
                    Layout.maximumWidth: root.maxTitleWidth
                    elide: Text.ElideRight
                    text: Media.title
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }

                Text {
                    Layout.maximumWidth: root.maxTitleWidth
                    elide: Text.ElideRight
                    text: Media.artist
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                }
            }
            WavyProgress {
                implicitWidth: 80
                progress: Media.progress
                animated: Media.playing
            }
        }

        RowLayout {
            id: osd
            visible: root.showOsd
            anchors.centerIn: parent
            spacing: Theme.spacing.sm

            Text {
                text: Audio.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: Colors.textOnSurface
            }

            Slider {
                implicitWidth: 140
                value: Audio.volume
                onMoved: Audio.setVolume(value)
            }

            Text {
                Layout.preferredWidth: 32
                horizontalAlignment: Text.AlignRight
                text: Audio.percent + "%"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Colors.textOnSurface
            }
        }
    }
}
