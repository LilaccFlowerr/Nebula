import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme
import qs.widgets.bar.center.components

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

    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property bool isExpanded: GlobalStates.mediaExpanded && GlobalStates.isOn(screenName) && Media.active

    implicitHeight: pill.height + (Theme.bar.height - Theme.button.size)

    property string event: ""
    property bool armed: false

    readonly property bool showEvent: event !== ""
    readonly property bool levelEvent: event === "volume" || event === "brightness"
    readonly property bool batteryEvent: event === "charging" || event === "unplugged" || event === "low"

    readonly property bool showMedia: Media.active && (!showEvent || isExpanded)
    readonly property bool mediaEvent: Media.active && showEvent && !isExpanded
    readonly property bool showNotification: event === "notification" && !isExpanded
    readonly property bool showBubble: event === "notification" && isExpanded
    readonly property bool notificationOpen: (showNotification && pillHover.hovered) || (showBubble && bubble.hovered)
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
        active: root.isExpanded && !GlobalStates.capturing
        onCleared: GlobalStates.mediaExpanded = false
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
        target: Brightness
        function onCurrentChanged() { root.popEvent("brightness"); }
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

    NotificationBubble {
        id: bubble
        anchors.top: pill.bottom
        anchors.topMargin: Theme.spacing.sm + offset
        anchors.horizontalCenter: parent.horizontalCenter
        shown: root.showBubble
        open: root.notificationOpen
    }

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.pillMargin

        implicitWidth: root.isExpanded ? root.cardWidth + Theme.spacing.lg * 2
                     : root.showNotification ? Theme.bar.notificationWidth
                     : Math.max(root.minPillWidth, (root.levelEvent ? osd.implicitWidth
                        : root.batteryEvent ? battery.implicitWidth
                        : root.showMedia ? media.implicitWidth
                        : root.empty ? emptyContent.implicitWidth
                        : windowContent.implicitWidth) + Theme.spacing.lg * 2)
        implicitHeight: root.isExpanded ? card.implicitHeight + Theme.spacing.lg * 2
                      : root.showNotification ? notif.implicitHeight + Theme.spacing.md * 2
                      : Theme.button.size
        radius: root.isExpanded || root.showNotification ? Theme.radius.large : Theme.radius.full
        color: Colors.surfaceContainer
        border.width: root.showNotification && Notifications.urgent ? 2 : 0
        border.color: Colors.errorColor
        clip: true

        Behavior on implicitHeight {
            NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on implicitWidth {
            enabled: !media.resizing
            NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        HoverHandler {
            id: pillHover
        }

        Binding {
            target: Notifications
            property: "paused"
            value: root.notificationOpen
        }

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

        MouseArea {
            anchors.fill: parent
            cursorShape: root.showMedia || root.showNotification ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (root.showNotification) Notifications.activate();
                else if (root.showMedia && !root.isExpanded) GlobalStates.toggleMedia(root.screenName);
            }
        }

        EmptyContent {
            id: emptyContent
            anchors.centerIn: parent
            visible: root.empty
        }

        WindowContent {
            id: windowContent
            anchors.centerIn: parent
            visible: root.showWindow
            maxTitleWidth: root.maxTitleWidth
        }

        MediaRow {
            id: media
            anchors.centerIn: parent
            visible: root.showMedia
            opacity: root.isExpanded ? 0 : 1
            maxTextWidth: root.mediaTextWidth
            waveWidth: root.waveWidth

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.fast }
            }
        }

        LevelOsd {
            id: osd
            anchors.centerIn: parent
            kind: root.event === "brightness" ? "brightness" : "volume"
            visible: root.levelEvent
        }

        BatteryEvent {
            id: battery
            anchors.centerIn: parent
            visible: root.batteryEvent
            event: root.event
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

        MediaCard {
            id: card
            visible: root.showMedia
            expanded: root.isExpanded
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.spacing.lg
            width: root.cardWidth
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

            readonly property real smallX: media.x + media.artSlot.x
            readonly property real smallY: media.y + media.artSlot.y
            readonly property real bigX: card.x + card.artX
            readonly property real bigY: card.y + card.artY

            property real e: root.mediaEvent ? 1 : 0

            Behavior on e {
                NumberAnimation {
                    duration: Theme.anim.island
                    easing.type: Easing.OutBack
                    easing.overshoot: Theme.anim.overshoot
                }
            }

            readonly property Item eventSlot: root.lastEvent === "volume" || root.lastEvent === "brightness" ? osd.artSlot
                                            : root.lastEvent === "notification" ? notif.artSlot
                                            : battery.artSlot
            readonly property real eventX: root.lastEvent === "notification" ? notif.x + notif.artX : eventSlot.parent.x + eventSlot.x
            readonly property real eventY: root.lastEvent === "notification" ? notif.y + notif.artY : eventSlot.parent.y + eventSlot.y

            readonly property real baseX: smallX + (bigX - smallX) * t
            readonly property real baseY: smallY + (bigY - smallY) * t
            readonly property real baseSize: media.artSlot.width + (card.artSlot.width - media.artSlot.width) * t

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
