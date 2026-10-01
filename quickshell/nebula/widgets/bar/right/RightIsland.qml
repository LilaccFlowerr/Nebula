import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.widgets.popups.quicksettings
import qs.services
import qs.theme

Island {
    id: root
    roundLeft: true

    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property bool powerOpen: GlobalStates.powerMenuOpen && GlobalStates.isOn(screenName)
    readonly property bool settingsOpen: GlobalStates.quickSettingsOpen && GlobalStates.isOn(screenName)
    property bool armed: false

    Timer {
        interval: 1000
        running: true
        onTriggered: root.armed = true
    }
    property alias powerArea: powerArea
    property alias settingsArea: settingsArea

    HyprlandFocusGrab {
        windows: [root.QsWindow.window]
        active: root.powerOpen || root.settingsOpen
        onCleared: {
            GlobalStates.powerMenuOpen = false;
            GlobalStates.quickSettingsOpen = false;
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
    Neck {
        id: neck
        anchors.top: parent.bottom
        x: row.x + gearButton.x + gearButton.width / 2 - width / 2
        neckWidth: Theme.quickSettings.neckWidth
        curve: Theme.quickSettings.neckCurve
        opacity: quickSettings.opacity
        visible: opacity > 0
    }

    Item {
        id: settingsArea
        anchors.top: neck.bottom
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        width: quickSettings.width
        height: root.settingsOpen ? quickSettings.height : 0

        QuickSettings {
            id: quickSettings
            anchors.top: parent.top
            anchors.right: parent.right
            open: root.settingsOpen
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
            color: Colors.surfaceContainer

            Text {
                id: clockText
                anchors.centerIn: parent

                font.weight: Font.DemiBold
                text: Time.time
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.clock
            }
        }

        IconButton { icon: "keyboard_arrow_up";   onClicked: console.info("tray") }
        IconButton { id: gearButton; icon: "settings"; onClicked: GlobalStates.toggleQuickSettings(root.screenName) }
        Item {
            implicitWidth: Theme.batteryRing.size
            implicitHeight: Theme.batteryRing.size

            BatteryRing {
                id: ring
                anchors.fill: parent
                visible: Battery.available
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
