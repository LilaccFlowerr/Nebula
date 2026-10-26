import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: tab

    spacing: Theme.spacing.xl

    SettingGroup {
        title: "Priority"

        SettingRow {
            icon: "bluetooth_audio"
            title: "Bluetooth first"
            subtitle: "Headphones become the output as soon as they connect"
            clickable: true
            onClicked: ___ // TODO: flip Settings.sound.bluetoothFirst

            Switch {
                checked: ___ // TODO: follow Settings.sound.bluetoothFirst
                onToggled: ___ // TODO: same flip as the row click
            }
        }
    }

    SettingGroup {
        title: "Output"

        Repeater {
            model: Audio.outputs

            // TODO: one SettingRow per output (modelData is a PwNode).
            //  - icon: bluetooth_audio for Bluetooth (Audio.isBluetooth), else speaker / monitor
            //  - title: Audio.label(modelData)
            //  - the active one (modelData === Audio.sink) shows a check icon on the right
            //  - clickable: click calls Audio.setOutput(modelData)
        }
    }
}
