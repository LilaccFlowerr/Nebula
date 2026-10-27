import QtQuick
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
    implicitWidth: Math.max(Theme.bar.centerMinWidth, (empty ? emptyContent.implicitWidth + Theme.spacing.lg * 2 : row.implicitWidth) + margin * 2)
    implicitHeight: Theme.bar.height

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

    function placeUnder(centerX, w) {
        const left = root.x;
        const room = QsWindow.window?.width ?? root.width;
        const m = Theme.bar.floatMargin;
        return Math.round(Math.max(m - left, Math.min(room - m - left - w, centerX - w / 2)));
    }

    Connections {
        target: GlobalStates
        function onDockPreviewChanged() { if (GlobalStates.dockPreview !== "") menuArea.centerX = root.centerOf(root.hoveredItem); }
        function onDockContextChanged() { if (GlobalStates.dockContext !== "") contextArea.centerX = root.centerOf(root.hoveredItem); }
    }

    Behavior on implicitWidth {
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
        hovered: islandHover.hovered || menuHover.hovered
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

        readonly property bool show: Settings.bar.dockTooltips && root.hoveredItem !== null && !root.menuOpen
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
        id: menuArea

        property real centerX: root.width / 2

        HoverHandler { id: menuHover }
        x: root.placeUnder(centerX, width)
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
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
