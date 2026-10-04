import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: tab

    readonly property var profiles: PowerProfiles.hasPerformanceProfile
        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
        : [PowerProfile.PowerSaver, PowerProfile.Balanced]

    function duration(seconds) {
        const m = Math.round(seconds / 60);
        const h = Math.floor(m / 60);
        return h > 0 ? h + " h " + (m % 60) + " min" : m + " min";
    }

    spacing: Theme.spacing.xl

    Rectangle {
        visible: Battery.available
        Layout.fillWidth: true
        implicitHeight: Theme.settings.heroHeight * 0.6
        radius: Theme.radius.large
        color: Battery.low ? Colors.errorContainer : Colors.primaryContainer

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.lg

            Text {
                text: Battery.percent + "%"
                font.family: Theme.font.family
                font.pixelSize: Theme.settings.titleSize * 1.6
                font.weight: Font.Bold
                color: Battery.low ? Colors.textOnErrorContainer : Colors.textOnPrimaryContainer
            }

            ColumnLayout {
                spacing: 2

                Text {
                    text: Battery.full ? "Fully charged" : Battery.charging ? "Charging" : Battery.pluggedIn ? "Plugged in" : "On battery"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                    color: Battery.low ? Colors.textOnErrorContainer : Colors.textOnPrimaryContainer
                }

                Text {
                    visible: text !== ""
                    text: Battery.charging && Battery.timeToFull > 0 ? tab.duration(Battery.timeToFull) + " until full"
                        : !Battery.pluggedIn && Battery.timeToEmpty > 0 ? tab.duration(Battery.timeToEmpty) + " left" : ""
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Battery.low ? Colors.textOnErrorContainer : Colors.textOnPrimaryContainer
                    opacity: 0.8
                }
            }
        }
    }

    SettingGroup {
        title: "Power mode"

        SettingRow {
            icon: PowerProfiles.profile === PowerProfile.PowerSaver ? "energy_savings_leaf" : PowerProfiles.profile === PowerProfile.Performance ? "bolt" : "balance"
            title: "Profile"
            subtitle: PowerProfiles.profile === PowerProfile.PowerSaver ? "Longer battery, slower"
                    : PowerProfiles.profile === PowerProfile.Performance ? "Fastest, uses more power" : "A bit of both"

            SegmentedButton {
                width: Theme.settings.controlWidth + Theme.settings.fieldWidth
                options: tab.profiles.map(p => p === PowerProfile.PowerSaver ? "Saver" : p === PowerProfile.Balanced ? "Balanced" : "Fast")
                currentIndex: tab.profiles.indexOf(PowerProfiles.profile)
                onSelected: index => PowerProfiles.profile = tab.profiles[index]
            }
        }
    }

    SettingGroup {
        visible: Battery.available
        title: "Battery"

        SettingRow {
            icon: "battery_alert"
            title: "Low battery warning"
            subtitle: "The island warns you and the ring turns red"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 5
                to: 40
                stepSize: 1
                value: Settings.power.lowBattery
                onMoved: Settings.power.lowBattery = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.power.lowBattery
                from: 5
                to: 40
                suffix: "%"
                onEdited: value => Settings.power.lowBattery = value
            }
        }
    }
}
