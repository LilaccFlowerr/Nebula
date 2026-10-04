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
        visible: BluetoothStatus.enabled && connected.count > 0
        title: "Connected"

        Repeater {
            id: connected
            model: BluetoothStatus.paired.filter(d => d.connected)

            ColumnLayout {
                id: card
                required property var modelData

                Layout.fillWidth: true
                spacing: 0

                SettingRow {
                    icon: BluetoothStatus.iconFor(card.modelData)
                    title: card.modelData.name
                    subtitle: "Connected"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "check_circle"
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: Colors.primary
                    }
                }

                RowLayout {
                    visible: card.modelData.batteryAvailable
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.spacing.lg + Theme.spacing.xs
                    Layout.rightMargin: Theme.spacing.lg + Theme.spacing.xs
                    Layout.bottomMargin: Theme.spacing.md
                    spacing: Theme.spacing.md

                    Text {
                        text: card.modelData.battery > 0.5 ? "battery_full" : card.modelData.battery > 0.2 ? "battery_3_bar" : "battery_1_bar"
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: Colors.textOnSurfaceVariant
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 8
                        radius: height / 2
                        color: Colors.surfaceContainerHighest

                        Rectangle {
                            width: parent.width * card.modelData.battery
                            height: parent.height
                            radius: height / 2
                            color: card.modelData.battery > 0.2 ? Colors.primary : Colors.errorColor

                            Behavior on width {
                                NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                            }
                        }
                    }

                    Text {
                        text: Math.round(card.modelData.battery * 100) + "%"
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: Font.DemiBold
                        color: Colors.textOnSurface
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.spacing.lg + Theme.spacing.xs
                    Layout.rightMargin: Theme.spacing.lg
                    Layout.bottomMargin: Theme.spacing.md
                    spacing: Theme.spacing.sm

                    Item {
                        Layout.fillWidth: true
                    }

                    ActionButton {
                        icon: "delete"
                        text: "Remove"
                        danger: true
                        onClicked: card.modelData.forget()
                    }

                    ActionButton {
                        icon: "link_off"
                        text: "Disconnect"
                        filled: true
                        onClicked: card.modelData.disconnect()
                    }
                }
            }
        }
    }

    SettingGroup {
        visible: BluetoothStatus.enabled && others.count > 0
        title: "My devices"

        Repeater {
            id: others
            model: BluetoothStatus.paired.filter(d => !d.connected)

            SettingRow {
                id: device
                required property var modelData

                icon: BluetoothStatus.iconFor(modelData)
                title: modelData.name
                subtitle: modelData.state === BluetoothDeviceState.Connecting ? "Connecting" : "Click to connect"
                clickable: true
                onClicked: modelData.connect()

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
            subtitle: BluetoothStatus.scanning ? "Put your device in pairing mode" : "Headphones, speakers, that kind of stuff"
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
