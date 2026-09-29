import qs.widgets.bar.left
import qs.widgets.bar.right
import qs.widgets.bar.center
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.theme

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property ShellScreen modelData
        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Theme.bar.windowHeight
        exclusiveZone: Theme.bar.height
        color: "transparent"

        mask: Region {
            regions: [
                Region { item: leftIsland },
                Region { item: centerIsland },
                Region { item: centerIsland.bubble },
                Region { item: rightIsland },
                Region { item: rightIsland.powerArea },
                Region { item: rightIsland.settingsArea }
            ]
        }

        WlrLayershell.namespace: "quickshell:bar"

        LeftIsland   { id: leftIsland;   anchors.left: parent.left }
        CenterIsland { id: centerIsland; anchors.horizontalCenter: parent.horizontalCenter }
        RightIsland  { id: rightIsland;  anchors.right: parent.right }
    }
}
