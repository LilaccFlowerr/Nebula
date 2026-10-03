import QtQuick
import QtQuick.Controls as Controls
import qs.theme

Controls.Slider {
    id: root

    property real trackHeight: 10
    property real handleWidth: 4
    property real handleGap: 4

    from: 0
    to: 1
    padding: 0
    implicitWidth: 160
    implicitHeight: 24

    property real shownPosition: visualPosition

    Behavior on shownPosition {
        enabled: !root.pressed
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasizedDecel
        }
    }

    readonly property real handleX: shownPosition * (availableWidth - handleWidth)

    background: Item {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: root.availableWidth
        height: root.trackHeight

        Rectangle {
            width: Math.max(0, root.handleX - root.handleGap)
            height: parent.height
            radius: Math.min(width, height) / 2
            color: Colors.primary
            visible: width > 0
        }

        Rectangle {
            id: inactive
            x: root.handleX + root.handleWidth + root.handleGap
            width: Math.max(0, parent.width - x)
            height: parent.height
            radius: Math.min(width, height) / 2
            color: Colors.secondaryContainer
            visible: width > 0
        }

        Rectangle {
            width: 4
            height: 4
            radius: 2
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width - width - (root.trackHeight - height) / 2
            color: Colors.primary
            visible: x - inactive.x >= (root.trackHeight - height) / 2
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.handleX
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: root.handleWidth
        implicitHeight: root.implicitHeight
        radius: width / 2
        color: Colors.primary
    }
}
