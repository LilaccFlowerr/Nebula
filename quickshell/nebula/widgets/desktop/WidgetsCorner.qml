import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

PanelWindow {
    id: window

    anchors {
        bottom: true
        left: true
    }
    implicitWidth: Theme.widgetCorner.windowWidth
    implicitHeight: Theme.widgetCorner.windowHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:widgetcorner"

    mask: Region { item: hitArea }

    property bool open: false
    property bool adding: false
    property string filter: "all"
    onOpenChanged: if (!open) adding = false
    readonly property color fill: Qt.alpha(Colors.surface, Theme.bar.opacity)

    readonly property var screens: Quickshell.screens.map(s => s.name)
    readonly property bool anyHidden: Widgets.list.some(w => w.enabled !== true)
    readonly property var filters: [{ key: "all", text: "All" }]
        .concat(screens.length > 1 ? screens.map(s => ({ key: "screen:" + s, text: s })) : [])
        .concat(anyHidden ? [{ key: "hidden", text: "Hidden" }] : [])
    readonly property var shownIds: Widgets.list.filter(matches).map(w => w.id)

    function matches(w) {
        if (filter === "hidden") return w.enabled !== true;
        if (filter.startsWith("screen:")) return !w.screen || w.screen === filter.slice(7);
        return true;
    }

    function addType(entry) {
        if (entry.picker) {
            window.open = false;
            Widgets.openPicker("", window.screen.name);
            return;
        }
        const props = { screen: window.screen.name };
        if (entry.key === "nowplaying") Object.assign(props, { x: -1, y: -1 });
        Widgets.add(entry.key, props);
        adding = false;
    }

    function edit(id) {
        window.open = false;
        Widgets.edit(id);
    }

    function openSettings(tab) {
        window.open = false;
        GlobalStates.openSettings("desktop", tab);
    }

    onFiltersChanged: if (!filters.some(f => f.key === filter)) filter = "all"

    Timer {
        id: closeTimer
        interval: Theme.recorder.closeDelay
        onTriggered: window.open = false
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop();
                window.open = true;
            } else {
                closeTimer.restart();
            }
        }
    }

    readonly property real targetWidth: open ? Theme.widgetCorner.openWidth : Theme.recorder.hotWidth - Theme.recorder.flare * 2
    readonly property real targetHeight: open ? content.implicitHeight + Theme.spacing.lg * 2 : 0

    Item {
        id: hitArea
        anchors.left: blob.left
        anchors.leftMargin: -Theme.recorder.flare
        anchors.bottom: parent.bottom
        width: Math.max(Theme.recorder.hotWidth, window.targetWidth + Theme.recorder.flare * 2)
        height: Math.max(Theme.recorder.hotHeight, window.targetHeight)
    }

    component Chip: Rectangle {
        id: chip

        property string text
        property bool active

        signal clicked()

        implicitWidth: chipText.implicitWidth + Theme.spacing.lg * 2
        implicitHeight: 32
        radius: active ? height / 2 : Theme.radius.small
        color: active ? Colors.secondaryContainer : chipMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.06) : "transparent"
        border.width: active ? 0 : 1
        border.color: Colors.outlineVariant

        Behavior on radius {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
        }

        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.text
            color: chip.active ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
            font.family: Theme.font.family
            font.pixelSize: Theme.font.small
            font.weight: chip.active ? Font.DemiBold : Font.Normal
        }

        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    component Preview: Item {
        id: preview

        property var cfg: ({})
        property string icon: "widgets"
        property bool dim: false
        readonly property var colors: Widgets.palette(cfg.color)

        opacity: dim ? 0.4 : 1

        ShapedArt {
            anchors.fill: parent
            visible: preview.cfg.type === "image"
            shape: MaterialShape[preview.cfg.shape ?? "Clover4Leaf"] ?? MaterialShape.Clover4Leaf
            color: preview.colors.fill
            source: visible && preview.cfg.source ? Wallpaper.url(preview.cfg.source) : ""
            sourceSize: Qt.size(width * 2, height * 2)
            zoom: preview.cfg.zoom ?? 1
            panX: preview.cfg.panX ?? 0
            panY: preview.cfg.panY ?? 0
            animationDuration: Theme.anim.medium
        }

        MaterialShape {
            anchors.fill: parent
            visible: preview.cfg.type !== "image"
            shape: MaterialShape[preview.cfg.shape ?? "Circle"] ?? MaterialShape.Circle
            color: preview.colors.fill
            animationDuration: Theme.anim.medium

            Text {
                anchors.centerIn: parent
                text: preview.icon
                font.family: Theme.font.icons
                font.pixelSize: preview.width * 0.42
                color: preview.colors.text
            }
        }
    }

    Rectangle {
        id: blob
        anchors.left: parent.left
        anchors.leftMargin: Theme.recorder.margin
        anchors.bottom: parent.bottom
        width: window.targetWidth
        height: window.targetHeight
        topLeftRadius: Theme.radius.large
        topRightRadius: Theme.radius.large
        color: window.fill
        clip: true

        Behavior on width {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on height {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        ColumnLayout {
            id: content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.lg
            visible: window.open
            spacing: Theme.spacing.md

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                IconButton {
                    implicitWidth: 36
                    implicitHeight: 36
                    visible: window.adding
                    icon: "arrow_back"
                    onClicked: window.adding = false
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: window.adding ? "Add widget" : "Widgets"
                        color: Colors.textOnSurface
                        font.family: Theme.font.family
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: !window.adding
                        text: Widgets.list.length === 1 ? "1 on your desktop" : Widgets.list.length + " on your desktop"
                        color: Colors.textOnSurfaceVariant
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                    }
                }

                ActionButton {
                    visible: !window.adding
                    icon: "add"
                    text: "Add"
                    filled: true
                    onClicked: window.adding = true
                }

                IconButton {
                    implicitWidth: 36
                    implicitHeight: 36
                    visible: !window.adding
                    icon: "settings"
                    onClicked: window.openSettings("")
                }
            }

            Row {
                visible: !window.adding && window.filters.length > 1
                spacing: Theme.spacing.sm

                Repeater {
                    model: window.filters

                    Chip {
                        required property var modelData
                        text: modelData.text
                        active: window.filter === modelData.key
                        onClicked: window.filter = modelData.key
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true
                visible: !window.adding
                implicitHeight: Math.min(contentHeight, Theme.widgetCorner.listHeight)
                contentHeight: list.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: list
                    width: parent.width
                    spacing: Theme.settings.rowGap

                    Repeater {
                        model: Widgets.idModel

                        Rectangle {
                            id: entry

                            required property string modelData
                            readonly property var cfg: Widgets.get(modelData) ?? ({})
                            readonly property var kind: Widgets.types[cfg.type] ?? ({ icon: "widgets", size: 200 })
                            readonly property bool on: cfg.enabled === true
                            readonly property int position: window.shownIds.indexOf(modelData)
                            readonly property real outer: Theme.radius.large
                            readonly property real inner: Theme.settings.rowRadius

                            width: list.width
                            height: Theme.widgetCorner.rowHeight
                            visible: position >= 0
                            topLeftRadius: position === 0 ? outer : inner
                            topRightRadius: topLeftRadius
                            bottomLeftRadius: position === window.shownIds.length - 1 ? outer : inner
                            bottomRightRadius: bottomLeftRadius
                            color: rowMouse.containsMouse ? Qt.tint(Colors.surfaceContainerHigh, Qt.alpha(Colors.textOnSurface, 0.05)) : Colors.surfaceContainerHigh

                            Behavior on color {
                                ColorAnimation { duration: Theme.anim.fast }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: window.edit(entry.modelData)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacing.md
                                anchors.rightMargin: Theme.spacing.lg
                                spacing: Theme.spacing.md

                                Preview {
                                    Layout.preferredWidth: Theme.widgetCorner.previewSize
                                    Layout.preferredHeight: Theme.widgetCorner.previewSize
                                    cfg: entry.cfg
                                    icon: entry.kind.icon
                                    dim: !entry.on
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: Widgets.label(entry.cfg)
                                        elide: Text.ElideRight
                                        color: entry.on ? Colors.textOnSurface : Colors.textOnSurfaceVariant
                                        font.family: Theme.font.family
                                        font.pixelSize: Theme.font.normal
                                        font.weight: Font.Medium
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: (entry.cfg.screen || "All screens") + " · " + Math.round(entry.cfg.size ?? entry.kind.size) + " px"
                                        elide: Text.ElideRight
                                        color: Colors.textOnSurfaceVariant
                                        font.family: Theme.font.family
                                        font.pixelSize: Theme.font.small
                                    }
                                }

                                IconButton {
                                    implicitWidth: 36
                                    implicitHeight: 36
                                    icon: "tune"
                                    onClicked: window.edit(entry.modelData)
                                }

                                Switch {
                                    checked: entry.on
                                    onToggled: Widgets.update(entry.modelData, { enabled: !entry.on })
                                }
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: !window.adding
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: Widgets.list.length === 0 ? "No widgets yet. Add one to get started" : window.shownIds.length === 0 ? "Nothing here" : "Right click a widget on the desktop to edit it"
                color: Colors.textOnSurfaceVariant
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
            }

            GridLayout {
                Layout.fillWidth: true
                visible: window.adding
                columns: 2
                rowSpacing: Theme.spacing.sm
                columnSpacing: Theme.spacing.sm

                Repeater {
                    model: window.adding ? Widgets.available() : []

                    Rectangle {
                        id: option

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        implicitHeight: Theme.widgetCorner.tileHeight
                        radius: Theme.radius.large
                        color: optionMouse.containsMouse ? Colors.secondaryContainer : Colors.surfaceContainerHigh

                        Behavior on color {
                            ColorAnimation { duration: Theme.anim.fast }
                        }

                        MouseArea {
                            id: optionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.addType(option.modelData)
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacing.md
                            spacing: 2

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Preview {
                                    anchors.centerIn: parent
                                    width: Theme.widgetCorner.tileShape
                                    height: width
                                    cfg: ({ type: option.modelData.key === "image" ? "" : option.modelData.key, shape: option.modelData.shape, color: option.modelData.color })
                                    icon: option.modelData.icon
                                    scale: optionMouse.containsMouse ? 1.08 : 1

                                    Behavior on scale {
                                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: option.modelData.title
                                elide: Text.ElideRight
                                color: optionMouse.containsMouse ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.normal
                                font.weight: Font.DemiBold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: option.modelData.description
                                elide: Text.ElideRight
                                color: optionMouse.containsMouse ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.small
                            }
                        }
                    }
                }
            }
        }
    }

    Shape {
        anchors.left: blob.right
        anchors.bottom: parent.bottom
        width: Theme.recorder.flare
        height: Theme.recorder.flare
        visible: blob.height > Theme.recorder.flare
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillColor: window.fill
            startX: Theme.recorder.flare; startY: Theme.recorder.flare
            PathArc { x: 0; y: 0; radiusX: Theme.recorder.flare; radiusY: Theme.recorder.flare; direction: PathArc.Clockwise }
            PathLine { x: 0; y: Theme.recorder.flare }
        }
    }
}
