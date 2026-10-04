import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: page

    property string arg: ""
    property bool showAll: false
    readonly property var options: arg ? Apps.candidates(arg) : []
    readonly property var others: showAll ? Apps.all.filter(e => !e.noDisplay && !options.includes(e)).sort((a, b) => a.name.localeCompare(b.name)) : []

    signal navigate(string target)

    spacing: Theme.spacing.xl

    SettingGroup {
        Text {
            visible: page.options.length === 0
            Layout.margins: Theme.spacing.lg
            text: "Nothing installed for this"
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: Colors.textOnSurfaceVariant
        }

        Repeater {
            model: page.options

            SettingRow {
                id: option
                required property var modelData
                readonly property bool active: Settings.apps[page.arg] === modelData.id

                title: modelData.name
                subtitle: modelData.genericName || modelData.comment
                clickable: true
                onClicked: {
                    Apps.choose(page.arg, modelData);
                    page.navigate("");
                }

                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: Theme.settings.iconSize * 1.4
                    source: Quickshell.iconPath(option.modelData.icon, true)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: option.active
                    text: "check_circle"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.primary
                }
            }
        }
    }

    SettingGroup {
        SettingRow {
            icon: "apps"
            title: "Show all apps"
            subtitle: "Also show apps that don't really fit"
            clickable: true
            onClicked: page.showAll = !page.showAll

            Switch {
                checked: page.showAll
                onToggled: page.showAll = !page.showAll
            }
        }

        Repeater {
            model: page.others

            SettingRow {
                id: option
                required property var modelData
                readonly property bool active: Settings.apps[page.arg] === modelData.id

                title: modelData.name
                subtitle: modelData.genericName || modelData.comment
                clickable: true
                onClicked: {
                    Apps.choose(page.arg, modelData);
                    page.navigate("");
                }

                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: Theme.settings.iconSize * 1.4
                    source: Quickshell.iconPath(option.modelData.icon, true)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: option.active
                    text: "check_circle"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.primary
                }
            }
        }
    }
}
