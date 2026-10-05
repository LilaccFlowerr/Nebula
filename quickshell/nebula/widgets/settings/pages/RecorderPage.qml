import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    readonly property var framerates: ["30", "60", "120"]

    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Capture"

        SettingRow {
            icon: Recorder.sound ? "mic" : "mic_off"
            title: "Record audio"
            subtitle: "Records what you hear too"
            clickable: true
            onClicked: Settings.recorder.sound = !Recorder.sound

            Switch {
                checked: Recorder.sound
                onToggled: Settings.recorder.sound = !Recorder.sound
            }
        }

        SettingRow {
            icon: "crop_free"
            title: "Start with a region"
            subtitle: "Pick an area before it starts"
            clickable: true
            onClicked: Settings.recorder.useRegion = !Recorder.useRegion

            Switch {
                checked: Recorder.useRegion
                onToggled: Settings.recorder.useRegion = !Recorder.useRegion
            }
        }

        SettingRow {
            icon: "speed"
            title: "Framerate"

            SegmentedButton {
                width: Theme.settings.controlWidth
                options: page.framerates
                currentIndex: page.framerates.indexOf(String(Recorder.framerate))
                onSelected: index => Settings.recorder.framerate = Number(page.framerates[index])
            }
        }
    }

    SettingGroup {
        title: "Files"

        SettingRow {
            icon: "folder"
            title: "Recordings folder"
            subtitle: Recorder.directory.replace(Quickshell.env("HOME"), "~")
        }
    }
}
