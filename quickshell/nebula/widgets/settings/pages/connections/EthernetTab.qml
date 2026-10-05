import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    spacing: Theme.spacing.xl

    Component.onCompleted: Ethernet.refresh()

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: Theme.settings.heroHeight * 0.6
        radius: Theme.radius.large
        color: Ethernet.connected ? Colors.primaryContainer : Colors.surfaceContainerHigh

        Behavior on color {
            ColorAnimation { duration: Theme.anim.medium }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.lg

            Text {
                text: Ethernet.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.settings.titleSize * 1.6
                color: Ethernet.connected ? Colors.textOnPrimaryContainer : Colors.textOnSurfaceVariant
            }

            ColumnLayout {
                spacing: 2

                Text {
                    text: Ethernet.available ? Ethernet.status : "No ethernet port"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.settings.titleSize * 0.8
                    font.weight: Font.Bold
                    color: Ethernet.connected ? Colors.textOnPrimaryContainer : Colors.textOnSurface
                }

                Text {
                    visible: text !== ""
                    text: Ethernet.connected ? Ethernet.connection + (Ethernet.speed ? " · " + Ethernet.speed : "") : ""
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Ethernet.connected ? Colors.textOnPrimaryContainer : Colors.textOnSurfaceVariant
                    opacity: 0.8
                }
            }
        }
    }

    SettingGroup {
        visible: Ethernet.available

        SettingRow {
            icon: "cable"
            title: "Use ethernet"
            subtitle: Ethernet.unplugged ? "Plug in a cable first" : "Connect or disconnect " + Ethernet.device
            clickable: !Ethernet.unplugged
            onClicked: Ethernet.connected ? Ethernet.disconnect() : Ethernet.connect()

            Switch {
                visible: !Ethernet.unplugged
                checked: Ethernet.connected
                onToggled: Ethernet.connected ? Ethernet.disconnect() : Ethernet.connect()
            }
        }
    }

    SettingGroup {
        visible: Ethernet.available
        title: "Details"

        SettingRow {
            icon: "settings_ethernet"
            title: "Interface"
            subtitle: Ethernet.device
        }

        SettingRow {
            visible: Ethernet.ip !== ""
            icon: "lan"
            title: "IP address"
            subtitle: Ethernet.ip
        }

        SettingRow {
            icon: "fingerprint"
            title: "MAC address"
            subtitle: Ethernet.address
        }
    }
}
