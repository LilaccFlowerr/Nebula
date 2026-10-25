import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import M3Shapes
import qs.components
import qs.widgets.popups.quicksettings
import qs.widgets.popups.calendar
import qs.widgets.popups.tray
import qs.widgets.popups.system
import qs.widgets.popups.osd
import qs.widgets.popups.notifications
import qs.services
import qs.theme

Island {
    id: root
    detach: Theme.bar.rightT
    hookLeft: true
    edgeRight: true
    roundLeft: true

    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property bool powerOpen: GlobalStates.powerMenuOpen && GlobalStates.isOn(screenName)
    readonly property bool settingsOpen: GlobalStates.quickSettingsOpen && GlobalStates.isOn(screenName)
    readonly property bool calendarOpen: GlobalStates.calendarOpen && GlobalStates.isOn(screenName)
    readonly property bool trayOpen: GlobalStates.trayOpen && GlobalStates.isOn(screenName)
    readonly property bool systemOpen: GlobalStates.systemOpen && GlobalStates.isOn(screenName)
    property SystemTrayItem trayMenuItem: null

    onTrayOpenChanged: if (!trayOpen) trayMenuItem = null
    readonly property bool fullSettings: GlobalStates.settingsOpen && GlobalStates.isOn(screenName)
    readonly property real presence: quickSettings.presence
    property alias powerArea: powerArea
    property alias settingsArea: settingsArea
    property alias calendarArea: calendarArea
    property alias trayArea: trayArea
    property alias systemArea: systemArea
    property alias alertArea: alertArea
    readonly property bool anyPopup: powerOpen || settingsOpen || calendarOpen || trayOpen || systemOpen || fullSettings

    HoverHandler { id: islandHover }

    HoverDismiss {
        active: (root.powerOpen || root.settingsOpen || root.calendarOpen || root.trayOpen || root.systemOpen) && !root.fullSettings && !GlobalStates.capturing
        hovered: islandHover.hovered || powerHover.hovered || trayHover.hovered || calendarHover.hovered || systemHover.hovered || settingsHover.hovered
        onDismissed: GlobalStates.closePopups()
    }

    Item {
        id: powerArea

        HoverHandler { id: powerHover }
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        width: powerMenu.width
        height: root.powerOpen ? powerMenu.height : 0

        PowerMenu {
            id: powerMenu
            anchors.top: parent.top
            anchors.right: parent.right
            open: root.powerOpen
            onRequestClose: GlobalStates.powerMenuOpen = false
        }
    }
    Item {
        id: trayArea

        HoverHandler { id: trayHover }
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        width: trayMenu.width
        height: trayMenu.open ? trayMenu.height : 0

        TrayMenu {
            id: trayMenu
            anchors.top: parent.top
            anchors.right: parent.right
            item: root.trayOpen ? root.trayMenuItem : null
            onRequestClose: GlobalStates.trayOpen = false
        }
    }

    Item {
        id: calendarArea

        HoverHandler { id: calendarHover }
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        width: calendar.width
        height: root.calendarOpen ? calendar.height : 0

        Calendar {
            id: calendar
            anchors.top: parent.top
            anchors.right: parent.right
            open: root.calendarOpen
        }
    }

    Item {
        id: systemArea

        HoverHandler { id: systemHover }
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        width: systemCard.width
        height: root.systemOpen ? systemCard.height : 0

        SystemCard {
            id: systemCard
            anchors.top: parent.top
            anchors.right: parent.right
            open: root.systemOpen
        }
    }

    Item {
        id: settingsArea

        HoverHandler { id: settingsHover }
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        width: quickSettings.implicitWidth
        height: root.settingsOpen || root.fullSettings ? quickSettings.implicitHeight : 0

        QuickSettings {
            id: quickSettings
            open: root.settingsOpen || root.fullSettings || expand > 0
            full: root.fullSettings
            onRequestClose: GlobalStates.quickSettingsOpen = false
        }
    }

    implicitWidth: row.implicitWidth + Theme.bar.padding * 2

    Column {
        id: alertArea
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        spacing: Theme.spacing.sm

        Item {
            anchors.right: parent.right
            visible: osd.opacity > 0
            width: osd.implicitWidth
            height: osd.open ? osd.implicitHeight : 0

            OsdPill {
                id: osd
                anchors.top: parent.top
                anchors.right: parent.right
                open: Events.current !== "" && !root.anyPopup
            }
        }

        Item {
            anchors.right: parent.right
            visible: stack.opacity > 0
            width: stack.implicitWidth
            height: stack.open ? stack.implicitHeight : 0

            NotificationStack {
                id: stack
                anchors.top: parent.top
                anchors.right: parent.right
                open: !root.anyPopup
            }
        }
    }

    Binding {
        target: Events
        property: "held"
        value: true
        when: osd.hovered
    }

    Binding {
        target: Notifications
        property: "paused"
        value: true
        when: stack.hovered || (Notifications.current !== null && root.anyPopup)
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.padding
        spacing: Theme.bar.gap


        Rectangle {
            id: clockPill

            readonly property var modes: [
                { key: "clock" },
                { key: "cpu", icon: "memory" },
                { key: "mem", icon: "memory_alt" },
                { key: "gpu", icon: "developer_board" }
            ]
            property int mode: 0
            property int shownMode: 0
            property int direction: 1
            property real wheelDelta: 0
            property real slide: 0
            property real contentOpacity: 1
            readonly property bool showsStats: mode > 0
            readonly property bool shownStats: shownMode > 0
            readonly property var current: modes[shownMode]
            readonly property real value: shownMode === 1 ? SystemStats.cpu : shownMode === 2 ? SystemStats.mem : SystemStats.gpu
            readonly property bool active: root.calendarOpen || root.systemOpen

            function setMode(next, step) {
                if (next === mode) return;
                direction = step;
                mode = next;
                if (!swap.running) swap.restart();
            }

            onShowsStatsChanged: SystemStats.users += showsStats ? 1 : -1
            Component.onDestruction: if (showsStats) SystemStats.users--

            implicitWidth: (shownStats ? statRow.implicitWidth : clockText.implicitWidth) + Theme.spacing.md * 2
            implicitHeight: Theme.button.size
            radius: Theme.radius.full
            clip: true
            color: active ? Colors.primaryContainer : clockMouse.containsMouse ? Colors.surfaceContainerHigh : Colors.surfaceContainer

            Behavior on implicitWidth {
                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
            }

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }

            SequentialAnimation {
                id: swap

                ParallelAnimation {
                    NumberAnimation { target: clockPill; property: "slide"; to: -clockPill.direction * clockPill.height * 0.6; duration: Theme.anim.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedAccel }
                    NumberAnimation { target: clockPill; property: "contentOpacity"; to: 0; duration: Theme.anim.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedAccel }
                }
                ScriptAction {
                    script: {
                        clockPill.shownMode = clockPill.mode;
                        clockPill.slide = clockPill.direction * clockPill.height * 0.6;
                    }
                }
                ParallelAnimation {
                    NumberAnimation { target: clockPill; property: "slide"; to: 0; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
                    NumberAnimation { target: clockPill; property: "contentOpacity"; to: 1; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
                }

                onFinished: if (clockPill.shownMode !== clockPill.mode) restart()
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (clockPill.showsStats)
                        GlobalStates.toggleSystem(root.screenName);
                    else
                        GlobalStates.toggleCalendar(root.screenName);
                }
                onWheel: wheel => {
                    if (wheelCooldown.running) {
                        clockPill.wheelDelta = 0;
                        return;
                    }
                    clockPill.wheelDelta += wheel.angleDelta.y;
                    if (Math.abs(clockPill.wheelDelta) < 120)
                        return;
                    const step = clockPill.wheelDelta < 0 ? 1 : -1;
                    const count = clockPill.modes.length;
                    clockPill.wheelDelta = 0;
                    clockPill.setMode((clockPill.mode + step + count) % count, step);
                    wheelCooldown.restart();
                }
            }

            Timer {
                id: wheelCooldown
                interval: Math.max(250, Theme.anim.fast + Theme.anim.medium)
            }

            Row {
                id: statRow
                anchors.centerIn: parent
                anchors.verticalCenterOffset: clockPill.slide
                visible: clockPill.shownStats
                opacity: clockPill.contentOpacity
                spacing: Theme.spacing.xs

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.button.iconSize
                    text: clockPill.current.icon ?? ""
                    color: clockPill.active ? Colors.textOnPrimaryContainer : Colors.textOnSurface
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.weight: Font.DemiBold
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.clock
                    text: Math.round(clockPill.value * 100) + "%"
                    color: clockPill.active ? Colors.textOnPrimaryContainer : Colors.textOnSurface
                }
            }

            Text {
                id: clockText
                anchors.centerIn: parent
                anchors.verticalCenterOffset: clockPill.slide
                visible: !clockPill.shownStats
                opacity: clockPill.contentOpacity

                font.weight: Font.DemiBold
                text: Time.time
                color: clockPill.active ? Colors.textOnPrimaryContainer : Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.clock
            }
        }

        Rectangle {
            id: trayButton

            property real shown: root.trayOpen ? 1 : 0

            Behavior on shown {
                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
            }

            visible: Settings.bar.trayButton
            implicitWidth: Theme.button.size + (trayIcons.implicitWidth + Theme.spacing.xs) * shown
            implicitHeight: Theme.button.size
            radius: height / 2
            color: trayMouse.containsMouse && !root.trayOpen ? Colors.surfaceContainerHigh : Colors.surfaceContainer
            clip: true

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }

            Row {
                id: trayIcons
                x: Theme.spacing.xs
                anchors.verticalCenter: parent.verticalCenter
                opacity: trayButton.shown
                visible: opacity > 0

                Text {
                    visible: SystemTray.items.values.length === 0
                    height: Theme.button.size
                    leftPadding: Theme.spacing.sm
                    rightPadding: Theme.spacing.xs
                    verticalAlignment: Text.AlignVCenter
                    text: "Empty"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    color: Colors.textOnSurfaceVariant
                }

            Repeater {
                model: SystemTray.items.values

                Item {
                    id: trayItem

                    required property SystemTrayItem modelData
                    readonly property bool menuOpen: root.trayMenuItem === modelData

                    width: Theme.button.size - Theme.spacing.xs * 2
                    height: width

                    MaterialShape {
                        anchors.fill: parent
                        implicitSize: parent.width
                        shape: itemMouse.containsMouse || trayItem.menuOpen ? MaterialShape.Cookie9Sided : MaterialShape.Circle
                        color: trayItem.menuOpen ? Colors.secondaryContainer : itemMouse.containsMouse ? Colors.surfaceContainerHighest : "transparent"
                        animationDuration: Theme.anim.medium

                        Behavior on color {
                            ColorAnimation { duration: Theme.anim.fast }
                        }
                    }

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: Theme.tray.iconSize
                        source: trayItem.modelData.icon
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton || trayItem.modelData.onlyMenu) {
                                if (trayItem.modelData.hasMenu) root.trayMenuItem = trayItem.menuOpen ? null : trayItem.modelData;
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayItem.modelData.secondaryActivate();
                            } else {
                                trayItem.modelData.activate();
                                GlobalStates.trayOpen = false;
                            }
                        }
                        onWheel: wheel => trayItem.modelData.scroll(wheel.angleDelta.y, false)
                    }
                }
            }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: Theme.spacing.xs * trayButton.shown
                width: Theme.button.size - Theme.spacing.xs * 2 * trayButton.shown
                height: width
                radius: width / 2
                color: Qt.alpha(trayMouse.containsMouse ? Colors.primary : Colors.primaryContainer, trayButton.shown)

                Text {
                    anchors.centerIn: parent
                    text: "chevron_left"
                    rotation: trayButton.shown * 180
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.button.iconSize
                    color: root.trayOpen ? Colors.textOnPrimaryContainer : Colors.textOnSurface
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: GlobalStates.toggleTray(root.screenName)
                }
            }
        }
        IconButton { id: gearButton; icon: "settings"; onClicked: GlobalStates.toggleQuickSettings(root.screenName) }
        Item {
            implicitWidth: Theme.batteryRing.size
            implicitHeight: Theme.batteryRing.size

            BatteryRing {
                id: ring
                anchors.fill: parent
                visible: Battery.available && Settings.bar.batteryRing
                level: Battery.level               
                low: Battery.low                 
            }

            IconButton {
                anchors.centerIn: parent
                icon: "power_settings_new"
                onClicked: GlobalStates.togglePowerMenu(root.screenName)
            }
        }
    }
}
