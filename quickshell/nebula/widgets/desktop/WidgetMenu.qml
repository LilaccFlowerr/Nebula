import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components
import qs.widgets.settings.pages.desktop

PanelWindow {
    id: window

    required property ShellScreen modelData

    screen: modelData
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: window.open ? cardMask : emptyMask

    property Region cardMask: Region { item: card }
    property Region emptyMask: Region {}

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:widgetmenu"

    readonly property var cfg: Widgets.get(Widgets.menuId) ?? ({})
    readonly property bool shapeLocked: cfg.type === "weather" && (cfg.follow ?? true)
    readonly property var kind: Widgets.types[cfg.type] ?? ({ size: 200, minSize: 80, maxSize: 600, color: "secondary" })
    readonly property bool open: Widgets.menuId !== "" && Widgets.menuScreen === modelData.name && cfg.id !== undefined
    readonly property real gap: Theme.spacing.md

    function set(props) {
        Widgets.update(Widgets.menuId, props);
    }

    function more() {
        const id = Widgets.menuId;
        Widgets.closeMenu();
        GlobalStates.openSettings("desktop", "widget:" + id);
    }

    readonly property string menuType: cfg.type ?? ""
    readonly property var actions: [
        Widgets.menuExpanded ? { key: "edit", icon: "close_fullscreen", text: "Less" } : { key: "edit", icon: "tune", text: "Edit" },
        { key: "duplicate", icon: "content_copy", text: "Duplicate", hidden: !!Widgets.types[menuType]?.single },
        { key: "center", icon: "center_focus_strong", text: "Center" },
        { key: "image", icon: "image", text: "Image", hidden: menuType !== "image" },
        { key: "remove", icon: "delete", text: "Hold to remove", danger: true, hold: true }
    ].filter(a => !a.hidden)

    function act(key) {
        const id = Widgets.menuId;
        switch (key) {
        case "edit": Widgets.menuExpanded = !Widgets.menuExpanded; break;
        case "center": center(); break;
        case "image": pick(); break;
        case "duplicate":
            Widgets.closeMenu();
            Widgets.duplicate(id);
            break;
        case "remove":
            Widgets.closeMenu();
            Widgets.remove(id);
            break;
        }
    }

    function pick() {
        Widgets.openPicker(Widgets.menuId, modelData.name);
    }

    function center() {
        const size = cfg.size ?? kind.size;
        set({
            x: Math.round((modelData.width - size) / 2),
            y: Math.round((modelData.height - size) / 2)
        });
    }

    HyprlandFocusGrab {
        windows: [window]
        active: window.open
        onCleared: Widgets.closeMenu()
    }

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            if (window.open) Widgets.closeMenu();
        }

        function onFocusedMonitorChanged() {
            if (window.open) Widgets.closeMenu();
        }
    }

    property real expand: Widgets.menuExpanded ? 1 : 0

    Behavior on expand {
        NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
    }

    Rectangle {
        id: card

        readonly property real targetX: Widgets.menuX - window.modelData.x
        readonly property real targetY: Widgets.menuY - window.modelData.y
        readonly property real rightX: targetX + Widgets.menuW + window.gap
        readonly property real fixedHeight: header.height + sizeRow.height + opacityRow.height + colorRow.height + actionRow.height + column.spacing * 5 + Theme.spacing.lg * 2 + (textField.visible ? textField.height + column.spacing : 0)
        readonly property real maxBody: window.modelData.height - window.gap * 2 - fixedHeight

        width: Theme.widgetEditor.compactWidth + (Theme.widgetEditor.fullWidth - Theme.widgetEditor.compactWidth) * window.expand
        height: column.implicitHeight + Theme.spacing.lg * 2
        x: rightX + Theme.widgetEditor.fullWidth + window.gap <= window.modelData.width ? rightX : Math.max(window.gap, targetX - width - window.gap)
        y: Math.max(window.gap, Math.min(targetY, window.modelData.height - height - window.gap))
        radius: Theme.radius.large
        color: Qt.alpha(Colors.surfaceContainer, 0.97)
        border.width: 1
        border.color: Colors.outlineVariant
        opacity: window.open ? 1 : 0
        scale: window.open ? 1 : 0.92
        transformOrigin: Item.Left

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }

        Behavior on scale {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            spacing: Theme.spacing.md

            RowLayout {
                id: header
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                MaterialShape {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    shape: MaterialShape[window.cfg.shape ?? "Circle"] ?? MaterialShape.Circle
                    color: Widgets.palette(window.cfg.color).fill
                    animationDuration: Theme.anim.medium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: Widgets.label(window.cfg)
                        elide: Text.ElideRight
                        color: Colors.textOnSurface
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.large
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: (window.cfg.screen || "All screens") + " · " + Math.round(window.cfg.size ?? window.kind.size) + " px"
                        elide: Text.ElideRight
                        color: Colors.textOnSurfaceVariant
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                    }
                }

                IconButton {
                    implicitWidth: 36
                    implicitHeight: 36
                    icon: "open_in_new"
                    onClicked: window.more()
                }
            }

            TextField {
                id: textField
                Layout.fillWidth: true
                visible: window.cfg.type === "text" && !Widgets.menuExpanded
                text: window.cfg.source ?? ""
                placeholder: "Write something"
                onEdited: text => window.set({ source: text })
            }

            RowLayout {
                id: sizeRow
                Layout.fillWidth: true
                spacing: Theme.spacing.md

                Text {
                    text: "aspect_ratio"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.textOnSurfaceVariant
                }

                Slider {
                    Layout.fillWidth: true
                    animated: false
                    from: window.kind.minSize
                    to: window.kind.maxSize
                    stepSize: 10
                    value: window.cfg.size ?? window.kind.size
                    onMoved: window.set({ size: Math.round(value / 10) * 10 })
                }

                Text {
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(window.cfg.size ?? window.kind.size)
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    color: Colors.textOnSurfaceVariant
                }
            }

            RowLayout {
                id: opacityRow
                Layout.fillWidth: true
                spacing: Theme.spacing.md

                Text {
                    text: "opacity"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.textOnSurfaceVariant
                }

                Slider {
                    Layout.fillWidth: true
                    animated: false
                    from: 20
                    to: 100
                    stepSize: 5
                    value: (window.cfg.opacity ?? 1) * 100
                    onMoved: window.set({ opacity: Math.round(value / 5) * 5 / 100 })
                }

                Text {
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                    text: Math.round((window.cfg.opacity ?? 1) * 100) + "%"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.small
                    color: Colors.textOnSurfaceVariant
                }
            }

            RowLayout {
                id: colorRow
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                Text {
                    Layout.rightMargin: Theme.spacing.xs
                    text: "palette"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.textOnSurfaceVariant
                }

                Repeater {
                    model: Widgets.colorRoles

                    Rectangle {
                        id: dot

                        required property string modelData
                        readonly property bool active: modelData === (window.cfg.color ?? window.kind.color)

                        implicitWidth: Theme.button.size - Theme.spacing.xs
                        implicitHeight: implicitWidth
                        radius: width / 2
                        color: Widgets.palette(modelData).fill
                        border.width: active ? 3 : 1
                        border.color: active ? Colors.primary : Colors.outlineVariant

                        Behavior on border.width {
                            NumberAnimation { duration: Theme.anim.fast }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.set({ color: dot.modelData })
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            Flickable {
                id: bodyFlick
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(body.implicitHeight, Math.max(0, card.maxBody)) * window.expand
                visible: window.expand > 0
                opacity: window.expand
                contentHeight: body.implicitHeight
                clip: true
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: body
                    width: bodyFlick.width
                    spacing: Theme.spacing.lg

                    SettingGroup {
                        title: "Shape"
                        visible: !window.shapeLocked

                        Item {
                            Layout.fillWidth: true
                            visible: !window.shapeLocked
                            implicitHeight: shapeGrid.implicitHeight + Theme.spacing.md * 2

                            Grid {
                                id: shapeGrid
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: Theme.spacing.md
                                columns: Theme.widgetEditor.shapeColumns
                                spacing: Theme.spacing.xs

                                Repeater {
                                    model: Widgets.shapes

                                    Rectangle {
                                        id: chip

                                        required property string modelData
                                        readonly property bool active: modelData === window.cfg.shape

                                        width: Theme.widgetEditor.shapeChip
                                        height: width
                                        radius: active ? height / 2 : Theme.radius.medium
                                        color: active ? Colors.secondaryContainer : chipMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.08) : "transparent"

                                        Behavior on radius {
                                            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                                        }

                                        MaterialShape {
                                            anchors.centerIn: parent
                                            width: Theme.settings.iconSize
                                            height: width
                                            shape: MaterialShape[chip.modelData] ?? MaterialShape.Circle
                                            color: chip.active ? Colors.textOnSecondaryContainer : Colors.primary
                                        }

                                        MouseArea {
                                            id: chipMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: window.set({ shape: chip.modelData })
                                        }
                                    }
                                }
                            }
                        }

                    }

                    WidgetOptions {
                        id: options
                        Layout.fillWidth: true
                        visible: options.hasOptions
                        arg: Widgets.menuId
                        spacing: Theme.spacing.lg
                        onNavigate: target => {
                            if (target !== "images") return;
                            Widgets.replacing = "";
                            window.pick();
                        }
                    }
                }
            }

            WidgetActions {
                id: actionRow
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.xs
                actions: window.actions
                onTriggered: key => window.act(key)
            }
        }
    }
}
