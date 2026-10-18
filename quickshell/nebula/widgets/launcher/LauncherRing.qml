import QtQuick
import M3Shapes
import qs.components
import "../../components/Curves.js" as Curves
import qs.services
import qs.theme

Item {
    id: root

    property int selected: 0
    property int cursor: 0
    property bool infinite: false
    property bool rushing: false
    property real intro: 1
    readonly property real cloverT: Curves.phase(intro, 0, 0.6)
    property real shownMorph: Launcher.commandMode ? 1 : 0

    Behavior on shownMorph {
        NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
    property real shownWall: Launcher.wallpaperMode ? 1 : 0

    Behavior on shownWall {
        NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
    readonly property var results: Launcher.results
    readonly property int slots: Launcher.slots
    readonly property var shapes: [MaterialShape.Cookie4Sided, MaterialShape.Clover4Leaf, MaterialShape.Cookie6Sided, MaterialShape.Circle, MaterialShape.Cookie9Sided, MaterialShape.Clover8Leaf, MaterialShape.Cookie12Sided, MaterialShape.Cookie7Sided]

    function entryAt(position) {
        const offset = position <= root.slots / 2 ? position : position - root.slots;
        const n = root.results.length;
        return root.results[((root.cursor + offset) % n + n) % n] ?? null;
    }

    width: Theme.launcher.size
    height: Theme.launcher.size

    MaterialShape {
        function clover(leaves) {
            const tip = (-90 + 180 / leaves) * Math.PI / 180;
            return polygon([
                point(0.5, 0.5 - Theme.launcher.valleyRadius),
                point(0.5 + Theme.launcher.leafRadius * Math.cos(tip), 0.5 + Theme.launcher.leafRadius * Math.sin(tip), Theme.launcher.leafRounding)
            ], leaves).normalized();
        }

        readonly property real leafOffset: 180 / Launcher.appSlots + (180 / Launcher.commandSlots - 180 / Launcher.appSlots) * root.shownMorph

        anchors.fill: parent
        scale: Math.max(0, Curves.back(root.cloverT, Theme.anim.overshoot))
        fromShape: MaterialShape.Clover8Leaf
        customToShape: clover(Launcher.commandSlots)
        morphProgress: root.shownMorph
        rotation: root.shownMorph * 360 / Launcher.commandSlots - leafOffset - (1 - Curves.decel(root.cloverT)) * 120
        readonly property color accent: Launcher.themeMode ? Scheme.previews[root.results[root.cursor]?.scheme]?.primaryContainer ?? Colors.primaryContainer
             : Launcher.wallpaperMode ? Colors.secondaryContainer : Launcher.commandMode ? Colors.tertiaryContainer : Colors.primaryContainer
        color: Qt.tint(Qt.alpha(Colors.surface, Theme.bar.opacity), Qt.alpha(accent, Theme.launcher.tint))

        Behavior on color {
            ColorAnimation { duration: Theme.anim.island; easing.type: Easing.OutCubic }
        }
    }

    FontMetrics {
        id: labelMetrics
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
    }

    MouseArea {
        anchors.fill: parent
        onClicked: mouse => {
            if (Math.hypot(mouse.x - width / 2, mouse.y - height / 2) > width / 2) Launcher.close();
        }
    }

    Repeater {
        model: Launcher.appSlots

        RingItem {
            required property int index
            readonly property int position: (index - root.selected + root.slots) % root.slots
            angle: position * 360 / root.slots
            delay: root.rushing ? 0 : Math.min(position, root.slots - position) * Theme.launcher.stagger * Theme.anim.scale
            rushing: root.rushing
            entry: root.infinite ? root.entryAt(position) : root.results[index] ?? null
            shape: root.shapes[index]
            selected: position === 0
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

    ShapedArt {
        readonly property var wallpaper: Launcher.wallpaperMode ? root.results[root.cursor] ?? null : null
        anchors.centerIn: parent
        width: Theme.launcher.previewSize
        height: Theme.launcher.previewSize
        shape: Wallpaper.transitionShape
        source: wallpaper ? Wallpaper.url(wallpaper.path) : ""
        sourceSize: Qt.size(width * 2, height * 2)
        color: Colors.surfaceContainer
        scale: Math.max(0, root.shownWall)
        rotation: (1 - root.shownWall) * -90
        visible: scale > 0.01
    }
}
