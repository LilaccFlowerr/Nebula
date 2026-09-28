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

    property string event: ""
    property bool armed: false

    readonly property bool showEvent: event !== ""
    readonly property bool batteryEvent: event === "charging" || event === "unplugged" || event === "low"

    readonly property bool showMedia: Media.active && !showEvent
    readonly property bool showWindow: ActiveWindow.hasWindow && !showMedia && !showEvent
    readonly property bool empty: !showWindow && !showMedia && !showEvent

    Timer {
        interval: 1000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: eventTimer
        onTriggered: root.event = ""
    }

    function popEvent(name, duration = 1500) {
        if (!armed) return;
        event = name;
        eventTimer.interval = duration;
        eventTimer.restart();
    }

    Connections {
        target: Audio
        function onVolumeChanged() { root.popEvent("volume"); }
        function onMutedChanged() { root.popEvent("volume"); }
    }

    Connections {
        target: Battery
        function onPluggedInChanged() { root.popEvent(Battery.pluggedIn ? "charging" : "unplugged", 2500); }
        function onLowChanged() { if (Battery.low) root.popEvent("low", 4000); }
    }

    Rectangle {
        id: pill
        anchors.centerIn: parent

        implicitWidth: root.empty ? Theme.button.size
                     : (root.event === "volume" ? osd.implicitWidth
                        : root.batteryEvent ? battery.implicitWidth
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
                    opacity: Media.playing ? 1 : 0.5

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.anim.medium }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "pause"
                    font.family: Theme.font.icons
                    font.pixelSize: 18
                    color: Colors.textOnSurface
                    opacity: Media.playing ? 0 : 1
                    scale: Media.playing ? 0.6 : 1

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.anim.medium }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.anim.medium
                            easing.type: Easing.OutBack
                        }
                    }
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
            visible: root.event === "volume"
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

        RowLayout {
            id: battery
            visible: root.batteryEvent
            anchors.centerIn: parent
            spacing: Theme.spacing.sm

            readonly property color accent: root.event === "low" ? Colors.errorColor
                                          : root.event === "charging" ? Colors.primary
                                          : Colors.textOnSurface

            Text {
                text: root.event === "charging" ? "bolt"
                    : root.event === "low" ? "battery_alert"
                    : "battery_full"
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: battery.accent
            }

            Text {
                text: root.event === "charging" ? "Charging"
                    : root.event === "low" ? "Battery low"
                    : "On battery"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Colors.textOnSurface
            }

            Text {
                text: Battery.percent + "%"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: battery.accent
            }
        }
    }
}
