import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Dock"

        SettingRow {
            icon: "apps"
            title: "Running apps"
            subtitle: "Show open apps that aren't pinned"
            clickable: true
            onClicked: Settings.bar.dockRunning = !Settings.bar.dockRunning

            Switch {
                checked: Settings.bar.dockRunning
                onToggled: Settings.bar.dockRunning = !Settings.bar.dockRunning
            }
        }

        SettingRow {
            icon: "label"
            title: "App names"
            subtitle: "Show the name under an app on hover"
            clickable: true
            onClicked: Settings.bar.dockTooltips = !Settings.bar.dockTooltips

            Switch {
                checked: Settings.bar.dockTooltips
                onToggled: Settings.bar.dockTooltips = !Settings.bar.dockTooltips
            }
        }

        SettingRow {
            icon: "push_pin"
            title: "Pinned apps"
            subtitle: Dock.pinned.length === 0 ? "Right click an app in the dock to pin it" : Dock.pinned.length === 1 ? "1 app pinned" : Dock.pinned.length + " apps pinned"

            ActionButton {
                anchors.verticalCenter: parent.verticalCenter
                visible: Dock.pinned.length > 0
                icon: "delete"
                text: "Unpin all"
                onClicked: Settings.bar.dockPinned = "[]"
            }
        }
    }

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
