import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

PanelWindow {
    id: window

    visible: GlobalStates.launcherOpen
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
    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property int selected: 0
    readonly property var results: Launcher.results
    onResultsChanged: selected = 0

    property bool rushing: false

    function step(delta, repeat) {
        rushing = repeat;
        if (repeat) rushTimer.restart();
        if (results.length > 0)
            selected = (selected + delta + results.length) % results.length;
    }

    Timer {
        id: rushTimer
        interval: Theme.anim.medium
        onTriggered: window.rushing = false
    }

    onVisibleChanged: if (visible) {
        input.text = "";
        selected = 0;
        input.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.scrim, Theme.launcher.dim)

        MouseArea {
            anchors.fill: parent
            onClicked: Launcher.close()
        }
    }

    LauncherRing {
        anchors.centerIn: parent
        selected: window.selected
        rushing: window.rushing
    }

    Rectangle {
        id: pill
        anchors.centerIn: parent
        width: Theme.launcher.searchWidth
        height: Theme.launcher.searchHeight
        radius: Theme.radius.full
        color: Colors.surfaceContainer

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.lg
            anchors.rightMargin: Theme.spacing.lg
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            clip: true
            color: text === ">" ? "transparent" : Colors.textOnSurface
            selectionColor: Colors.primary
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            onTextChanged: Launcher.query = text

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) Launcher.close();
                else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) window.step(-1, event.isAutoRepeat);
                else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down || event.key === Qt.Key_Tab) window.step(1, event.isAutoRepeat);
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) Launcher.activate(window.results[window.selected]);
                else return;
                event.accepted = true;
            }
        }

        Text {
            anchors.centerIn: parent
            visible: input.text === "" || input.text === ">"
            text: input.text === ">" ? "> Commands" : "Search"
            color: Colors.textOnSurfaceVariant
            opacity: 0.6
            font: input.font
        }
    }
}
