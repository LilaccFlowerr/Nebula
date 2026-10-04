import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    id: tab

    spacing: Theme.spacing.xl

    Component.onCompleted: Wifi.scanning = true
    Component.onDestruction: Wifi.scanning = false

    SettingGroup {
        SettingRow {
            icon: Wifi.icon
            title: "Wifi"
            subtitle: !Wifi.available ? "No wifi card found" : Wifi.connected ? "Connected to " + Wifi.ssid : Wifi.enabled ? "Not connected" : "Off"
            clickable: Wifi.available
            onClicked: Wifi.toggle()

            Switch {
                visible: Wifi.available
                checked: Wifi.enabled
                onToggled: Wifi.toggle()
            }
        }
    }

    SettingGroup {
        visible: Wifi.connected
        title: "Connected"

        SettingRow {
            icon: Wifi.strengthIcon(Wifi.network)
            title: Wifi.ssid
            subtitle: "Signal " + Math.round(Wifi.strength(Wifi.network) * 100) + "%"

            IconButton {
                icon: "link_off"
                onClicked: Wifi.disconnect()
            }
        }
    }

    SettingGroup {
        visible: Wifi.enabled && Wifi.available
        title: "Networks"

        RowLayout {
            visible: Wifi.networks.filter(n => !n.connected).length === 0
            Layout.fillWidth: true
            Layout.margins: Theme.spacing.lg
            spacing: Theme.spacing.md

            LoadingIndicator {
                implicitWidth: Theme.settings.iconSize * 1.5
                implicitHeight: implicitWidth
                contained: false
                running: parent.visible
            }

            Text {
                text: "Looking for networks"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                color: Colors.textOnSurfaceVariant
            }
        }

        Repeater {
            model: Wifi.networks.filter(n => !n.connected)

            SettingRow {
                id: entry
                required property var modelData

                icon: Wifi.strengthIcon(entry.modelData)
                title: entry.modelData.name
                subtitle: Wifi.pending === entry.modelData.name || entry.modelData.stateChanging ? "Connecting"
                        : entry.modelData.known ? "Saved"
                        : Wifi.secured(entry.modelData) ? "Secured" : "Open"
                clickable: true
                onClicked: {
                    if (Wifi.needsPassword(entry.modelData)) {
                        Wifi.error = "";
                        Wifi.prompt = entry.modelData;
                    } else {
                        Wifi.connect(entry.modelData);
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Wifi.secured(entry.modelData)
                    text: "lock"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize * 0.8
                    color: Colors.textOnSurfaceVariant
                }

                IconButton {
                    visible: entry.modelData.known
                    icon: "delete"
                    onClicked: Wifi.forget(entry.modelData)
                }
            }
        }
    }
}
