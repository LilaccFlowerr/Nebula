import QtQuick
import QtQuick.Layouts
import Quickshell
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings
import "../../../components/Curves.js" as Curves

Rectangle {
    id: root

    property bool open: false
    property bool full: false
    property real expand: 0
    property real fade: 1
    property point offset: Qt.point(0, 0)
    readonly property real presence: expand * fade
    signal requestClose()

    readonly property real targetX: ((QsWindow.window?.width ?? 0) - Theme.settings.width) / 2 - offset.x
    readonly property real targetY: ((QsWindow.window?.height ?? 0) - Theme.settings.height) / 2 - offset.y

    function lerp(a, b, t) {
        return a + (b - a) * t;
    }

    onFullChanged: {
        expandAnim.stop();
        fadeAnim.stop();
        if (full) {
            offset = parent.mapToItem(null, 0, 0);
            content.forceActiveFocus();
            if (GlobalStates.settingsFromQuick) {
                fade = 1;
                expandAnim.restart();
            } else {
                expand = 1;
                fade = 0;
                fadeAnim.to = 1;
                fadeAnim.restart();
            }
        } else {
            fadeAnim.to = 0;
            fadeAnim.restart();
        }
    }

    onOpenChanged: if (open && !full) fade = 1

    NumberAnimation {
        id: expandAnim
        target: root
        property: "expand"
        to: 1
        duration: Theme.settings.expandDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.standard
    }

    NumberAnimation {
        id: fadeAnim
        target: root
        property: "fade"
        duration: Theme.anim.medium
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.standard
        onFinished: if (root.fade === 0) root.expand = 0
    }

    implicitWidth: Theme.quickSettings.width
    implicitHeight: column.implicitHeight + Theme.spacing.lg * 2
    x: lerp(0, targetX, expand)
    y: lerp(0, targetY, expand)
    width: lerp(implicitWidth, Theme.settings.width, expand)
    height: lerp(implicitHeight, Theme.settings.height, expand)
    radius: lerp(Theme.radius.large, Theme.radius.large + Theme.spacing.sm, expand)
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)
    clip: expand > 0

    property real shown: open ? 1 : 0
    property real openScale: open ? 1 : 0.9

    visible: opacity > 0
    opacity: shown * fade
    scale: openScale * lerp(Theme.settings.fadeScale, 1, fade)
    transformOrigin: expand > 0 ? Item.Center : Item.Top

    Behavior on shown {
        NumberAnimation { duration: Theme.anim.fast }
    }
    Behavior on openScale {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    SettingsContent {
        id: content
        anchors.centerIn: parent
        width: Theme.settings.width
        height: Theme.settings.height
        opacity: Curves.phase(root.expand, 0.5, 0.5)
        visible: opacity > 0
    }

    ColumnLayout {
        id: column
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.spacing.lg
        width: root.implicitWidth - Theme.spacing.lg * 2
        spacing: Theme.spacing.lg
        opacity: 1 - Curves.phase(root.expand, 0, 0.35)
        visible: opacity > 0

        RowLayout {
            spacing: Theme.spacing.md

            ShapedArt {
                implicitWidth: Theme.quickSettings.avatarSize
                implicitHeight: Theme.quickSettings.avatarSize
                shape: MaterialShape.Cookie9Sided
                source: SystemInfo.avatar
                color: Colors.surfaceContainerHigh

                Text {
                    anchors.centerIn: parent
                    text: "add_a_photo"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.quickSettings.avatarIconSize
                    color: Colors.textOnSurface
                    opacity: avatarMouse.containsMouse ? 0.9 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.anim.fast }
                    }
                }

                MouseArea {
                    id: avatarMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemInfo.pickAvatar()
                }
            }

            ColumnLayout {
                spacing: 2

                Text {
                    text: SystemInfo.user + "@" + SystemInfo.host
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.clock
                    font.weight: Font.DemiBold
                }

                Text {
                    text: SystemInfo.uptime + (Battery.available ? " · " + Battery.percent + "%" : "")
                    color: Colors.textOnSurfaceVariant
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Theme.spacing.sm
            columnSpacing: Theme.spacing.sm

            Tile {
                Layout.fillWidth: true
                visible: Wifi.available
                icon: Wifi.icon
                title: "Wifi"
                subtitle: Wifi.connected ? Wifi.ssid : Wifi.enabled ? "Not connected" : "Off"
                active: Wifi.enabled
                splittable: true
                onClicked: Wifi.toggle()
                onOpenRequested: GlobalStates.openSettings("connections", "wifi", true)
            }

            Tile {
                Layout.fillWidth: true
                visible: BluetoothStatus.available
                icon: BluetoothStatus.icon
                title: "Bluetooth"
                subtitle: BluetoothStatus.connected ? BluetoothStatus.deviceName : BluetoothStatus.enabled ? "On" : "Off"
                active: BluetoothStatus.enabled
                splittable: true
                onClicked: BluetoothStatus.toggle()
                onOpenRequested: GlobalStates.openSettings("connections", "bluetooth", true)
            }

            Tile {
                Layout.fillWidth: true
                icon: Dnd.icon
                title: "Do not disturb"
                subtitle: Dnd.enabled ? "On" : "Off"
                active: Dnd.enabled
                onClicked: Dnd.toggle()
            }

            Tile {
                Layout.fillWidth: true
                icon: "settings"
                title: "Settings"
                subtitle: "All settings"
                onClicked: GlobalStates.toggleSettings(GlobalStates.focusedScreen(), true)
            }
        }

        RowLayout {
            spacing: Theme.spacing.md

            Text {
                text: Audio.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: Colors.textOnSurface
            }

            Slider {
                Layout.fillWidth: true
                value: Audio.volume
                onMoved: Audio.setVolume(value)
            }
        }

        RowLayout {
            visible: Brightness.available
            spacing: Theme.spacing.md

            Text {
                text: "brightness_medium"
                font.family: Theme.font.icons
                font.pixelSize: Theme.button.iconSize
                color: Colors.textOnSurface
            }

            Slider {
                Layout.fillWidth: true
                value: Brightness.level
                onMoved: Brightness.setBrightness(value)
            }
        }
    }
}
