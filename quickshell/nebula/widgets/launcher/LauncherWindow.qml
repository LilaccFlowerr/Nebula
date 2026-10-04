import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme
import "../../components/Curves.js" as Curves

PanelWindow {
    id: window

    readonly property bool open: GlobalStates.launcherOpen
    property real progress: 0
    readonly property real pillT: Curves.phase(progress, 0.45, 0.45)

    NumberAnimation {
        id: openAnim
        target: window
        property: "progress"
        to: 1
        duration: Theme.anim.slow + Theme.anim.medium
        easing.type: Easing.Linear
    }

    NumberAnimation {
        id: closeAnim
        target: window
        property: "progress"
        to: 0
        duration: Theme.anim.slow
        easing.type: Easing.Linear
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
    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property int selected: 0
    readonly property var results: Launcher.results
    onResultsChanged: selected = Launcher.wallpaperMode ? Math.max(0, results.findIndex(w => w.path === Wallpaper.current))
        : Launcher.themeMode ? Math.max(0, results.findIndex(s => s.scheme === Scheme.current)) : 0

    Connections {
        target: Launcher
        function onClearRequested() { input.text = ""; }
    }

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

    onOpenChanged: {
        if (open) {
            input.text = "";
            selected = 0;
            input.forceActiveFocus();
            closeAnim.stop();
            openAnim.restart();
        } else {
            openAnim.stop();
            closeAnim.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.scrim, Theme.launcher.dim * window.progress)

        MouseArea {
            anchors.fill: parent
            onClicked: Launcher.close()
        }
    }

    LauncherRing {
        id: ring
        anchors.centerIn: parent
        intro: window.progress
        selected: window.selected
        rushing: window.rushing
    }

    Rectangle {
        id: pill
        anchors.centerIn: parent
        anchors.verticalCenterOffset: ring.shownWall * Theme.launcher.wallpaperPillOffset
        width: Theme.launcher.searchHeight + (Theme.launcher.searchWidth - Theme.launcher.searchHeight) * Math.max(0, Curves.back(window.pillT, Theme.anim.overshoot))
        height: Theme.launcher.searchHeight
        scale: Math.min(1, window.pillT * 4)
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
            opacity: Math.max(0, window.pillT * 3 - 2)
            color: text === ">" ? "transparent" : Colors.textOnSurface
            selectionColor: Colors.primary
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            onTextChanged: Launcher.query = text

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) Launcher.close();
                else if (event.key === Qt.Key_Backspace && input.text === "" && Launcher.picker !== "") Launcher.picker = "";
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
            text: Launcher.wallpaperMode ? "Wallpapers" : Launcher.themeMode ? "Themes" : input.text === ">" ? "> Commands" : "Search"
            color: Colors.textOnSurfaceVariant
            opacity: 0.6 * input.opacity
            font: input.font
        }
    }
}
