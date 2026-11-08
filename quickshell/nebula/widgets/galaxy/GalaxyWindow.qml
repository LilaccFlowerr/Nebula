import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

PanelWindow {
    id: window

    readonly property bool open: GlobalStates.galaxyOpen
    property real progress: 0
    property real time: 0

    onOpenChanged: {
        if (open) {
            card.reset();
            card.slots = {};
            card.now = Date.now();
            card.burstIn();
            closeAnim.stop();
            openAnim.restart();
        } else {
            openAnim.stop();
            closeAnim.restart();
        }
    }

    NumberAnimation {
        id: openAnim
        target: window
        property: "progress"
        to: 1
        duration: Theme.galaxy.openDuration * Theme.anim.scale
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.emphasizedDecel
    }

    NumberAnimation {
        id: closeAnim
        target: window
        property: "progress"
        to: 0
        duration: Theme.galaxy.closeDuration * Theme.anim.scale
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.emphasizedAccel
    }

    visible: open || progress > 0
    screen: Quickshell.screens.find(s => s.name === GlobalStates.screen) ?? Quickshell.screens[0]
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:galaxy"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    FrameAnimation {
        running: window.visible
        onTriggered: window.time += frameTime
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.surface, Theme.galaxy.backdrop * window.progress)

        MouseArea {
            anchors.fill: parent
            onClicked: if (!card.back()) GlobalStates.galaxyOpen = false
        }
    }

    Starfield {
        anchors.fill: parent
        shown: window.progress
    }

    GalaxyCard {
        id: card
        anchors.centerIn: parent
        open: window.progress
        time: window.time
        opacity: window.progress
        scale: 0.94 + 0.06 * window.progress
        focus: true
        onCloseRequested: GlobalStates.galaxyOpen = false

        Keys.onEscapePressed: if (!card.back()) GlobalStates.galaxyOpen = false
    }
}
