import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: page

    spacing: Theme.spacing.xl

    function seconds(ms) {
        return (ms / 1000).toFixed(1).replace(".0", "") + " s";
    }

    SettingGroup {
        title: "Behavior"

        SettingRow {
            icon: Dnd.icon
            title: "Do not disturb"
            subtitle: Dnd.enabled ? "Notifications are kept quiet" : "Notifications pop up in the island"
            clickable: true
            onClicked: Dnd.toggle()

            Switch {
                checked: Dnd.enabled
                onToggled: Dnd.toggle()
            }
        }
    }

    SettingGroup {
        title: "Timing"

        SettingRow {
            icon: "timer"
            title: "Popup duration"
            subtitle: page.seconds(Notifications.normalTimeout)

            Slider {
                width: Theme.settings.controlWidth
                from: 1000
                to: 10000
                stepSize: 500
                value: Notifications.normalTimeout
                onMoved: Settings.notifications.normalTimeout = value
            }
        }

        SettingRow {
            icon: "priority_high"
            title: "Urgent popup duration"
            subtitle: page.seconds(Notifications.urgentTimeout)

            Slider {
                width: Theme.settings.controlWidth
                from: 1000
                to: 15000
                stepSize: 500
                value: Notifications.urgentTimeout
                onMoved: Settings.notifications.urgentTimeout = value
            }
        }
    }
}
