import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Media"

        SettingRow {
            icon: "graphic_eq"
            title: "Visualizer"
            subtitle: "The cava bar!"
            clickable: true
            onClicked: Settings.bar.visualizer = !Settings.bar.visualizer

            Switch {
                checked: Settings.bar.visualizer
                onToggled: Settings.bar.visualizer = !Settings.bar.visualizer
            }
        }

        SettingRow {
            icon: "lyrics"
            title: "Synced lyrics"
            subtitle: "In the sized media card  "
            clickable: true
            onClicked: Settings.bar.lyrics = !Settings.bar.lyrics

            Switch {
                checked: Settings.bar.lyrics
                onToggled: Settings.bar.lyrics = !Settings.bar.lyrics
            }
        }
    }

    SettingGroup {
        title: "Island"

        SettingRow {
            icon: "timer"
            title: "Volume and brightness popup"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 500
                to: 4000
                stepSize: 250
                value: Settings.bar.osdDuration
                onMoved: Settings.bar.osdDuration = Math.round(value / 250) * 250
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.bar.osdDuration
                from: 500
                to: 4000
                step: 250
                factor: 1000
                decimals: 2
                suffix: " s"
                onEdited: value => Settings.bar.osdDuration = value
            }
        }

        SettingRow {
            icon: "deployed_code"
            title: "Logo when idle"
            clickable: true
            onClicked: Settings.bar.osLogo = !Settings.bar.osLogo

            Switch {
                checked: Settings.bar.osLogo
                onToggled: Settings.bar.osLogo = !Settings.bar.osLogo
            }
        }
    }

    SettingGroup {
        title: "Popups"

        SettingRow {
            icon: "volume_up"
            title: "Volume"
            subtitle: "When the volume changes"
            clickable: true
            onClicked: Settings.bar.eventVolume = !Settings.bar.eventVolume

            Switch {
                checked: Settings.bar.eventVolume
                onToggled: Settings.bar.eventVolume = !Settings.bar.eventVolume
            }
        }

        SettingRow {
            visible: Brightness.available
            icon: "brightness_6"
            title: "Brightness"
            subtitle: "When the screen brightness changes"
            clickable: true
            onClicked: Settings.bar.eventBrightness = !Settings.bar.eventBrightness

            Switch {
                checked: Settings.bar.eventBrightness
                onToggled: Settings.bar.eventBrightness = !Settings.bar.eventBrightness
            }
        }

        SettingRow {
            visible: Battery.available
            icon: "power"
            title: "Charger"
            subtitle: "When you plug it in or out"
            clickable: true
            onClicked: Settings.bar.eventCharger = !Settings.bar.eventCharger

            Switch {
                checked: Settings.bar.eventCharger
                onToggled: Settings.bar.eventCharger = !Settings.bar.eventCharger
            }
        }

        SettingRow {
            visible: Battery.available
            icon: "battery_alert"
            title: "Low battery"
            subtitle: "When the battery runs low"
            clickable: true
            onClicked: Settings.bar.eventLowBattery = !Settings.bar.eventLowBattery

            Switch {
                checked: Settings.bar.eventLowBattery
                onToggled: Settings.bar.eventLowBattery = !Settings.bar.eventLowBattery
            }
        }
    }
}
