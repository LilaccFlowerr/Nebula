import QtQuick
import qs.services
import qs.theme

Rectangle {
    id: root

    property int wsId: 1

    readonly property bool active: Workspaces.activeId === root.wsId
    readonly property bool occupied: Workspaces.isOccupied(root.wsId)
    readonly property bool urgent: Workspaces.isUrgent(root.wsId)

    implicitWidth: active ? Theme.workspaces.activeWidth : Theme.button.size
    implicitHeight: Theme.button.size
    radius: Theme.radius.full

    color: urgent   ? Colors.errorColor
         : active   ? Colors.primary
         : occupied ? Colors.surfaceContainerLow
         :            Colors.surfaceContainer

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.anim.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

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
