import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.theme

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
        mask: drag.active ? fullMask : widgetMask

        property Region widgetMask: Region { item: widget }
        property Region fullMask: Region {
            width: window.width
            height: window.height
        }

        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell:nowplaying"

        readonly property real maxX: width - widget.width
        readonly property real maxY: height - widget.height

        NowPlaying {
            id: widget
            x: Settings.nowPlaying.x < 0 ? Theme.nowPlaying.margin : Math.min(Settings.nowPlaying.x, window.maxX)
            y: Settings.nowPlaying.y < 0 ? window.maxY - Theme.nowPlaying.margin : Math.min(Settings.nowPlaying.y, window.maxY)

            DragHandler {
                id: drag
                target: widget
                cursorShape: Qt.ClosedHandCursor
                xAxis.minimum: 0
                xAxis.maximum: window.maxX
                yAxis.minimum: 0
                yAxis.maximum: window.maxY
                onActiveChanged: {
                    if (active) return;
                    Settings.nowPlaying.x = widget.x;
                    Settings.nowPlaying.y = widget.y;
                }
            }
        }
    }
}
