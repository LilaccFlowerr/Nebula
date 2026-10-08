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
import qs.services
import qs.theme

Island {
    id: root
    roundLeft: true

    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property bool powerOpen: GlobalStates.powerMenuOpen && GlobalStates.isOn(screenName)
    readonly property bool settingsOpen: GlobalStates.quickSettingsOpen && GlobalStates.isOn(screenName)
    readonly property bool calendarOpen: GlobalStates.calendarOpen && GlobalStates.isOn(screenName)
    readonly property bool trayOpen: GlobalStates.trayOpen && GlobalStates.isOn(screenName)
    property SystemTrayItem trayMenuItem: null

    onTrayOpenChanged: if (!trayOpen) trayMenuItem = null
    readonly property bool fullSettings: GlobalStates.settingsOpen && GlobalStates.isOn(screenName)
    readonly property real presence: quickSettings.presence
    property bool armed: false

    Timer {
        interval: 1000
        running: true
        onTriggered: root.armed = true
    }
    property alias powerArea: powerArea
    property alias settingsArea: settingsArea
    property alias calendarArea: calendarArea
    property alias trayArea: trayArea

    HyprlandFocusGrab {
        windows: [root.QsWindow.window]
        active: (root.powerOpen || root.settingsOpen || root.calendarOpen || root.trayOpen) && !GlobalStates.capturing
        onCleared: {
            GlobalStates.powerMenuOpen = false;
            GlobalStates.quickSettingsOpen = false;
            GlobalStates.calendarOpen = false;
            GlobalStates.trayOpen = false;
        }
    }

    Item {
        id: powerArea
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
        id: settingsArea
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

    Connections {
        target: Battery
        function onPluggedInChanged() { if (root.armed) ring.ripple(Battery.pluggedIn ? 1500 : 0); }
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.padding
        spacing: Theme.bar.gap


        Rectangle {
            id: clockPill

            implicitWidth: clockText.implicitWidth + Theme.spacing.md * 2
            implicitHeight: Theme.button.size
            radius: Theme.radius.full
            color: root.calendarOpen ? Colors.primaryContainer : clockMouse.containsMouse ? Colors.surfaceContainerHigh : Colors.surfaceContainer

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: GlobalStates.toggleCalendar(root.screenName)
            }

            Text {
                id: clockText
                anchors.centerIn: parent

                font.weight: Font.DemiBold
                text: Time.time
                color: root.calendarOpen ? Colors.textOnPrimaryContainer : Colors.textOnSurface
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
