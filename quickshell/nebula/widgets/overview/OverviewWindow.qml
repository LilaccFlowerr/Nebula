import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.theme

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: window

        required property ShellScreen modelData
        readonly property bool open: GlobalStates.overviewOpen
        readonly property bool focusedHere: Hyprland.focusedMonitor?.name === modelData?.name
        property bool main: false

        onFocusedHereChanged: if (open) main = focusedHere
        onMainChanged: if (main && open) overview.forceActiveFocus()
        property bool ready: false
        property real shown: open && ready ? 1 : 0

        Behavior on shown {
            NumberAnimation {
                duration: Math.round(Theme.overview.duration * Theme.anim.scale)
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.standard
            }
        }

        screen: modelData
        visible: open || shown > 0
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:overview"
        WlrLayershell.keyboardFocus: main ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        onOpenChanged: {
            if (!open) return;
            ready = false;
            main = focusedHere;
            startDelay.restart();
            if (main) overview.forceActiveFocus();
        }

        Timer {
            id: startDelay
            interval: Theme.overview.startDelay
            onTriggered: window.ready = true
        }

        Item {
            anchors.fill: parent

            Image {
                id: wallpaper
                anchors.fill: parent
                source: Wallpaper.url(Settings.wallpaper.path)
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(width / 2, height / 2)
                visible: false
            }

            MultiEffect {
                anchors.fill: wallpaper
                opacity: window.ready || window.shown > 0 ? 1 : 0
                source: wallpaper
                blurEnabled: true
                blur: 1
                blurMax: Theme.overview.wallpaperBlur
                autoPaddingEnabled: false
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.alpha(Colors.scrim, window.ready || window.shown > 0 ? Theme.overview.dim : 0)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: GlobalStates.overviewOpen = false
            }

            Overview {
                id: overview
                anchors.fill: parent
                screenName: window.modelData?.name ?? ""
                open: window.open
                main: window.main
                ready: window.ready
                shown: window.shown
            }
        }
    }
}
