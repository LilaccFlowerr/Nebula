import QtQuick
import qs.components
import qs.services
import qs.theme

Island {
    roundLeft: true
    implicitWidth: 336

    Rectangle {
        id: clockPill

        implicitWidth: clockText.implicitWidth + Theme.spacing.md * 2
        implicitHeight: Theme.button.size
        radius: Theme.radius.full
        color: Colors.surfaceContainer

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.padding

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
    IconButton {
        icon: "settings"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.bar.padding
        onClicked: console.info("gear clicked!")
    }
}
