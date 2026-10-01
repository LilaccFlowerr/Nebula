import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property real angle: 0
    property var entry: null
    property bool selected: false
    property string shape: "circle"

    Behavior on angle {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: Theme.anim.island
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    readonly property bool empty: entry === null
    readonly property real radians: (angle - 90) * Math.PI / 180

    width: Theme.launcher.labelWidth
    height: Theme.launcher.itemSize + Theme.launcher.labelGap + label.height
    x: parent.width / 2 + Theme.launcher.ringRadius * Math.cos(radians) - width / 2
    y: parent.height / 2 + Theme.launcher.ringRadius * Math.sin(radians) - height / 2

    Rectangle {
        anchors.centerIn: shape
        width: Theme.launcher.selectionSize
        height: Theme.launcher.selectionSize
        radius: width / 2
        color: Qt.alpha(Colors.textOnPrimaryContainer, 0.25)
        visible: root.selected && !root.empty
    }

    ShapedImage {
        id: shape
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.launcher.itemSize
        height: Theme.launcher.itemSize
        shape: root.shape
        placeholderColor: Colors.surfaceContainerHigh
        opacity: root.empty ? 0.25 : 1
    }

    IconImage {
        anchors.centerIn: shape
        implicitSize: Theme.launcher.iconSize
        source: root.entry && !Launcher.commandMode ? Quickshell.iconPath(root.entry.icon, true) : ""
        visible: source !== ""
    }

    Text {
        anchors.centerIn: shape
        visible: Launcher.commandMode && !root.empty
        text: root.entry?.icon ?? ""
        color: Colors.textOnSurface
        font.family: Theme.font.icons
        font.pixelSize: Theme.launcher.iconSize
    }

    Text {
        id: label
        anchors.top: shape.bottom
        anchors.topMargin: Theme.launcher.labelGap
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        text: root.entry?.name ?? ""
        color: Colors.textOnPrimaryContainer
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
    }
}
