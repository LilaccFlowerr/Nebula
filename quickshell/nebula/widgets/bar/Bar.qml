import qs.widgets.bar.left
import qs.widgets.bar.right
import qs.widgets.bar.center
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
        readonly property bool fullSettings: GlobalStates.settingsOpen && GlobalStates.isOn(modelData.name)

        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: modelData.height
        exclusiveZone: Theme.bar.height
        color: "transparent"

        IdleInhibitor {
            window: window
            enabled: KeepAwake.enabled
        }

        mask: Region {
            regions: [
                Region { item: leftIsland },
                Region { item: centerIsland },
                Region { item: centerIsland.bubble },
                Region { item: rightIsland },
                Region { item: rightIsland.powerArea },
                Region { item: rightIsland.settingsArea },
                Region { item: rightIsland.calendarArea },
                Region { item: rightIsland.trayArea },
                Region {
                    width: window.fullSettings ? window.width : 0
                    height: window.fullSettings ? window.height : 0
                }
            ]
        }

        WlrLayershell.namespace: "quickshell:bar"
        WlrLayershell.keyboardFocus: fullSettings ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

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

        LeftIsland   { id: leftIsland;   anchors.left: parent.left }
        CenterIsland { id: centerIsland; anchors.horizontalCenter: parent.horizontalCenter }
        RightIsland  { id: rightIsland;  anchors.right: parent.right }
    }
}
