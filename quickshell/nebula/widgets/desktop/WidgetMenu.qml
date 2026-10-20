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
    readonly property var kind: Widgets.types[cfg.type] ?? ({ size: 200, minSize: 80, maxSize: 600, color: "secondary" })
    readonly property bool open: Widgets.menuId !== "" && Widgets.menuScreen === modelData.name && cfg.id !== undefined
    readonly property real gap: Theme.spacing.md
    readonly property real cardWidth: 352

    function set(props) {
        Widgets.update(Widgets.menuId, props);
    }

    function more() {
        const id = Widgets.menuId;
        Widgets.closeMenu();
        GlobalStates.openSettings("desktop", "widget:" + id);
    }

    function center() {
        const size = cfg.size ?? type.size;
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

    Rectangle {
        id: card

        readonly property real targetX: Widgets.menuX - window.modelData.x
        readonly property real targetY: Widgets.menuY - window.modelData.y
        readonly property real rightX: targetX + Widgets.menuW + window.gap

        width: window.cardWidth
        height: column.implicitHeight + Theme.spacing.lg * 2
        x: rightX + width + window.gap <= window.modelData.width ? rightX : Math.max(window.gap, targetX - width - window.gap)
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
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

                MaterialShape {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    shape: MaterialShape[window.cfg.shape ?? "Circle"] ?? MaterialShape.Circle
                    color: Widgets.palette(window.cfg.color).fill
                    animationDuration: Theme.anim.medium
                }

                Text {
                    Layout.fillWidth: true
                    text: Widgets.label(window.cfg)
                    elide: Text.ElideRight
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                }

                IconButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    icon: "tune"
                    onClicked: window.more()
                }
            }

            TextField {
                Layout.fillWidth: true
                visible: window.cfg.type === "text"
                text: window.cfg.source ?? ""
                placeholder: "Write something"
                onEdited: text => window.set({ source: text })
            }

            Flickable {
                id: shapeFlick
                Layout.fillWidth: true
                implicitHeight: Theme.button.size
                contentWidth: shapeRow.implicitWidth
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick

                WheelHandler {
                    onWheel: event => {
                        const max = Math.max(0, shapeFlick.contentWidth - shapeFlick.width);
                        shapeFlick.contentX = Math.max(0, Math.min(max, shapeFlick.contentX - event.angleDelta.y));
                    }
                }

                Row {
                    id: shapeRow
                    spacing: Theme.spacing.xs

                    Repeater {
                        model: Widgets.shapes

                        Rectangle {
                            id: chip

                            required property string modelData
                            readonly property bool active: modelData === window.cfg.shape

                            width: Theme.button.size
                            height: Theme.button.size
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

            RowLayout {
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
                Layout.fillWidth: true
                spacing: Theme.spacing.sm

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

                IconButton {
                    implicitWidth: 36
                    implicitHeight: 36
                    icon: "center_focus_strong"
                    onClicked: window.center()
                }

                IconButton {
                    implicitWidth: 36
                    implicitHeight: 36
                    icon: "image"
                    visible: window.cfg.type === "image"
                    onClicked: window.openImagePicker()
                }

                IconButton {
                    implicitWidth: 36
                    implicitHeight: 36
                    icon: "delete"
                    onClicked: {
                        const id = Widgets.menuId;
                        Widgets.closeMenu();
                        Widgets.remove(id);
                    }
                }
            }
        }
    }

    function openImagePicker() {
        const id = Widgets.menuId;
        Widgets.closeMenu();
        Widgets.replacing = id;
        GlobalStates.openSettings("desktop", "images");
    }
}
