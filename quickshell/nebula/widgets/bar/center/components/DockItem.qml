import QtQuick
import Quickshell
import Quickshell.Widgets
import M3Shapes
import qs.services
import qs.theme

Item {
    id: root

    required property string key
    required property bool leaving
    required property int index
    property ListModel listModel

    readonly property var app: Dock.app(key)
    readonly property int windowCount: app?.windows.length ?? 0
    readonly property bool running: windowCount > 0
    readonly property bool active: app?.active ?? false
    readonly property bool launching: Dock.isLaunching(key)
    readonly property bool menuOpen: GlobalStates.dockMenu === key
    readonly property bool hovered: mouse.containsMouse
    readonly property string screenName: QsWindow.window?.screen?.name ?? ""
    readonly property int ownShape: Dock.shapeFor(key)

    property real shown: 0
    property real breath: 0

    implicitWidth: Theme.dock.itemSize * shown
    implicitHeight: Theme.dock.itemSize
    opacity: Math.min(1, shown)

    Component.onCompleted: popIn.start()

    onLeavingChanged: {
        if (leaving) {
            popIn.stop();
            popOut.start();
        } else if (shown < 1) {
            popOut.stop();
            popIn.start();
        }
    }

    onHoveredChanged: {
        if (!hovered) {
            hoverOpen.stop();
        } else if (running && GlobalStates.dockMenu !== "" && GlobalStates.isOn(screenName)) {
            GlobalStates.dockMenu = key;
        } else if (running) {
            hoverOpen.restart();
        }
    }

    Timer {
        id: hoverOpen
        interval: Theme.dock.previewDelay
        onTriggered: if (root.hovered && GlobalStates.dockMenu === "") GlobalStates.toggleDockMenu(root.key, root.screenName)
    }

    NumberAnimation {
        id: popIn
        target: root
        property: "shown"
        to: 1
        duration: Theme.anim.medium
        easing.type: Easing.OutBack
        easing.overshoot: Theme.anim.overshoot
    }

    NumberAnimation {
        id: popOut
        target: root
        property: "shown"
        to: 0
        duration: Theme.anim.medium
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.emphasizedAccel
        onFinished: if (root.leaving && root.listModel) root.listModel.remove(root.index)
    }

    SequentialAnimation {
        running: root.launching
        loops: Animation.Infinite
        onStopped: root.breath = 0

        NumberAnimation { target: root; property: "breath"; to: 1; duration: Theme.dock.breathDuration; easing.type: Easing.InOutSine }
        NumberAnimation { target: root; property: "breath"; to: 0; duration: Theme.dock.breathDuration; easing.type: Easing.InOutSine }
    }

    Item {
        anchors.centerIn: parent
        width: Theme.dock.itemSize
        height: Theme.dock.itemSize
        scale: (0.5 + 0.5 * Math.min(1, root.shown)) * (mouse.pressed ? 0.9 : 1)

        MaterialShape {
            anchors.fill: parent
            implicitSize: parent.width
            scale: 1 - Theme.dock.breathDepth * root.breath
            opacity: 1 - 0.4 * root.breath
            shape: root.launching || root.active || root.hovered || root.menuOpen ? root.ownShape : MaterialShape.Circle
            color: root.launching ? Colors.tertiaryContainer
                 : root.menuOpen ? Colors.secondaryContainer
                 : root.active ? Colors.primaryContainer
                 : root.hovered ? Colors.surfaceContainerHighest
                 : "transparent"
            animationDuration: Theme.anim.medium
            animationEasing.type: Easing.BezierSpline
            animationEasing.bezierCurve: Theme.anim.emphasizedDecel

            Behavior on color {
                ColorAnimation { duration: Theme.anim.fast }
            }
        }

        IconImage {
            anchors.centerIn: parent
            implicitSize: Theme.dock.iconSize
            source: root.app?.icon ?? ""
            visible: source !== ""
        }

        Text {
            anchors.centerIn: parent
            visible: !(root.app?.icon)
            text: "apps"
            font.family: Theme.font.icons
            font.pixelSize: Theme.dock.iconSize
            color: root.active ? Colors.textOnPrimaryContainer : Colors.textOnSurfaceVariant
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 1
            spacing: Theme.dock.dotGap

            Repeater {
                model: Theme.dock.maxDots

                Rectangle {
                    required property int index

                    readonly property bool on: index < root.windowCount

                    width: on ? (root.active && root.windowCount === 1 ? Theme.dock.dotActiveWidth : Theme.dock.dotSize) : 0
                    height: Theme.dock.dotSize
                    radius: height / 2
                    color: root.active ? Colors.primary : Colors.textOnSurfaceVariant
                    opacity: on ? 1 : 0
                    visible: width > 0

                    Behavior on width {
                        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: Theme.anim.fast }
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: !root.leaving
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => {
            hoverOpen.stop();
            if (event.button === Qt.RightButton) {
                GlobalStates.toggleDockMenu(root.key, root.screenName);
                return;
            }
            GlobalStates.dockMenu = "";
            if (event.button === Qt.MiddleButton) Dock.launch(root.key);
            else Dock.activate(root.key);
        }
    }
}
