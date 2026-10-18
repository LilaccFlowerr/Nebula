import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import M3Shapes
import qs.services
import qs.theme
import qs.widgets.desktop.nowplaying

Item {
    id: card

    property int ws: 1
    property var monitor: null
    property bool selected: false
    property bool live: false
    property bool interactive: false
    property bool decorated: false
    property Item barSource: null
    property int captureToken: 0
    property real radius: Theme.radius.large
    property int emptyShape: MaterialShape.Cookie9Sided
    readonly property bool hovered: hover.hovered
    readonly property var windows: Hyprland.toplevels.values.filter(t => t.workspace?.id === card.ws)
    readonly property real screenWidth: (monitor?.width ?? 1920) / (monitor?.scale ?? 1)
    readonly property real screenHeight: (monitor?.height ?? 1080) / (monitor?.scale ?? 1)
    readonly property real k: width / screenWidth

    signal clicked()
    signal windowClicked(var toplevel)
    signal windowDragged(var toplevel, point scenePos)
    signal windowDropped(var toplevel, point scenePos)

    HoverHandler {
        id: hover
    }

    ClippingRectangle {
        id: frame
        anchors.fill: parent
        radius: card.radius
        color: Colors.surfaceContainer

        Image {
            anchors.fill: parent
            source: Wallpaper.url(Settings.wallpaper.path)
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(card.screenWidth / 2, card.screenWidth * 9 / 32)
            asynchronous: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: card.clicked()
        }

        MaterialShape {
            visible: card.windows.length === 0
            anchors.centerIn: parent
            width: parent.height * Theme.overview.emptyShapeRatio
            height: width
            shape: card.emptyShape
            color: Qt.alpha(Colors.surfaceContainerHigh, Theme.overview.emptyShapeOpacity)

            Text {
                anchors.centerIn: parent
                text: card.ws
                font.family: Theme.font.family
                font.pixelSize: parent.width * 0.32
                font.weight: Font.Medium
                color: Colors.textOnSurfaceVariant
            }
        }

        Loader {
            active: card.decorated && Settings.nowPlaying.enabled

            sourceComponent: Item {
                width: card.screenWidth
                height: card.screenHeight
                scale: card.k
                transformOrigin: Item.TopLeft
                enabled: false

                NowPlaying {
                    x: Settings.nowPlaying.x < 0 ? Theme.nowPlaying.margin : Math.min(Settings.nowPlaying.x, parent.width - width)
                    y: Settings.nowPlaying.y < 0 ? parent.height - height - Theme.nowPlaying.margin : Math.min(Settings.nowPlaying.y, parent.height - height)
                }
            }
        }

        Repeater {
            model: card.windows

            ClippingRectangle {
                id: win

                required property var modelData
                readonly property var at: modelData.lastIpcObject.at ?? [0, 0]
                readonly property var size: modelData.lastIpcObject.size ?? [card.screenWidth, card.screenWidth * 9 / 16]

                x: (at[0] - (modelData.monitor?.x ?? 0)) * card.k
                y: (at[1] - (modelData.monitor?.y ?? 0)) * card.k
                width: size[0] * card.k
                height: size[1] * card.k
                radius: Math.max(2, Theme.radius.medium * card.k)
                color: Colors.surfaceContainerHigh
                opacity: drag.dragging ? Theme.overview.draggedOpacity : 1

                ScreencopyView {
                    id: view
                    anchors.fill: parent
                    captureSource: win.modelData.wayland
                    live: card.live

                    Connections {
                        target: card
                        function onCaptureTokenChanged() { view.captureFrame(); }
                    }
                }

                IconImage {
                    visible: !view.hasContent
                    anchors.centerIn: parent
                    implicitSize: Math.min(win.width, win.height) * 0.3
                    source: Quickshell.iconPath(DesktopEntries.heuristicLookup(win.modelData.lastIpcObject.class ?? "")?.icon ?? "", true)
                }

                MouseArea {
                    id: drag

                    property point start
                    property bool dragging: false

                    anchors.fill: parent
                    enabled: card.interactive
                    cursorShape: dragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onPressed: mouse => {
                        start = Qt.point(mouse.x, mouse.y);
                        dragging = false;
                    }
                    onPositionChanged: mouse => {
                        if (!dragging && Math.hypot(mouse.x - start.x, mouse.y - start.y) > Theme.overview.dragThreshold) dragging = true;
                        if (dragging) card.windowDragged(win.modelData, mapToItem(null, mouse.x, mouse.y));
                    }
                    onReleased: mouse => {
                        if (dragging) card.windowDropped(win.modelData, mapToItem(null, mouse.x, mouse.y));
                        dragging = false;
                    }
                    onClicked: if (!dragging) card.windowClicked(win.modelData)
                }
            }
        }

        ShaderEffectSource {
            visible: card.barSource !== null
            width: card.width
            height: Theme.bar.height * card.k
            sourceItem: card.barSource
            live: true
            smooth: true
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: card.radius
        color: "transparent"
        border.width: card.selected ? Theme.overview.selectedBorder : card.hovered ? Theme.overview.hoverBorder : 0
        border.color: card.selected ? Colors.primary : Colors.outline
    }
}
