import QtQuick
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property int selected: 0
    readonly property var results: Launcher.results
    readonly property int slots: Launcher.slots
    readonly property var shapes: ["cookie4", "clover4", "cookie6", "circle", "cookie9", "clover8", "cookie12", "cookie7"]

    width: Theme.launcher.size
    height: Theme.launcher.size

    ShapedImage {
        anchors.fill: parent
        bumps: root.slots
        lobes: Theme.launcher.lobes
        rotation: -90
        placeholderColor: Launcher.commandMode ? Colors.tertiaryContainer : Colors.primaryContainer
    }

    Repeater {
        model: root.slots

        RingItem {
            required property int index
            angle: (index - root.selected + root.slots) % root.slots * 360 / root.slots
            entry: root.results[index] ?? null
            selected: index === root.selected
            shape: root.shapes[index]
        }
    }
}
