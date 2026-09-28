import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
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
    readonly property int mediaTextWidth: 220
    readonly property int waveWidth: 200
    readonly property int cardWidth: 380

    property bool expanded: false
    readonly property bool isExpanded: expanded && showMedia

    implicitHeight: pill.height + (Theme.bar.height - Theme.button.size)

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

    HyprlandFocusGrab {
        windows: [root.QsWindow.window]
        active: root.isExpanded
        onCleared: root.expanded = false
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: (Theme.bar.height - Theme.button.size) / 2

        implicitWidth: root.isExpanded ? root.cardWidth + Theme.spacing.lg * 2
                     : root.empty ? Theme.button.size
                     : (root.event === "volume" ? osd.implicitWidth
                        : root.batteryEvent ? battery.implicitWidth
                        : root.showMedia ? media.implicitWidth
                        : content.implicitWidth) + Theme.spacing.lg * 2
        implicitHeight: root.isExpanded ? card.implicitHeight + Theme.spacing.lg * 2 : Theme.button.size
        radius: root.isExpanded ? Theme.radius.large : Theme.radius.full
        color: Colors.surfaceContainer
        clip: true

        Behavior on implicitHeight {
            NumberAnimation {
                duration: Theme.anim.island
                easing.type: Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: root.showMedia ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (root.showMedia) root.expanded = true
        }

        Behavior on implicitWidth {
            enabled: !textWidthAnim.running
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
            opacity: root.isExpanded ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.fast }
            }
            anchors.centerIn: parent
            spacing: Theme.spacing.sm

            property real textWidth: Media.playing ? root.mediaTextWidth
                : Math.min(root.mediaTextWidth, Math.max(mediaTitle.implicitWidth, mediaArtist.implicitWidth))

            Behavior on textWidth {
                NumberAnimation {
                    id: textWidthAnim
                    duration: Theme.anim.island
                    easing.type: Easing.OutBack
                    easing.overshoot: Theme.anim.overshoot
                }
            }

            Item {
                id: smallArtSlot
                implicitWidth: 28
                implicitHeight: 28
            }

            ColumnLayout {
                Layout.preferredWidth: media.textWidth
                spacing: 0

                Text {
                    id: mediaTitle
                    Layout.maximumWidth: media.textWidth
                    elide: Text.ElideRight
                    text: Media.title
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }

                Text {
                    id: mediaArtist
                    Layout.maximumWidth: media.textWidth
                    elide: Text.ElideRight
                    text: Media.artist
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                }
            }
            WavyProgress {
                implicitWidth: root.waveWidth
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

        ColumnLayout {
            id: card
            visible: root.showMedia
            enabled: root.isExpanded
            opacity: root.isExpanded ? 1 : 0

            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: root.isExpanded ? Theme.anim.fast : 0 }
                    NumberAnimation { duration: root.isExpanded ? Theme.anim.medium : Theme.anim.fast }
                }
            }
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.spacing.lg
            width: root.cardWidth
            spacing: Theme.spacing.md

            RowLayout {
                id: cardTop
                spacing: Theme.spacing.md

                Item {
                    id: bigArtSlot
                    implicitWidth: 80
                    implicitHeight: 80
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: Media.title
                        color: Colors.textOnSurface
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: Media.artist
                        color: Colors.textOnSurfaceVariant
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                    }
                }
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

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: Media.formatTime(Media.position)
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                }

                Item { Layout.fillWidth: true }

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

                IconButton { icon: "skip_previous"; onClicked: Media.previous() }
                IconButton { icon: Media.playing ? "pause" : "play_arrow"; onClicked: Media.togglePlaying() }
                IconButton { icon: "skip_next"; onClicked: Media.next() }
            }
        }

        ClippingRectangle {
            id: art
            visible: root.showMedia

            property real t: root.isExpanded ? 1 : 0

            Behavior on t {
                NumberAnimation {
                    duration: Theme.anim.island
                    easing.type: Easing.OutBack
                    easing.overshoot: Theme.anim.overshoot
                }
            }

            readonly property real smallX: media.x + smallArtSlot.x
            readonly property real smallY: media.y + smallArtSlot.y
            readonly property real bigX: card.x + cardTop.x + bigArtSlot.x
            readonly property real bigY: card.y + cardTop.y + bigArtSlot.y

            x: smallX + (bigX - smallX) * t
            y: smallY + (bigY - smallY) * t
            width: smallArtSlot.width + (bigArtSlot.width - smallArtSlot.width) * t
            height: width
            radius: Theme.radius.small + (Theme.radius.medium - Theme.radius.small) * t
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
    }
}
