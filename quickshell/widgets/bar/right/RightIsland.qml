import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import qs.theme

Island {
    roundLeft: true
    implicitWidth: row.implicitWidth + Theme.bar.padding * 2

    Connections {
        target: Battery
        function onPluggedInChanged() { ring.ripple(Battery.pluggedIn ? 1500 : 0); }
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.padding
        spacing: Theme.bar.gap


        Rectangle {
            id: clockPill

            implicitWidth: clockText.implicitWidth + Theme.spacing.md * 2
            implicitHeight: Theme.button.size
            radius: Theme.radius.full
            color: Colors.surfaceContainer

            Text {
                id: clockText
                anchors.centerIn: parent

                font.weight: Font.DemiBold
                text: Time.time
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.clock
            }
        }

        IconButton { icon: "keyboard_arrow_up";   onClicked: console.info("tray") }
        IconButton { icon: "settings";            onClicked: console.info("quick settings") }
        Item {
            implicitWidth: Theme.batteryRing.size
            implicitHeight: Theme.batteryRing.size

            BatteryRing {
                id: ring
                anchors.fill: parent
                visible: Battery.available
                level: Battery.level               
                low: Battery.low                 
            }

            IconButton {
                anchors.centerIn: parent
                icon: "power_settings_new"
                onClicked: console.info("power")
            }
        }
    }
}
