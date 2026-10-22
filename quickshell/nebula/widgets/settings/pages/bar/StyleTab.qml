import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Style"

        Repeater {
            model: [
                { key: "attached", icon: "toolbar", title: "Attached", subtitle: "Every island hooks onto the screen edge" },
                { key: "mixed", icon: "dock_to_bottom", title: "Mixed", subtitle: "The middle island hooks on, the sides float" },
                { key: "floating", icon: "web_asset", title: "Floating", subtitle: "All islands float" }
            ]

            SettingRow {
                required property var modelData
                readonly property bool chosen: Settings.bar.style === modelData.key

                icon: modelData.icon
                title: modelData.title
                subtitle: modelData.subtitle
                clickable: true
                onClicked: Settings.bar.style = modelData.key

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: chosen ? "radio_button_checked" : "radio_button_unchecked"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: chosen ? Colors.primary : Colors.textOnSurfaceVariant
                }
            }
        }
    }

    SettingGroup {
        title: "Look"

        SettingRow {
            visible: Settings.bar.style !== "attached"
            icon: "space_bar"
            title: "Gap to the edge"
            subtitle: "Space around floating islands"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 0
                to: 16
                stepSize: 1
                value: Settings.bar.gap
                onMoved: Settings.bar.gap = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.bar.gap
                from: 0
                to: 16
                suffix: " px"
                onEdited: value => Settings.bar.gap = value
            }
        }

        SettingRow {
            icon: "rounded_corner"
            title: "Corner radius"
            subtitle: "How round the islands are"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 4
                to: 28
                stepSize: 1
                value: Settings.bar.radius
                onMoved: Settings.bar.radius = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.bar.radius
                from: 4
                to: 28
                suffix: " px"
                onEdited: value => Settings.bar.radius = value
            }
        }

        SettingRow {
            icon: "opacity"
            title: "Opacity"
            subtitle: "Bar, popups and panels"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 40
                to: 100
                stepSize: 1
                value: Settings.bar.opacity
                onMoved: Settings.bar.opacity = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.bar.opacity
                from: 40
                to: 100
                suffix: "%"
                onEdited: value => Settings.bar.opacity = value
            }
        }

        SettingRow {
            icon: "pill"
            title: "Pill opacity"
            subtitle: "The pill inside the middle island"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 40
                to: 100
                stepSize: 1
                value: Settings.bar.pillOpacity
                onMoved: Settings.bar.pillOpacity = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.bar.pillOpacity
                from: 40
                to: 100
                suffix: "%"
                onEdited: value => Settings.bar.pillOpacity = value
            }
        }
    }

    SettingGroup {
        title: "Blur"

        SettingRow {
            icon: "blur_on"
            title: "Shell blur"
            subtitle: "Frosted glass behind the bar, popups and panels"
            clickable: true
            onClicked: Settings.blur.shell = !Settings.blur.shell

            Switch {
                checked: Settings.blur.shell
                onToggled: Settings.blur.shell = !Settings.blur.shell
            }
        }

        SettingRow {
            icon: "blur_circular"
            title: "Strength"
            subtitle: "How far the blur spreads, also used for windows"
            enabled: Settings.blur.shell
            opacity: enabled ? 1 : 0.5

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 1
                to: 20
                stepSize: 1
                value: Settings.blur.size
                onMoved: Settings.blur.size = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.blur.size
                from: 1
                to: 20
                suffix: " px"
                onEdited: value => Settings.blur.size = value
            }
        }

        SettingRow {
            icon: "layers"
            title: "Quality"
            subtitle: "More passes look smoother but cost more GPU"
            enabled: Settings.blur.shell
            opacity: enabled ? 1 : 0.5

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 1
                to: 6
                stepSize: 1
                value: Settings.blur.passes
                onMoved: Settings.blur.passes = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.blur.passes
                from: 1
                to: 6
                suffix: ""
                onEdited: value => Settings.blur.passes = value
            }
        }
    }
}
