import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: tab

    readonly property var scales: ["1", "1.25", "1.5", "2"]
    readonly property int enabledCount: HyprConfig.monitors.filter(m => !m.disabled).length

    spacing: Theme.spacing.xl

    Component.onCompleted: HyprConfig.refresh()

    Repeater {
        model: HyprConfig.monitors

        SettingGroup {
            id: monitor
            required property var modelData

            title: modelData.name + (modelData.description ? " · " + modelData.description : "")

            SettingRow {
                icon: monitor.modelData.disabled ? "desktop_access_disabled" : "desktop_windows"
                title: "Use this display"
                subtitle: monitor.modelData.disabled ? "Turned off" : monitor.modelData.mode + " Hz"
                clickable: monitor.modelData.disabled || tab.enabledCount > 1
                onClicked: HyprConfig.setMonitor(monitor.modelData.name, { disabled: !monitor.modelData.disabled })

                Switch {
                    visible: monitor.modelData.disabled || tab.enabledCount > 1
                    checked: !monitor.modelData.disabled
                    onToggled: HyprConfig.setMonitor(monitor.modelData.name, { disabled: !monitor.modelData.disabled })
                }
            }

            SettingRow {
                visible: !monitor.modelData.disabled
                icon: "aspect_ratio"
                title: "Resolution"
            }

            Flow {
                visible: !monitor.modelData.disabled
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spacing.lg + Theme.spacing.xs
                Layout.rightMargin: Theme.spacing.lg
                Layout.bottomMargin: Theme.spacing.md
                spacing: Theme.spacing.sm

                Repeater {
                    model: monitor.modelData.modes

                    Rectangle {
                        id: chip
                        required property string modelData
                        readonly property bool active: modelData === monitor.modelData.mode

                        implicitWidth: chipText.implicitWidth + Theme.spacing.lg * 2
                        implicitHeight: Theme.button.size - Theme.spacing.sm
                        radius: active ? height / 2 : Theme.radius.small
                        color: active ? Colors.secondaryContainer : chipMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.08) : "transparent"
                        border.width: active ? 0 : 1
                        border.color: Colors.outlineVariant

                        Behavior on radius {
                            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                        }

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: chip.modelData.replace("@", " · ") + " Hz"
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            font.weight: chip.active ? Font.DemiBold : Font.Normal
                            color: chip.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }

                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: HyprConfig.setMonitor(monitor.modelData.name, { mode: chip.modelData })
                        }
                    }
                }
            }

            SettingRow {
                visible: !monitor.modelData.disabled
                icon: "zoom_in"
                title: "Scale"
                subtitle: "WARNING dont select 2x size unless you wanna be stuck"

                SegmentedButton {
                    width: Theme.settings.controlWidth
                    options: tab.scales
                    currentIndex: tab.scales.indexOf(String(Math.round(monitor.modelData.scale * 100) / 100))
                    onSelected: index => HyprConfig.setMonitor(monitor.modelData.name, { scale: Number(tab.scales[index]) })
                }
            }
        }
    }

    SettingGroup {
        visible: Brightness.available
        title: "Brightness"

        SettingRow {
            icon: "brightness_medium"
            title: "Screen brightness"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                value: Brightness.level
                onMoved: Brightness.setBrightness(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Brightness.percent
                from: 1
                to: 100
                suffix: "%"
                onEdited: value => Brightness.setBrightness(value / 100)
            }
        }
    }
}
