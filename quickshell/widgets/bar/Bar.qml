// The top bar: one transparent window per screen that holds the three islands.
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
        // Taller than the bar so the center island can grow downward, but Hyprland only
        // reserves the bar height, so windows stay where they are
        implicitHeight: Theme.bar.windowHeight
        exclusiveZone: Theme.bar.height
        color: "transparent"   // the window itself is invisible, only the islands are drawn

        // Only the islands catch the mouse; everywhere else clicks go through to the windows
        mask: Region {
            regions: [
                Region { item: leftIsland },
                Region { item: centerIsland },
                Region { item: rightIsland }
            ]
        }

        // Name for Hyprland layer rules (blur): match = { namespace = "^quickshell:bar$" }
        WlrLayershell.namespace: "quickshell:bar"

        LeftIsland   { id: leftIsland;   anchors.left: parent.left }
        CenterIsland { id: centerIsland; anchors.horizontalCenter: parent.horizontalCenter }
        RightIsland  { id: rightIsland;  anchors.right: parent.right }
    }
}
