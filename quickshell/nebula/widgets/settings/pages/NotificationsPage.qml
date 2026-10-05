import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    spacing: Theme.spacing.xl

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
            subtitle: "How long they show"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 1000
                to: 10000
                stepSize: 500
                value: Notifications.normalTimeout
                onMoved: Settings.notifications.normalTimeout = value
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Notifications.normalTimeout
                from: 1000
                to: 10000
                step: 500
                factor: 1000
                decimals: 1
                suffix: " s"
                onEdited: value => Settings.notifications.normalTimeout = value
            }
        }

        SettingRow {
            icon: "priority_high"
            title: "Urgent popup duration"
            subtitle: "How long the important notifications show"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 1000
                to: 15000
                stepSize: 500
                value: Notifications.urgentTimeout
                onMoved: Settings.notifications.urgentTimeout = value
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Notifications.urgentTimeout
                from: 1000
                to: 15000
                step: 500
                factor: 1000
                decimals: 1
                suffix: " s"
                onEdited: value => Settings.notifications.urgentTimeout = value
            }
        }
    }
}
