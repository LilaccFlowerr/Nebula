import QtQuick
import qs.components
import "../../components/Curves.js" as Curves
import qs.services
import qs.theme

Item {
    id: root

    property int selected: 0
    property bool rushing: false
    property real intro: 1
    readonly property real cloverT: Curves.phase(intro, 0, 0.6)
    property real shownMorph: Launcher.commandMode ? 1 : 0

    Behavior on shownMorph {
        NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
    readonly property var results: Launcher.results
    readonly property int slots: Launcher.slots
    readonly property var shapes: ["cookie4", "clover4", "cookie6", "circle", "cookie9", "clover8", "cookie12", "cookie7"]

    width: Theme.launcher.size
    height: Theme.launcher.size

    ShapedImage {
        anchors.fill: parent
        scale: Math.max(0, Curves.back(root.cloverT, Theme.anim.overshoot))
        bumps: Launcher.appSlots
        bumpsTo: Launcher.commandSlots
        morph: root.shownMorph
        lobes: Theme.launcher.lobes
        rotation: -90 + root.shownMorph * 360 / Launcher.commandSlots - (1 - Curves.decel(root.cloverT)) * 120
        placeholderColor: Launcher.commandMode ? Colors.tertiaryContainer : Colors.primaryContainer

        Behavior on placeholderColor {
            ColorAnimation { duration: Theme.anim.island; easing.type: Easing.OutCubic }
        }
    }

    FontMetrics {
        id: labelMetrics
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
    }

    Rectangle {
        x: root.width / 2 - width / 2
        y: root.height / 2 - Theme.launcher.ringRadius - (Theme.launcher.labelGap + labelMetrics.height) / 2 - height / 2
        width: Theme.launcher.selectionSize
        height: Theme.launcher.selectionSize
        radius: width / 2
        color: Qt.alpha(Colors.textOnPrimaryContainer, 0.25)
        visible: root.results.length > 0
        scale: Curves.back(Curves.phase(root.intro, 0.3, 0.35), Theme.anim.overshoot)
    }

    Repeater {
        model: Launcher.appSlots

        RingItem {
            required property int index
            readonly property int position: (index - root.selected + root.slots) % root.slots
            angle: position * 360 / root.slots
            delay: root.rushing ? 0 : Math.min(position, root.slots - position) * Theme.launcher.stagger
            rushing: root.rushing
            entry: root.results[index] ?? null
            shape: root.shapes[index]
            readonly property real appear: Math.max(0, Curves.back(Curves.phase(root.intro, 0.3 + position * 0.04, 0.35), Theme.anim.overshoot))
            opacity: Math.min(1, appear * 2)
            transform: Scale {
                origin.x: Theme.launcher.labelWidth / 2
                origin.y: Theme.launcher.itemSize / 2
                xScale: appear
                yScale: appear
            }
            visible: index < root.slots
        }
    }
}
