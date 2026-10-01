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
    property string shape: "circle"
    property int delay: 0
    property bool rushing: false

    Behavior on angle {
        SequentialAnimation {
            PauseAnimation { duration: root.delay }
            RotationAnimation {
                direction: RotationAnimation.Shortest
                duration: root.rushing ? Theme.anim.medium : Theme.anim.island
                easing.type: root.rushing ? Easing.OutCubic : Easing.OutBack
                easing.overshoot: Theme.anim.overshoot
            }
        }
    }

    property var shownEntry: null
    Component.onCompleted: shownEntry = entry
    onEntryChanged: swap.restart()

    SequentialAnimation {
        id: swap
        NumberAnimation { target: root; property: "scale"; to: 0; duration: Theme.anim.fast; easing.type: Easing.InCubic }
        ScriptAction { script: root.shownEntry = root.entry }
        NumberAnimation { target: root; property: "scale"; to: 1; duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }

    readonly property bool empty: shownEntry === null
    readonly property bool isCommand: shownEntry?.run !== undefined
    readonly property real radians: (angle - 90) * Math.PI / 180

    width: Theme.launcher.labelWidth
    height: Theme.launcher.itemSize + Theme.launcher.labelGap + label.height
    x: parent.width / 2 + Theme.launcher.ringRadius * Math.cos(radians) - width / 2
    y: parent.height / 2 + Theme.launcher.ringRadius * Math.sin(radians) - height / 2

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
        source: root.shownEntry && !root.isCommand ? Quickshell.iconPath(root.shownEntry.icon, true) : ""
        visible: source !== ""
    }

    Text {
        anchors.centerIn: shape
        visible: root.isCommand
        text: root.shownEntry?.icon ?? ""
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
        text: root.shownEntry?.name ?? ""
        color: Colors.textOnPrimaryContainer
        font.family: Theme.font.family
        font.pixelSize: Theme.font.small
    }
}
