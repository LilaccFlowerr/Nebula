import QtQuick
import qs.components
import qs.services
import qs.theme

Island {
    roundLeft: true
    implicitWidth: 336

    Text {
        text: Time.time

        color: Colors.textOnSurface
        font.family: Theme.font.family
        font.pixelSize: Theme.font.clock

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.bar.padding
    }
}