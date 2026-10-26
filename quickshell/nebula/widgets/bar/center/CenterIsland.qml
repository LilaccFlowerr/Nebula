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
    readonly property bool menuOpen: GlobalStates.dockMenu !== "" && GlobalStates.isOn(QsWindow.window?.screen?.name ?? "")
    readonly property bool showDivider: Dock.pinned.length > 0 && Dock.running.length > 0
    property Item hoveredItem: null

    property alias menuArea: menuArea

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
        active: root.menuOpen
        hovered: islandHover.hovered || menuHover.hovered
        onDismissed: GlobalStates.dockMenu = ""
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

        HoverHandler { id: menuHover }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: Theme.spacing.sm
        width: menu.width
        height: root.menuOpen ? menu.height : 0

        DockMenu {
            id: menu
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            key: root.menuOpen ? GlobalStates.dockMenu : ""
            onRequestClose: GlobalStates.dockMenu = ""
        }
    }
}
