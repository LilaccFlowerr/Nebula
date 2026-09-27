import QtQuick
import qs.theme

Rectangle {
    id: root

    // Settings per island
    property bool roundLeft: false
    property bool roundRight: false

    implicitHeight: Theme.bar.height
    // Slightly see-through; the blur behind it comes from a Hyprland layer rule (hypr/hyprland/rules.lua)
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    bottomLeftRadius: roundLeft ? Theme.bar.radius : 0
    bottomRightRadius: roundRight ? Theme.bar.radius: 0

}