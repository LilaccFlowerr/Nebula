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
        implicitHeight: Theme.bar.height
        color: "transparent"   // the window itself is invisible, only the islands are drawn

        // Name for Hyprland layer rules (blur): match = { namespace = "^quickshell:bar$" }
        WlrLayershell.namespace: "quickshell:bar"

        // TODO step 3: the three islands
          LeftIsland   { anchors.left: parent.left }
          CenterIsland { anchors.horizontalCenter: parent.horizontalCenter }
          RightIsland  { anchors.right: parent.right }
    }
}
