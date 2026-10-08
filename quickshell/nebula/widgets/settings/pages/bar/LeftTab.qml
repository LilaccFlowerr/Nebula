import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Workspaces"

        SettingRow {
            icon: "view_week"
            title: "Workspaces per group"
            subtitle: "Dots before a new group starts"

            Slider {
                width: Theme.settings.controlWidth - Theme.settings.fieldWidth - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                from: 3
                to: 10
                stepSize: 1
                value: Settings.bar.workspaces
                onMoved: Settings.bar.workspaces = Math.round(value)
            }

            NumberField {
                anchors.verticalCenter: parent.verticalCenter
                value: Settings.bar.workspaces
                from: 3
                to: 10
                step: 1
                factor: 1
                decimals: 0
                suffix: ""
                onEdited: value => Settings.bar.workspaces = value
            }
        }

        SettingRow {
            icon: "category"
            title: "Style"
            subtitle: "What each workspace looks like"

            SegmentedButton {
                readonly property var styles: ["numbers", "pills", "shapes"]

                width: Theme.settings.controlWidth
                anchors.verticalCenter: parent.verticalCenter
                options: ["Numbers", "Pills", "Shapes"]
                currentIndex: Math.max(0, styles.indexOf(Settings.bar.workspaceStyle))
                onSelected: index => Settings.bar.workspaceStyle = styles[index]
            }
        }
    }
}
