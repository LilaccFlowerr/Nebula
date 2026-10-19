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
        SettingRow {
            icon: "music_note"
            title: "Now playing"
            subtitle: "Album art and controls"
            clickable: true
            visible: Widgets.first("nowplaying") === null
            onClicked: page.navigate("widget:" + Widgets.add("nowplaying", { x: -1, y: -1 }))
        }

        SettingRow {
            icon: "image"
            title: "Image"
            subtitle: "Any picture, in a shape"
            clickable: true
            onClicked: {
                Widgets.replacing = "";
                page.navigate("images");
            }
        }

        SettingRow {
            icon: "sticky_note_2"
            title: "Text"
            subtitle: "A note on your desktop"
            clickable: true
            onClicked: page.navigate("widget:" + Widgets.add("text"))
        }
    }
}
