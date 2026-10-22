import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Blur"

        SettingRow {
            icon: "blur_on"
            title: "Window blur"
            subtitle: "Blur what is behind see-through windows"
            clickable: true
            onClicked: Settings.windows.blurOn = !Settings.windows.blurOn

            Switch {
                checked: Settings.windows.blurOn
                onToggled: Settings.windows.blurOn = !Settings.windows.blurOn
            }
        }
    }

    SettingGroup {
        title: "Look"

        SettingRow {
            icon: "opacity"
            title: "Opacity"
            subtitle: "Lower makes windows see-through"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 50
                to: 100
                stepSize: 1
                value: Settings.windows.opacity
                onMoved: Settings.windows.opacity = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.windows.opacity
                from: 50
                to: 100
                suffix: "%"
                onEdited: value => Settings.windows.opacity = value
            }
        }

        SettingRow {
            icon: "rounded_corner"
            title: "Corner radius"
            subtitle: "How round the windows are"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 0
                to: 30
                stepSize: 1
                value: Settings.windows.rounding
                onMoved: Settings.windows.rounding = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.windows.rounding
                from: 0
                to: 30
                suffix: " px"
                onEdited: value => Settings.windows.rounding = value
            }
        }
    }

    SettingGroup {
        title: "Gaps"

        SettingRow {
            icon: "splitscreen"
            title: "Between windows"
            subtitle: "Space between tiled windows"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 0
                to: 20
                stepSize: 1
                value: Settings.windows.gapsIn
                onMoved: Settings.windows.gapsIn = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.windows.gapsIn
                from: 0
                to: 20
                suffix: " px"
                onEdited: value => Settings.windows.gapsIn = value
            }
        }

        SettingRow {
            icon: "fit_screen"
            title: "Around the screen"
            subtitle: "Space between windows and the screen edge"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 0
                to: 40
                stepSize: 1
                value: Settings.windows.gapsOut
                onMoved: Settings.windows.gapsOut = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.windows.gapsOut
                from: 0
                to: 40
                suffix: " px"
                onEdited: value => Settings.windows.gapsOut = value
            }
        }
    }
}
