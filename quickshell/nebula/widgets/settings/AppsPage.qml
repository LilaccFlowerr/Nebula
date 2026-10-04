import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: page

    signal navigate(string target)

    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Default apps"

        Repeater {
            model: Apps.roles

            SettingRow {
                id: role
                required property var modelData
                readonly property var app: Apps.entry(modelData.key)

                icon: modelData.icon
                title: modelData.title
                subtitle: (app ? app.name : "Not set") + (modelData.shortcut ? " · " + modelData.shortcut : "")
                clickable: true
                onClicked: page.navigate("app:" + modelData.key)

                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: Theme.settings.iconSize * 1.4
                    source: role.app ? Quickshell.iconPath(role.app.icon, true) : ""
                    visible: source !== ""
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "chevron_right"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.textOnSurfaceVariant
                }
            }
        }
    }

    SettingGroup {
        title: "Launcher"

        SettingRow {
            icon: "history"
            title: "Recent apps"
            subtitle: "Forget what you opened lately"

            IconButton {
                icon: "delete_sweep"
                onClicked: Launcher.clearRecent()
            }
        }
    }
}
