import qs.widgets.bar.left
import qs.widgets.bar.right
import qs.widgets.bar.center
import qs.widgets.bar.media
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: window

        required property ShellScreen modelData
        readonly property bool fullSettings: GlobalStates.settingsOpen && GlobalStates.isOn(modelData?.name ?? "")
        readonly property bool popupHere: GlobalStates.popupOpen && GlobalStates.isOn(modelData?.name ?? "")

        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: modelData?.height ?? Theme.bar.height
        exclusiveZone: Theme.bar.zone
        color: "transparent"

        IdleInhibitor {
            window: window
            enabled: KeepAwake.enabled
        }

        mask: Region {
            regions: [
                Region { item: leftIsland },
                Region { item: centerIsland },
                Region { item: centerIsland.background },
                Region { item: centerIsland.menuArea },
                Region { item: centerIsland.contextArea },
                Region { item: mediaIsland },
                Region { item: mediaIsland.bodyArea },
                Region { item: rightIsland },
                Region { item: rightIsland.powerArea },
                Region { item: rightIsland.settingsArea },
                Region { item: rightIsland.calendarArea },
                Region { item: rightIsland.trayArea },
                Region { item: rightIsland.systemArea },
                Region { item: rightIsland.alertArea },
                Region {
                    width: window.fullSettings ? window.width : 0
                    height: window.fullSettings ? window.height : 0
                }
            ]
        }

        WlrLayershell.namespace: "quickshell:bar"
        WlrLayershell.keyboardFocus: fullSettings ? WlrKeyboardFocus.Exclusive : popupHere ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        Shortcut {
            sequence: "Escape"
            enabled: window.popupHere && !window.fullSettings
            onActivated: GlobalStates.closePopups()
        }

        Rectangle {
            anchors.fill: parent
            color: Colors.scrim
            opacity: Theme.launcher.dim * rightIsland.presence
            visible: opacity > 0

            MouseArea {
                anchors.fill: parent
                enabled: window.fullSettings
                onClicked: GlobalStates.settingsOpen = false
            }
        }

        LeftIsland   { id: leftIsland;   anchors.left: parent.left; anchors.leftMargin: Theme.bar.floatMargin; anchors.top: parent.top; anchors.topMargin: Theme.bar.floatMargin }
        CenterIsland { id: centerIsland; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; anchors.topMargin: Theme.bar.floatMargin }
        MediaIsland {
            id: mediaIsland

            readonly property real gapLeft: leftIsland.x + leftIsland.width
            readonly property real gapRight: centerIsland.x

            available: gapRight - gapLeft - Theme.bar.gap * 2
            panelRoom: rightIsland.x - x - Theme.bar.gap
            x: Math.max(gapLeft + Theme.bar.gap, gapLeft + (gapRight - gapLeft - width) / 2)
            anchors.top: parent.top
            anchors.topMargin: Theme.bar.floatMargin
        }
        RightIsland  { id: rightIsland;  anchors.right: parent.right; anchors.rightMargin: Theme.bar.floatMargin; anchors.top: parent.top; anchors.topMargin: Theme.bar.floatMargin }
    }
}
