import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    property var sections: []

    signal navigate(string target)

    spacing: Theme.spacing.xl

    SettingGroup {
        Repeater {
            model: page.sections

            SettingRow {
                required property var modelData

                icon: modelData.icon
                title: modelData.title
                subtitle: modelData.subtitle
                clickable: true
                onClicked: page.navigate("section:" + modelData.key)

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
}
