import QtQuick
import Quickshell
import Quickshell.Wayland
import M3Shapes
import qs.services
import qs.theme
import "../../components/Orbits.js" as Orbits

PanelWindow {
    id: window

    readonly property var apps: Notifications.missedApps.slice(0, Orbits.count)
    property real out: hover.hovered ? 1 : 0
    property real time: 0

    Behavior on out {
        NumberAnimation {
            duration: Theme.anim.medium * Theme.anim.scale
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }

    visible: apps.length > 0 && !GlobalStates.galaxyOpen
    anchors {
        right: true
        top: true
        bottom: true
    }
    implicitWidth: Theme.galaxy.peekSize
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region { item: area }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:galaxypeek"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    FrameAnimation {
        running: window.visible && window.out > 0
        onTriggered: window.time += frameTime
    }

    Item {
        id: area
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.galaxy.peekZone + Theme.galaxy.peekOut * window.out
        height: Theme.galaxy.peekSize

        HoverHandler {
            id: hover
        }

        TapHandler {
            onTapped: GlobalStates.toggleGalaxy(window.screen?.name ?? GlobalStates.focusedScreen())
        }

        Item {
            x: parent.width - Theme.galaxy.peekZone - Theme.galaxy.peekOut * window.out
            width: Theme.galaxy.peekSize
            height: Theme.galaxy.peekSize

            MaterialShape {
                anchors.fill: parent
                shape: MaterialShape.Cookie9Sided
                rotation: window.time * 8
                color: Colors.primaryContainer
            }

            Repeater {
                model: window.apps

                MaterialShape {
                    required property var modelData
                    required property int index
                    readonly property var at: Orbits.at(index, window.time, 0.13)

                    width: 8
                    height: 8
                    x: Theme.galaxy.peekSize / 2 + at.x - 4
                    y: Theme.galaxy.peekSize / 2 + at.y - 4
                    shape: Dock.shapeFor(modelData.name)
                    color: [Colors.primary, Colors.tertiary, Colors.secondary][index % 3]
                }
            }
        }
    }
}
