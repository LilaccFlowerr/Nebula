import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "After a screenshot"

        SettingRow {
            icon: "content_paste"
            title: "Copy to clipboard"
            subtitle: "Paste it right away"
            clickable: true
            onClicked: Settings.screenshot.copy = !Screenshot.copy

            Switch {
                checked: Screenshot.copy
                onToggled: Settings.screenshot.copy = !Screenshot.copy
            }
        }

        SettingRow {
            icon: "notifications"
            title: "Show a notification"
            subtitle: "With a preview of the screenshot"
            clickable: true
            onClicked: Settings.screenshot.notify = !Screenshot.notify

            Switch {
                checked: Screenshot.notify
                onToggled: Settings.screenshot.notify = !Screenshot.notify
            }
        }
    }

    SettingGroup {
        title: "Files"

        SettingRow {
            icon: "folder"
            title: "Screenshots folder"
            subtitle: Screenshot.directory.replace(Quickshell.env("HOME"), "~")

            ActionButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "open_in_new"
                text: "Open"
                onClicked: Screenshot.openFolder()
            }
        }
    }
}
