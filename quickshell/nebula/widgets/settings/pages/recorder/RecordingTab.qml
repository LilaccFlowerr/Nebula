import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    readonly property var framerates: ["Auto", "30", "60", "120"]

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
            subtitle: Recorder.framerate === 0 ? "Matches the screen you record" : ""

            SegmentedButton {
                width: Theme.settings.controlWidth
                options: page.framerates
                currentIndex: Recorder.framerate === 0 ? 0 : page.framerates.indexOf(String(Recorder.framerate))
                onSelected: index => Settings.recorder.framerate = index === 0 ? 0 : Number(page.framerates[index])
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
