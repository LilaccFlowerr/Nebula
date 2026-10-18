import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import M3Shapes
import qs.services
import qs.theme
import qs.widgets.bar.left
import qs.widgets.bar.center
import qs.widgets.bar.right

Item {
    id: root

    property string screenName: ""
    property bool open: false
    property bool ready: false
    property bool main: false
    property real shown: 0

    readonly property var monitor: Hyprland.monitors.values.find(m => m.name === root.screenName) ?? null
    readonly property int currentId: monitor?.activeWorkspace?.id ?? 1
    readonly property var allIds: Hyprland.workspaces.values.map(w => w.id).filter(id => id > 0)
    readonly property int newId: {
        let id = 1;
        while (allIds.includes(id)) id++;
        return id;
    }
    readonly property var ids: Hyprland.workspaces.values
        .filter(w => w.id > 0 && w.monitor?.name === root.screenName)
        .map(w => w.id)
        .sort((a, b) => a - b)
        .concat([newId])
    readonly property int currentIndex: Math.max(0, ids.indexOf(currentId))

    property int selected: 0
    property real shownSelected: selected
    property bool snap: false
    property int captureToken: 0

    Behavior on shownSelected {
        enabled: !root.snap
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    readonly property var shapes: [MaterialShape.Cookie9Sided, MaterialShape.Clover4Leaf, MaterialShape.Cookie6Sided, MaterialShape.Sunny, MaterialShape.Cookie12Sided]

    readonly property real stripWidth: width * Theme.overview.stripRatio
    readonly property real stripHeight: stripWidth * 9 / 16
    readonly property real bigWidth: width * Theme.overview.bigRatio
    readonly property real sideWidth: width * Theme.overview.sideRatio
    readonly property real stripBottom: Theme.overview.stripTop + stripHeight + Theme.overview.labelHeight
    readonly property real filmCenter: height / 2
    readonly property real step: (bigWidth + sideWidth) / 2 + Theme.overview.sideGap

    property var dragging: null
    property point dragPos

    function lerp(a, b, t) {
        return a + (b - a) * t;
    }

    function reset() {
        snap = true;
        selected = currentIndex;
        snap = false;
        Hyprland.refreshToplevels();
        captureToken++;
    }

    function stepBy(delta) {
        selected = Math.max(0, Math.min(ids.length - 1, selected + delta));
    }

    function go(index) {
        const id = ids[index];
        if (id === undefined) return;
        selected = index;
        if (id !== currentId) {
            if (id === newId) Hyprland.dispatch(`hl.dsp.focus({ monitor = "${root.screenName}" })`);
            Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
        }
        GlobalStates.overviewOpen = false;
    }

    function address(toplevel) {
        const a = toplevel.address;
        return a.startsWith("0x") ? a : "0x" + a;
    }

    function focusWindow(toplevel) {
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address(toplevel)}" })`);
        GlobalStates.overviewOpen = false;
    }

    function stripCardAt(pos) {
        for (let i = 0; i < strip.count; i++) {
            const item = strip.itemAt(i);
            if (!item) continue;
            const p = item.mapFromItem(null, pos.x, pos.y);
            if (p.x >= 0 && p.y >= 0 && p.x <= item.width && p.y <= item.height) return item;
        }
        return null;
    }

    function drop(toplevel, pos) {
        dragging = null;
        const target = stripCardAt(pos);
        if (!target || target.ws === toplevel.workspace?.id) return;
        if (target.ws === newId) Hyprland.dispatch(`hl.dsp.focus({ monitor = "${root.screenName}" })`);
        Hyprland.dispatch(`hl.dsp.window.move({ workspace = "${target.ws}", window = "address:${address(toplevel)}" })`);
        Qt.callLater(Hyprland.refreshToplevels);
    }

    onCurrentIndexChanged: if (open) selected = currentIndex

    Connections {
        target: GlobalStates
        enabled: root.open && root.main
        function onOverviewConfirmRequested() { root.go(root.selected); }
    }
    onOpenChanged: if (open) reset()

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) GlobalStates.overviewOpen = false;
        else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) stepBy(-1);
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down || event.key === Qt.Key_Tab) stepBy(1);
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) go(selected);
        else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) go(event.key - Qt.Key_1);
        else return;
        event.accepted = true;
    }

    WheelHandler {
        property real delta: 0

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            delta += Math.abs(event.angleDelta.x) > Math.abs(event.angleDelta.y) ? event.angleDelta.x : event.angleDelta.y;
            if (Math.abs(delta) < 120) return;
            root.stepBy(delta < 0 ? 1 : -1);
            delta = 0;
        }
    }

    Item {
        id: barCopy
        x: -width - root.width
        width: root.width
        height: Theme.bar.height
        enabled: false
        visible: root.open || root.shown > 0

        LeftIsland { anchors.left: parent.left }
        CenterIsland { anchors.horizontalCenter: parent.horizontalCenter }
        RightIsland { anchors.right: parent.right }
    }

    Item {
        anchors.fill: parent

        Repeater {
            model: root.ids

            WsCard {
                id: film

                required property int index
                required property int modelData
                readonly property real d: index - root.shownSelected
                readonly property real near: Math.max(0, 1 - Math.abs(d))

                ws: modelData
                visible: Math.abs(d) < Theme.overview.visibleRange
                monitor: root.monitor
                live: root.open && Math.abs(d) < 0.5
                interactive: root.open && index === root.selected
                captureToken: root.captureToken
                emptyShape: root.shapes[(ws - 1) % root.shapes.length]
                readonly property bool target: index === root.selected
                readonly property real zoom: target ? 1 - root.shown : 0
                readonly property real cardWidth: root.lerp(root.sideWidth, root.bigWidth, near)

                decorated: zoom > 0
                barSource: barCopy
                width: root.lerp(cardWidth, root.width, zoom)
                height: width * 9 / 16
                x: root.lerp(root.width / 2 + d * root.step - cardWidth / 2, 0, zoom)
                y: root.lerp(root.filmCenter - cardWidth * 9 / 32, 0, zoom)
                radius: Theme.overview.cardRadius * width / root.bigWidth
                z: target ? 2 : near
                opacity: target ? (root.ready || root.shown > 0 ? 1 : 0) : root.lerp(Theme.overview.sideOpacity, 1, near) * root.shown

                onClicked: index === root.selected ? root.go(index) : root.selected = index
                onWindowClicked: toplevel => root.focusWindow(toplevel)
                onWindowDragged: (toplevel, pos) => {
                    root.dragging = toplevel;
                    root.dragPos = pos;
                }
                onWindowDropped: (toplevel, pos) => root.drop(toplevel, pos)
            }
        }

        Row {
            y: Theme.overview.stripTop
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.overview.stripGap
            opacity: root.shown

            Repeater {
                id: strip
                model: root.ids

                Column {
                    id: slot

                    required property int index
                    required property int modelData
                    readonly property int ws: modelData
                    readonly property bool dropTarget: root.dragging !== null && root.stripCardAt(root.dragPos) === slot

                    spacing: Theme.overview.labelGap

                    WsCard {
                        width: root.stripWidth
                        height: root.stripHeight
                        ws: slot.ws
                        monitor: root.monitor
                        selected: slot.index === root.selected || slot.dropTarget
                        captureToken: root.captureToken
                        emptyShape: root.shapes[(slot.ws - 1) % root.shapes.length]
                        radius: Theme.radius.medium
                        barSource: barCopy
                        scale: hovered || slot.dropTarget ? Theme.overview.hoverScale : 1
                        onClicked: root.go(slot.index)

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.anim.medium
                                easing.type: Easing.OutBack
                                easing.overshoot: Theme.anim.overshoot
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.spacing.xs + 2

                        Rectangle {
                            width: Theme.overview.badgeSize
                            height: width
                            radius: width / 2
                            color: slot.ws === root.currentId ? Colors.primaryContainer : Colors.surfaceContainerHigh

                            Text {
                                anchors.centerIn: parent
                                text: slot.ws === root.newId ? "+" : slot.ws
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.small - 1
                                font.weight: Font.Medium
                                color: slot.ws === root.currentId ? Colors.textOnPrimaryContainer : Colors.textOnSurfaceVariant
                            }
                        }

                        Text {
                            readonly property var first: Hyprland.toplevels.values.find(t => t.workspace?.id === slot.ws)
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.min(implicitWidth, root.stripWidth - Theme.overview.badgeSize - Theme.spacing.sm)
                            elide: Text.ElideRight
                            text: first ? (DesktopEntries.heuristicLookup(first.lastIpcObject.class ?? "")?.name ?? first.title.split(" — ").pop()) : slot.ws === root.newId ? "New" : "Empty"
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            color: slot.index === root.selected ? Colors.textOnSurface : Colors.textOnSurfaceVariant
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: root.dragging !== null
        x: root.dragPos.x - width / 2
        y: root.dragPos.y - height / 2
        width: Theme.overview.ghostWidth
        height: width * 9 / 16
        radius: Theme.radius.medium
        color: Colors.surfaceContainerHigh
        border.width: Theme.overview.hoverBorder
        border.color: Colors.primary

        IconImage {
            anchors.centerIn: parent
            implicitSize: parent.height * 0.4
            source: root.dragging ? Quickshell.iconPath(DesktopEntries.heuristicLookup(root.dragging.lastIpcObject.class ?? "")?.icon ?? "", true) : ""
        }
    }
}
