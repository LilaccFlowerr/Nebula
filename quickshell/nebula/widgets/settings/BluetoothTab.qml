import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    spacing: Theme.spacing.xl

    Component.onDestruction: BluetoothStatus.scan(false)

    SettingGroup {
        SettingRow {
            icon: BluetoothStatus.icon
            title: "Bluetooth"
            subtitle: !BluetoothStatus.available ? "No bluetooth adapter found" : BluetoothStatus.connected ? "Connected to " + BluetoothStatus.deviceName : BluetoothStatus.enabled ? "On" : "Off"
            clickable: BluetoothStatus.available
            onClicked: BluetoothStatus.toggle()

            Switch {
                visible: BluetoothStatus.available
                checked: BluetoothStatus.enabled
                onToggled: BluetoothStatus.toggle()
            }
        }
    }

    SettingGroup {
        visible: BluetoothStatus.enabled && BluetoothStatus.paired.length > 0
        title: "My devices"

        Repeater {
            model: BluetoothStatus.paired

            SettingRow {
                id: device
                required property var modelData

                icon: BluetoothStatus.iconFor(modelData)
                title: modelData.name
                subtitle: modelData.state === BluetoothDeviceState.Connecting ? "Connecting"
                        : modelData.connected ? "Connected" + (modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "%" : "")
                        : "Not connected"
                clickable: true
                onClicked: BluetoothStatus.activate(modelData)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: device.modelData.connected
                    text: "check_circle"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.primary
                }

                IconButton {
                    icon: "delete"
                    onClicked: device.modelData.forget()
                }
            }
        }
    }

    SettingGroup {
        visible: BluetoothStatus.enabled
        title: "Add a device"

        SettingRow {
            icon: "bluetooth_searching"
            title: "Search for devices"
            subtitle: BluetoothStatus.scanning ? "Put your device in pairing mode" : "Find new headphones, speakers and more"
            clickable: true
            onClicked: BluetoothStatus.scan(!BluetoothStatus.scanning)

            LoadingIndicator {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: Theme.settings.iconSize * 1.5
                implicitHeight: implicitWidth
                contained: false
                running: BluetoothStatus.scanning
            }

            Switch {
                anchors.verticalCenter: parent.verticalCenter
                checked: BluetoothStatus.scanning
                onToggled: BluetoothStatus.scan(!BluetoothStatus.scanning)
            }
        }

        Repeater {
            model: BluetoothStatus.scanning ? BluetoothStatus.nearby : []

            SettingRow {
                required property var modelData

                icon: BluetoothStatus.iconFor(modelData)
                title: modelData.name
                subtitle: modelData.pairing ? "Pairing" : "Click to pair"
                clickable: !modelData.pairing
                onClicked: BluetoothStatus.pair(modelData)
            }
        }
    }
}
