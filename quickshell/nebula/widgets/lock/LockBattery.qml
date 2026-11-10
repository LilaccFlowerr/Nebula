import QtQuick
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.alpha(Colors.secondaryContainer, Theme.lock.surfaceTint)
    }

    BatteryRing {
        anchors.fill: parent
        anchors.margins: 6
        level: Battery.level
        low: Battery.low
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Battery.charging
            text: "bolt"
            font.family: Theme.font.icons
            font.pixelSize: root.width * 0.2
            color: Colors.textOnSecondaryContainer
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Battery.percent + "%"
            font.family: Theme.font.family
            font.pixelSize: root.width * 0.22
            font.weight: Font.Medium
            color: Colors.textOnSecondaryContainer
        }
    }
}
