import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    property string query: ""
    readonly property var options: {
        const q = query.trim().toLowerCase();
        return Apps.all.filter(e => !e.noDisplay && (q === "" || [e.name, e.genericName, e.id].some(t => (t ?? "").toLowerCase().includes(q))))
            .sort((a, b) => a.name.localeCompare(b.name));
    }

    signal navigate(string target)

    spacing: Theme.spacing.xl

    Component.onCompleted: search.focusInput()

    TextField {
        id: search
        Layout.fillWidth: true
        placeholder: "Search"
        onTyped: text => page.query = text
    }

    SettingGroup {
        Text {
            visible: page.options.length === 0
            Layout.margins: Theme.spacing.lg
            text: "Nothing called that"
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: Colors.textOnSurfaceVariant
        }

        Repeater {
            model: page.options

            SettingRow {
                id: option
                required property var modelData
                readonly property string appId: HyprConfig.appIdFor(modelData)
                readonly property bool added: HyprConfig.appModes[appId] !== undefined

                image: Quickshell.iconPath(modelData.icon, true)
                icon: "apps"
                title: modelData.name
                subtitle: modelData.genericName || modelData.comment
                clickable: true
                onClicked: {
                    if (!option.added) HyprConfig.setAppMode(option.appId, "solid");
                    page.navigate("");
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: option.added
                    text: "check_circle"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.primary
                }
            }
        }
    }
}
