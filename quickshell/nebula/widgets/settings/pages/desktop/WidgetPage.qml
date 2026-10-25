import QtQuick
import QtQuick.Layouts
import Quickshell
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    property string arg: ""
    readonly property var cfg: Widgets.get(arg) ?? ({})
    readonly property bool shapeLocked: cfg.type === "weather" && (cfg.follow ?? true)
    readonly property var type: Widgets.types[cfg.type] ?? ({ title: "", icon: "widgets", size: 200, minSize: 80, maxSize: 600, color: "secondary" })

    signal navigate(string target)

    function set(props) {
        Widgets.update(arg, props);
    }

    function center() {
        const screen = Widgets.screenNamed(cfg.screen ?? "");
        const size = cfg.size ?? type.size;
        set({ x: Math.round((screen.width - size) / 2), y: Math.round((screen.height - size) / 2) });
    }

    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Look"

        SettingRow {
            icon: "category"
            title: "Shape"
            subtitle: page.shapeLocked ? "Follows the weather" : cfg.shape ?? ""
        }

        Item {
            Layout.fillWidth: true
            visible: !page.shapeLocked
            implicitHeight: shapeFlow.implicitHeight + Theme.spacing.md * 2

            Flow {
                id: shapeFlow
                x: Theme.spacing.md
                y: Theme.spacing.md
                width: parent.width - Theme.spacing.md * 2
                spacing: Theme.spacing.xs

                Repeater {
                    model: Widgets.shapes

                    Rectangle {
                        id: chip

                        required property string modelData
                        readonly property bool active: modelData === page.cfg.shape

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
                            onClicked: page.set({ shape: chip.modelData })
                        }
                    }
                }
            }
        }

        SettingRow {
            icon: "aspect_ratio"
            title: "Size"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: page.type.minSize
                to: page.type.maxSize
                stepSize: 10
                value: page.cfg.size ?? page.type.size
                onMoved: page.set({ size: Math.round(value / 10) * 10 })
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: page.cfg.size ?? page.type.size
                from: page.type.minSize
                to: page.type.maxSize
                step: 10
                suffix: " px"
                onEdited: value => page.set({ size: value })
            }
        }

        SettingRow {
            icon: "palette"
            title: "Color"

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.sm

                Repeater {
                    model: Widgets.colorRoles

                    Rectangle {
                        id: dot

                        required property string modelData
                        readonly property bool active: modelData === (page.cfg.color ?? page.type.color)

                        width: Theme.button.size - Theme.spacing.xs
                        height: width
                        radius: width / 2
                        color: Widgets.palette(modelData).fill
                        border.width: active ? 3 : 1
                        border.color: active ? Colors.primary : Colors.outlineVariant

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.set({ color: dot.modelData })
                        }
                    }
                }
            }
        }

        SettingRow {
            icon: "opacity"
            title: "Opacity"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 20
                to: 100
                stepSize: 5
                value: (page.cfg.opacity ?? 1) * 100
                onMoved: page.set({ opacity: Math.round(value / 5) * 5 / 100 })
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Math.round((page.cfg.opacity ?? 1) * 100)
                from: 20
                to: 100
                step: 5
                suffix: " %"
                onEdited: value => page.set({ opacity: value / 100 })
            }
        }
    }

    WidgetOptions {
        Layout.fillWidth: true
        arg: page.arg
        onNavigate: target => page.navigate(target)
    }

    SettingGroup {
        title: "Position"

        SettingRow {
            icon: "open_with"
            title: "Position"
            subtitle: (page.cfg.x ?? -1) < 0 ? "Bottom left" : "Drag it on your desktop, or type it"

            ActionButton {
                icon: "center_focus_strong"
                text: "Center"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: page.center()
            }

            IconButton {
                icon: "restart_alt"
                visible: page.cfg.type === "nowplaying" && ((page.cfg.x ?? -1) >= 0 || (page.cfg.y ?? -1) >= 0)
                anchors.verticalCenter: parent.verticalCenter
                onClicked: page.set({ x: -1, y: -1 })
            }
        }

        SettingRow {
            icon: "desktop_windows"
            title: "Screen"
            subtitle: !cfg.screen ? "Same widget on every screen" : "Only on this screen"

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.sm

                Repeater {
                    model: [{ name: "All", value: "" }].concat(Quickshell.screens.map(s => ({ name: s.name, value: s.name })))

                    Rectangle {
                        id: screenChip

                        required property var modelData
                        readonly property bool active: modelData.value === (page.cfg.screen ?? "")

                        implicitWidth: screenText.implicitWidth + Theme.spacing.lg * 2
                        implicitHeight: Theme.button.size - Theme.spacing.xs
                        radius: active ? height / 2 : Theme.radius.medium
                        color: active ? Colors.secondaryContainer : "transparent"
                        border.width: active ? 0 : 1
                        border.color: Colors.outlineVariant

                        Behavior on radius {
                            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                        }

                        Text {
                            id: screenText
                            anchors.centerIn: parent
                            text: screenChip.modelData.name
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            font.weight: screenChip.active ? Font.DemiBold : Font.Normal
                            color: screenChip.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.set({ screen: screenChip.modelData.value })
                        }
                    }
                }
            }
        }

        SettingRow {
            icon: "swap_horiz"
            title: "Horizontal"
            visible: (page.cfg.x ?? -1) >= 0

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Math.round(page.cfg.x ?? 0)
                from: 0
                to: 8000
                step: 10
                suffix: " px"
                onEdited: value => page.set({ x: value })
            }
        }

        SettingRow {
            icon: "swap_vert"
            title: "Vertical"
            visible: (page.cfg.y ?? -1) >= 0

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Math.round(page.cfg.y ?? 0)
                from: 0
                to: 8000
                step: 10
                suffix: " px"
                onEdited: value => page.set({ y: value })
            }
        }
    }

    SettingGroup {
        title: "Widget"

        SettingRow {
            icon: "visibility"
            title: "Show on desktop"
            clickable: true
            onClicked: page.set({ enabled: !page.cfg.enabled })

            Switch {
                checked: page.cfg.enabled === true
                onToggled: page.set({ enabled: !page.cfg.enabled })
            }
        }

        SettingRow {
            icon: "delete"
            title: "Remove widget"
            subtitle: "Gone for good"

            ActionButton {
                icon: "delete"
                text: "Remove"
                danger: true
                filled: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    const id = page.arg;
                    page.navigate("");
                    Widgets.remove(id);
                }
            }
        }
    }
}
