import QtQuick
import qs.services
import qs.theme

Rectangle {
    id: root

    // Which workspace this button is
    property int wsId: 1

    // Its state, straight from the Workspaces service
    readonly property bool active: Workspaces.activeId === root.wsId
    readonly property bool occupied: Workspaces.isOccupied(root.wsId)
    readonly property bool urgent: Workspaces.isUrgent(root.wsId)

    // Active = wide pill, the rest = circle
    implicitWidth: active ? Theme.workspaces.activeWidth : Theme.button.size
    implicitHeight: Theme.button.size
    radius: Theme.radius.full

    color: urgent   ? Colors.errorColor
         : active   ? Colors.primary
         : occupied ? Colors.surfaceContainerLow
         :            Colors.surfaceContainer

    // Grow into a pill / shrink back into a dot
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    // Fade between colors (ColorAnimation instead of NumberAnimation, because it's a color)
    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.standard
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.wsId
        font.family: Theme.font.family
        font.pixelSize: Theme.font.normal
        color: root.active ? Colors.textOnPrimary : Colors.textOnSurface
        opacity: root.active || root.occupied ? 1 : 0.4
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Workspaces.focus(root.wsId)
    }
}