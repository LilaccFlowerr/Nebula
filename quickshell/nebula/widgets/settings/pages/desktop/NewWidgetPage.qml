import QtQuick
import QtQuick.Layouts
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    signal navigate(string target)

    spacing: Theme.spacing.xl

    SettingGroup {
        Repeater {
            model: Widgets.available()

            SettingRow {
                id: option

                required property var modelData

                icon: modelData.icon
                title: modelData.title
                subtitle: modelData.description
                clickable: true
                onClicked: {
                    if (modelData.picker) {
                        Widgets.replacing = "";
                        page.navigate("images");
                        return;
                    }
                    const props = modelData.key === "nowplaying" ? { x: -1, y: -1 } : {};
                    page.navigate("widget:" + Widgets.add(modelData.key, props));
                }
            }
        }
    }
}
