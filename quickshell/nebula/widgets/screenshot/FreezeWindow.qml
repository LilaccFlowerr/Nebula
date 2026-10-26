import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: window

        required property ShellScreen modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        mask: Region {}

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:freeze"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Loader {
            anchors.fill: parent
            active: Screenshot.freezing

            sourceComponent: ScreencopyView {
                captureSource: window.modelData
                live: false
                paintCursor: false
                visible: hasContent
                onHasContentChanged: if (hasContent) Screenshot.markFrozen()
            }
        }
    }
}
