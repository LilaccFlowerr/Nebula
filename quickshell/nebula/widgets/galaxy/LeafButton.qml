import QtQuick
import qs.theme

Rectangle {
    id: button

    property string icon
    property string text
    property bool primary: false
    readonly property bool pressed: buttonMouse.pressed
    readonly property color fg: primary ? Colors.textOnPrimary : Colors.textOnSurfaceVariant

    signal clicked()

    implicitWidth: icon !== "" ? height : label.implicitWidth + Theme.spacing.lg * 2
    implicitHeight: 34
    radius: pressed ? height / 4 : height / 2
    color: primary ? (buttonMouse.containsMouse ? Qt.lighter(Colors.primary, 1.08) : Colors.primary)
        : buttonMouse.containsMouse ? Qt.lighter(Colors.surfaceContainerHighest, 1.15) : Colors.surfaceContainerHighest

    Behavior on radius {
        NumberAnimation {
            duration: Theme.anim.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        width: button.icon !== "" ? implicitWidth : Math.min(implicitWidth, button.width - Theme.spacing.lg * 2)
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        text: button.icon !== "" ? button.icon : button.text
        color: button.fg
        font.family: button.icon !== "" ? Theme.font.icons : Theme.font.family
        font.pixelSize: button.icon !== "" ? 19 : Theme.font.small + 1
        font.weight: button.icon !== "" ? 400 : 700
        font.variableAxes: button.icon !== "" ? ({ "FILL": 1, "wght": 600 }) : ({})
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
