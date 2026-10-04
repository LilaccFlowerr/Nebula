import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Now playing"

        SettingRow {
            icon: "album"
            title: "Now playing widget"
            subtitle: "The spinning cookie"
            clickable: true
            onClicked: Settings.nowPlaying.enabled = !Settings.nowPlaying.enabled

            Switch {
                checked: Settings.nowPlaying.enabled
                onToggled: Settings.nowPlaying.enabled = !Settings.nowPlaying.enabled
            }
        }

        SettingRow {
            icon: "autorenew"
            title: "Spin while playing"
            subtitle: "Turns slowly while music plays"
            clickable: true
            onClicked: Settings.nowPlaying.spin = !Settings.nowPlaying.spin

            Switch {
                checked: Settings.nowPlaying.spin
                onToggled: Settings.nowPlaying.spin = !Settings.nowPlaying.spin
            }
        }

        SettingRow {
            icon: "open_with"
            title: "Position"
            subtitle: Settings.nowPlaying.x < 0 ? "Bottom left" : "Somewhere you dragged it"

            IconButton {
                icon: "restart_alt"
                visible: Settings.nowPlaying.x >= 0 || Settings.nowPlaying.y >= 0
                onClicked: {
                    Settings.nowPlaying.x = -1;
                    Settings.nowPlaying.y = -1;
                }
            }
        }
    }
}
