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
    implicitWidth: Math.max(Theme.bar.centerMinWidth, pill.implicitWidth + pillMargin * 2)

    readonly property real pillMargin: (Theme.bar.height - Theme.button.size) / 2
    readonly property real minPillWidth: Theme.bar.centerMinWidth - pillMargin * 2

    readonly property int maxTitleWidth: 360
    readonly property int mediaTextWidth: 220
    readonly property int waveWidth: 200
    readonly property int cardWidth: 440

    property bool expanded: false
    readonly property bool isExpanded: expanded && Media.active

    implicitHeight: pill.height + (Theme.bar.height - Theme.button.size)

    property string event: ""
    property bool armed: false

    readonly property bool showEvent: event !== ""
    readonly property bool batteryEvent: event === "charging" || event === "unplugged" || event === "low"

    readonly property bool showMedia: Media.active && (!showEvent || isExpanded)
    readonly property bool mediaEvent: Media.active && showEvent && !isExpanded
    readonly property bool showNotification: event === "notification" && !isExpanded
    readonly property bool showBubble: event === "notification" && isExpanded
    readonly property bool notificationOpen: (showNotification && pillHover.hovered) || (showBubble && bubbleHover.hovered)
    property alias bubble: bubble
    property string lastEvent: ""
    onEventChanged: if (event !== "") lastEvent = event
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
        onTriggered: root.event = Notifications.current ? "notification" : ""
    }

    function popEvent(name, duration = 1500) {
        if (!armed || Notifications.current || isExpanded) return;
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
        target: Notifications
        function onCurrentChanged() {
            if (Notifications.current) {
                eventTimer.stop();
                root.event = "notification";
            } else if (root.event === "notification") {
                root.event = "";
            }
        }
    }

    Connections {
        target: Battery
        function onPluggedInChanged() { root.popEvent(Battery.pluggedIn ? "charging" : "unplugged", 2500); }
        function onLowChanged() { if (Battery.low) root.popEvent("low", 4000); }
    }

    Rectangle {
        id: bubble
        anchors.top: pill.bottom
        anchors.topMargin: Theme.spacing.sm + (root.showBubble ? 0 : -Theme.spacing.lg)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.bar.notificationWidth
        height: root.showBubble ? bubbleContent.implicitHeight + Theme.spacing.md * 2 : 0
        radius: Theme.radius.large
        color: Qt.alpha(Colors.surface, Theme.bar.opacity)
        border.width: Notifications.urgent ? 2 : 0
        border.color: Colors.errorColor
        opacity: root.showBubble ? 1 : 0
        scale: root.showBubble ? 1 : 0.9
        visible: opacity > 0
        clip: true

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on anchors.topMargin {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on height {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        HoverHandler {
            id: bubbleHover
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Notifications.activate()
        }

        NotificationContent {
            id: bubbleContent
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.md
            n: Notifications.current
            open: root.notificationOpen
        }
    }

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.pillMargin

        implicitWidth: root.isExpanded ? root.cardWidth + Theme.spacing.lg * 2
                     : root.showNotification ? Theme.bar.notificationWidth
                     : Math.max(root.minPillWidth, (root.event === "volume" ? osd.implicitWidth
                        : root.batteryEvent ? battery.implicitWidth
                        : root.showMedia ? media.implicitWidth
                        : root.empty ? emptyContent.implicitWidth
                        : content.implicitWidth) + Theme.spacing.lg * 2)
        implicitHeight: root.isExpanded ? card.implicitHeight + Theme.spacing.lg * 2
                      : root.showNotification ? notif.implicitHeight + Theme.spacing.md * 2
                      : Theme.button.size
        radius: root.isExpanded || root.showNotification ? Theme.radius.large : Theme.radius.full

        Visualizer {
            anchors.fill: parent
            anchors.leftMargin: parent.height / 2
            anchors.rightMargin: parent.height / 2
            visible: root.showMedia && !root.isExpanded
            opacity: Theme.visualizer.pillOpacity
            barWidth: Theme.visualizer.barWidth
            count: Cava.bars
            values: Cava.values
        }

        Visualizer {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spacing.lg
            height: Theme.visualizer.cardHeight
            opacity: root.isExpanded ? Theme.visualizer.pillOpacity : 0
            visible: opacity > 0
            barWidth: Theme.visualizer.barWidth
            count: Cava.bars
            values: Cava.values

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.medium }
            }
        }

        HoverHandler {
            id: pillHover
        }

        Binding {
            target: Notifications
            property: "paused"
            value: root.notificationOpen
        }
        color: Colors.surfaceContainer
        border.width: root.showNotification && Notifications.urgent ? 2 : 0
        border.color: Colors.errorColor
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
            cursorShape: root.showMedia || root.showNotification ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (root.showNotification) Notifications.activate();
                else if (root.showMedia) root.expanded = true;
            }
        }

        Behavior on implicitWidth {
            enabled: !textWidthAnim.running
            NumberAnimation {
                duration: Theme.anim.island
                easing.type: Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }
        }

        RowLayout {
            id: emptyContent
            anchors.centerIn: parent
            visible: root.empty
            spacing: Theme.spacing.sm

            Text {
                text: SystemInfo.osLogo
                font.family: Theme.font.logos
                font.pixelSize: Theme.button.iconSize
                color: Colors.textOnSurface
            }

            Text {
                text: Time.date
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
            }
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

            Item {
                id: osdArtSlot
                visible: Media.active
                implicitWidth: Theme.bar.eventArtSize
                implicitHeight: Theme.bar.eventArtSize
            }

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

        NotificationContent {
            id: notif
            visible: root.showNotification
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.md
            n: Notifications.current
            open: root.notificationOpen
        }

        RowLayout {
            id: battery
            visible: root.batteryEvent
            anchors.centerIn: parent
            spacing: Theme.spacing.sm

            Item {
                id: batteryArtSlot
                visible: Media.active
                implicitWidth: Theme.bar.eventArtSize
                implicitHeight: Theme.bar.eventArtSize
            }

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
                Layout.fillWidth: true
                spacing: Theme.spacing.md

                Item {
                    id: bigArtSlot
                    implicitWidth: 80
                    implicitHeight: 80
                }

                ColumnLayout {
                    Layout.preferredWidth: Theme.lyrics.titleWidth
                    Layout.fillWidth: false
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

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: lyricsView
                        anchors.fill: parent
                        visible: Lyrics.synced
                        clip: true
                        interactive: false

                        model: Lyrics.lines
                        currentIndex: Math.max(0, Lyrics.currentIndex)
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        preferredHighlightBegin: Theme.lyrics.lineHeight
                        preferredHighlightEnd: Theme.lyrics.lineHeight * 2
                        highlightMoveDuration: Theme.anim.medium

                        delegate: Text {
                            required property var modelData
                            required property int index
                            readonly property bool current: index === Lyrics.currentIndex

                            width: lyricsView.width
                            height: Theme.lyrics.lineHeight
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            text: modelData.text || "♪"
                            color: current ? Colors.primary : Colors.textOnSurfaceVariant
                            opacity: current ? 1 : 0.6
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            font.weight: current ? Font.DemiBold : Font.Normal

                            Behavior on color {
                                ColorAnimation { duration: Theme.anim.medium }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: Theme.anim.medium }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Lyrics.seekToLine(index)
                            }
                        }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Lyrics.status === "loading"
                        spacing: Theme.spacing.xs

                        Repeater {
                            model: 3

                            Rectangle {
                                required property int index
                                width: 6
                                height: 6
                                radius: 3
                                color: Colors.textOnSurfaceVariant

                                SequentialAnimation on opacity {
                                    running: Lyrics.status === "loading"
                                    loops: Animation.Infinite
                                    PauseAnimation { duration: index * 150 }
                                    NumberAnimation { from: 0.3; to: 1; duration: 400; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 1; to: 0.3; duration: 400; easing.type: Easing.InOutSine }
                                    PauseAnimation { duration: (2 - index) * 150 }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Lyrics.status === "instrumental"
                        text: "Instrumental"
                        color: Colors.textOnSurfaceVariant
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        font.italic: true
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
            visible: Media.active && (root.showMedia || root.mediaEvent || e > 0)

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

            property real e: root.mediaEvent ? 1 : 0

            Behavior on e {
                NumberAnimation {
                    duration: Theme.anim.island
                    easing.type: Easing.OutBack
                    easing.overshoot: Theme.anim.overshoot
                }
            }

            readonly property Item eventSlot: root.lastEvent === "volume" ? osdArtSlot
                                            : root.lastEvent === "notification" ? notif.artSlot
                                            : batteryArtSlot
            readonly property real eventX: root.lastEvent === "notification" ? notif.x + notif.artX : eventSlot.parent.x + eventSlot.x
            readonly property real eventY: root.lastEvent === "notification" ? notif.y + notif.artY : eventSlot.parent.y + eventSlot.y

            readonly property real baseX: smallX + (bigX - smallX) * t
            readonly property real baseY: smallY + (bigY - smallY) * t
            readonly property real baseSize: smallArtSlot.width + (bigArtSlot.width - smallArtSlot.width) * t

            x: baseX + (eventX - baseX) * e
            y: baseY + (eventY - baseY) * e
            width: baseSize + (eventSlot.width - baseSize) * e
            height: width
            readonly property real baseRadius: Theme.radius.small + (Theme.radius.medium - Theme.radius.small) * t
            readonly property real eventRadius: root.lastEvent === "notification" ? width / 2 : Theme.radius.small
            radius: baseRadius + (eventRadius - baseRadius) * e
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
