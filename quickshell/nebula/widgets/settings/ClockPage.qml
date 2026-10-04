import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

ColumnLayout {
    spacing: Theme.spacing.xl

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: Theme.settings.heroHeight * 0.7
        radius: Theme.radius.large
        color: Colors.primaryContainer

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.spacing.xs

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Time.time
                font.family: Theme.font.family
                font.pixelSize: Theme.settings.titleSize * 2
                font.weight: Font.Bold
                color: Colors.textOnPrimaryContainer
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Time.date
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                color: Colors.textOnPrimaryContainer
                opacity: 0.75
            }
        }
    }

    SettingGroup {
        title: "Format"

        SettingRow {
            icon: "schedule"
            title: "24-hour clock"
            subtitle: Time.use24h ? "13:08" : "1:08 PM"
            clickable: true
            onClicked: Settings.clock.use24h = !Time.use24h

            Switch {
                checked: Time.use24h
                onToggled: Settings.clock.use24h = !Time.use24h
            }
        }
    }
}
