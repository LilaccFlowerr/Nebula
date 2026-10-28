import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.components
import qs.services
import qs.theme
import qs.widgets.bar.center.components

Island {
    id: root
    roundLeft: true
    roundRight: true
    detach: Theme.bar.centerT
    hookLeft: true
    hookRight: true
    ink: notch
    bottomRadius: Theme.bar.radius + Theme.dock.notchRadius * lift
    implicitWidth: baseWidth + Theme.dock.notchGrow * lift
    implicitHeight: Theme.bar.height + Theme.dock.notchDrop * lift

    property real baseWidth: Math.max(Theme.bar.centerMinWidth, (empty ? emptyContent.implicitWidth + Theme.spacing.lg * 2 : row.implicitWidth) + margin * 2)
    readonly property real notch: 1 - Theme.bar.centerT
    readonly property bool lifted: notch > 0.5 && (root.bgHovered || islandHover.hovered || menuOpen)
    property real lift: lifted ? 1 : 0

    Behavior on lift {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    readonly property real margin: (Theme.bar.height - Theme.dock.itemSize) / 2
    readonly property bool empty: Dock.pinned.length === 0 && Dock.running.length === 0
    readonly property bool here: GlobalStates.isOn(QsWindow.window?.screen?.name ?? "")
    readonly property bool previewOpen: GlobalStates.dockPreview !== "" && here
    readonly property bool contextOpen: GlobalStates.dockContext !== "" && here
    readonly property bool menuOpen: previewOpen || contextOpen
    readonly property bool showDivider: Dock.pinned.length > 0 && Dock.running.length > 0
    property Item hoveredItem: null

    property alias menuArea: menuArea
    property alias contextArea: contextArea

    function centerOf(item) {
        return item ? item.mapToItem(root, item.width / 2, 0).x : root.width / 2;
    }

    function dripX(centerX, w) {
        const edge = root.bottomRadius + Theme.dock.dripHook;
        if (w > root.width - edge * 2) return Math.round((root.width - w) / 2);
        return Math.round(Math.max(edge, Math.min(root.width - edge - w, centerX - w / 2)));
    }

    function placeUnder(centerX, w) {
        const left = root.x;
        const room = QsWindow.window?.width ?? root.width;
        const m = Theme.bar.floatMargin;
        return Math.round(Math.max(m - left, Math.min(room - m - left - w, centerX - w / 2)));
    }

    Connections {
        target: GlobalStates
        function onDockPreviewChanged() { if (GlobalStates.dockPreview !== "") Qt.callLater(() => { if (root.hoveredItem) menuArea.centerX = root.centerOf(root.hoveredItem); }); }
        function onDockContextChanged() { if (GlobalStates.dockContext !== "") Qt.callLater(() => { if (root.hoveredItem) contextArea.centerX = root.centerOf(root.hoveredItem); }); }
    }

    Behavior on baseWidth {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
    }

    function sync(model, keys) {
        for (let i = 0; i < model.count; i++) {
            const row = model.get(i);
            const wanted = keys.includes(row.key);
            if (row.leaving === wanted) model.setProperty(i, "leaving", !wanted);
        }
        for (const key of keys) {
            let found = false;
            for (let i = 0; i < model.count; i++) if (model.get(i).key === key) found = true;
            if (!found) model.append({ key: key, leaving: false });
        }
    }

    ListModel { id: pinnedModel }
    ListModel { id: runningModel }

    Connections {
        target: Dock
        function onPinnedChanged() { root.sync(pinnedModel, Dock.pinned); }
        function onRunningChanged() { root.sync(runningModel, Dock.running); }
    }

    Component.onCompleted: {
        sync(pinnedModel, Dock.pinned);
        sync(runningModel, Dock.running);
    }

    HoverHandler { id: islandHover }

    HoverDismiss {
        active: root.previewOpen
        hovered: islandHover.hovered || root.bgHovered || menuHover.hovered
        onDismissed: GlobalStates.dockPreview = ""
    }

    EmptyContent {
        id: emptyContent
        anchors.centerIn: parent
        opacity: root.empty ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.dock.spacing
        scale: 1 + (Theme.dock.notchIconScale - 1) * root.lift

        Repeater {
            model: pinnedModel

            DockItem {
                id: dockItem
                listModel: pinnedModel
                onHoveredChanged: if (hovered) root.hoveredItem = dockItem; else if (root.hoveredItem === dockItem) root.hoveredItem = null
            }
        }

        Item {
            implicitWidth: root.showDivider ? Theme.dock.dividerWidth + Theme.spacing.sm * 2 : 0
            implicitHeight: Theme.dock.itemSize
            opacity: root.showDivider ? 1 : 0

            Behavior on implicitWidth {
                NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
            }
            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.fast }
            }

            Rectangle {
                anchors.centerIn: parent
                width: Theme.dock.dividerWidth
                height: Theme.dock.dividerHeight
                radius: width / 2
                color: Colors.outlineVariant
            }
        }

        Repeater {
            model: runningModel

            DockItem {
                id: dockItem
                listModel: runningModel
                onHoveredChanged: if (hovered) root.hoveredItem = dockItem; else if (root.hoveredItem === dockItem) root.hoveredItem = null
            }
        }
    }

    Rectangle {
        id: tooltip

        readonly property bool show: root.notch <= 0.5 && Settings.bar.dockTooltips && root.hoveredItem !== null && !root.menuOpen
        property string text: ""
        property real centerX: 0

        onShowChanged: if (show) update()
        Connections {
            target: root
            function onHoveredItemChanged() { if (root.hoveredItem) tooltip.update(); }
        }

        function update() {
            text = root.hoveredItem?.app?.name ?? "";
            centerX = root.hoveredItem ? root.hoveredItem.mapToItem(root, root.hoveredItem.width / 2, 0).x : centerX;
        }

        x: Math.round(centerX - width / 2)
        y: root.height + Theme.dock.tooltipGap
        width: label.implicitWidth + Theme.spacing.md * 2
        height: label.implicitHeight + Theme.spacing.xs * 2
        radius: height / 2
        color: Colors.inverseSurface
        opacity: show ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }
        Behavior on x {
            enabled: tooltip.opacity > 0
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: tooltip.text
            color: Colors.inverseOnSurface
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }
    }

    Item {
        id: drip

        readonly property bool peek: root.notch > 0.5 && root.previewOpen
        readonly property bool show: peek || (root.notch > 0.5 && Settings.bar.dockTooltips && root.hoveredItem !== null && !root.contextOpen)
        readonly property real hookSize: Theme.dock.dripHook
        readonly property real bodyHeight: dripLabel.implicitHeight + Theme.spacing.xs * 2
        property real labelWidth: dripLabel.implicitWidth + Theme.spacing.md * 2
        readonly property real labelX: root.dripX(centerX, labelWidth)
        readonly property bool hookLeft: x - hookSize >= root.bottomRadius - 1
        readonly property bool hookRight: x + width + hookSize <= root.width - root.bottomRadius + 1
        readonly property real cornerRadius: Math.min(height, width) / 2 * (1 - grow) + Theme.radius.large * grow
        property string text: ""
        property real centerX: 0
        property real drop: show ? 1 : 0
        property real grow: peek ? 1 : 0

        onShowChanged: if (show) update()
        Connections {
            target: root
            function onHoveredItemChanged() { if (root.hoveredItem) drip.update(); }
        }

        function update() {
            text = root.hoveredItem?.app?.name ?? "";
            centerX = root.centerOf(root.hoveredItem);
        }

        x: Math.round(labelX + (menuArea.x - labelX) * grow)
        y: root.height - 1
        width: labelWidth + (preview.width - labelWidth) * grow
        height: (bodyHeight + (preview.height - bodyHeight) * grow) * Math.max(0, drop)
        visible: drop > 0.01

        Behavior on drop {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on centerX {
            enabled: drip.visible
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }
        Behavior on labelWidth {
            NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
        }
        Behavior on grow {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }

        Rectangle {
            anchors.fill: parent
            color: root.fill
            topLeftRadius: drip.hookLeft ? 0 : drip.cornerRadius
            topRightRadius: drip.hookRight ? 0 : drip.cornerRadius
            bottomLeftRadius: drip.cornerRadius
            bottomRightRadius: drip.cornerRadius
        }

        Shape {
            x: -drip.hookSize
            width: drip.hookSize
            height: drip.hookSize
            visible: drip.hookLeft
            scale: Math.min(1, Math.max(0, drip.drop))
            transformOrigin: Item.TopRight
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: -1
                fillColor: root.fill
                startX: 0; startY: 0
                PathLine { x: drip.hookSize; y: 0 }
                PathLine { x: drip.hookSize; y: drip.hookSize }
                PathArc { x: 0; y: 0; radiusX: drip.hookSize; radiusY: drip.hookSize; direction: PathArc.Counterclockwise }
            }
        }

        Shape {
            x: drip.width
            width: drip.hookSize
            height: drip.hookSize
            visible: drip.hookRight
            scale: Math.min(1, Math.max(0, drip.drop))
            transformOrigin: Item.TopLeft
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: -1
                fillColor: root.fill
                startX: drip.hookSize; startY: 0
                PathLine { x: 0; y: 0 }
                PathLine { x: 0; y: drip.hookSize }
                PathArc { x: drip.hookSize; y: 0; radiusX: drip.hookSize; radiusY: drip.hookSize }
            }
        }

        Text {
            id: dripLabel
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height - drip.bodyHeight + Theme.spacing.xs
            text: drip.text
            color: Colors.textOnSurface
            opacity: Math.max(0, Math.min(1, (drip.drop - 0.6) / 0.4)) * Math.max(0, 1 - drip.grow * 3)
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
        }
    }

    Item {
        id: menuArea

        property real centerX: root.width / 2

        HoverHandler { id: menuHover }
        x: root.notch > 0.5 ? root.dripX(centerX, width) : root.placeUnder(centerX, width)
        anchors.top: parent.bottom
        anchors.topMargin: root.notch > 0.5 ? -1 : Theme.spacing.sm
        width: preview.width
        height: root.previewOpen ? preview.height : 0

        Behavior on centerX {
            enabled: preview.visible
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }

        DockPreview {
            id: preview
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            key: root.previewOpen ? GlobalStates.dockPreview : ""
            attached: root.notch > 0.5
            onRequestClose: GlobalStates.dockPreview = ""
        }
    }

    Item {
        id: contextArea

        property real centerX: root.width / 2

        x: root.placeUnder(centerX, width)
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        width: contextMenu.width
        height: root.contextOpen ? contextMenu.height : 0

        DockContextMenu {
            id: contextMenu
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            key: root.contextOpen ? GlobalStates.dockContext : ""
            onRequestClose: GlobalStates.dockContext = ""
        }
    }
}
