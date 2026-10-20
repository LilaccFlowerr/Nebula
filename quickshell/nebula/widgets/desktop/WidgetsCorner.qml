import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

PanelWindow {
    id: window

    anchors {
        bottom: true
        left: true
    }
    implicitWidth: Theme.recorder.windowSize
    implicitHeight: Theme.recorder.windowSize
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:widgetcorner"

    mask: Region { item: hitArea }

    property bool open: false
    property bool adding: false
    onOpenChanged: if (!open) adding = false
    readonly property color fill: Qt.alpha(Colors.surface, Theme.bar.opacity)
    readonly property int rowHeight: 44

    function addType(entry) {
        if (entry.picker) {
            openSettings("images");
            return;
        }
        const props = { screen: window.screen.name };
        if (entry.key === "nowplaying") Object.assign(props, { x: -1, y: -1 });
        Widgets.add(entry.key, props);
        adding = false;
    }

    function openSettings(tab) {
        window.open = false;
        GlobalStates.openSettings("desktop", tab);
    }

    Timer {
        id: closeTimer
        interval: Theme.recorder.closeDelay
        onTriggered: window.open = false
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop();
                window.open = true;
            } else {
                closeTimer.restart();
            }
        }
    }

    readonly property real targetWidth: open ? Theme.recorder.openWidth : Theme.recorder.hotWidth - Theme.recorder.flare * 2
    readonly property real targetHeight: open ? content.implicitHeight + Theme.spacing.lg * 2 : 0

    Item {
        id: hitArea
        anchors.left: blob.left
        anchors.leftMargin: -Theme.recorder.flare
        anchors.bottom: parent.bottom
        width: Math.max(Theme.recorder.hotWidth, window.targetWidth + Theme.recorder.flare * 2)
        height: Math.max(Theme.recorder.hotHeight, window.targetHeight)
    }

    Rectangle {
        id: blob
        anchors.left: parent.left
        anchors.leftMargin: Theme.recorder.margin
        anchors.bottom: parent.bottom
        width: window.targetWidth
        height: window.targetHeight
        topLeftRadius: Theme.radius.large
        topRightRadius: Theme.radius.large
        color: window.fill
        clip: true

        Behavior on width {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }
        Behavior on height {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        ColumnLayout {
            id: content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.lg
            visible: window.open
            spacing: Theme.spacing.md

            RowLayout {
                Layout.fillWidth: true

                IconButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    visible: window.adding
                    icon: "arrow_back"
                    onClicked: window.adding = false
                }

                Text {
                    Layout.fillWidth: true
                    text: window.adding ? "Add widget" : "Widgets"
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                }

                IconButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    visible: !window.adding
                    icon: "settings"
                    onClicked: window.openSettings("")
                }
            }

            Flickable {
                Layout.fillWidth: true
                visible: !window.adding
                implicitHeight: Math.min(contentHeight, window.rowHeight * 5)
                contentHeight: list.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: list
                    width: parent.width

                    Repeater {
                        model: Widgets.idModel

                        Item {
                            id: entry

                            required property string modelData
                            readonly property var cfg: Widgets.get(modelData) ?? ({})
                            readonly property bool on: cfg.enabled === true

                            width: list.width
                            height: window.rowHeight

                            HoverHandler {
                                id: rowHover
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.radius.medium
                                color: rowHover.hovered ? Qt.alpha(Colors.textOnSurface, 0.06) : "transparent"
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: window.openSettings("widget:" + entry.modelData)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacing.sm
                                anchors.rightMargin: Theme.spacing.sm
                                spacing: Theme.spacing.md

                                MaterialShape {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    shape: MaterialShape[entry.cfg.shape ?? "Circle"] ?? MaterialShape.Circle
                                    color: Widgets.palette(entry.cfg.color).fill
                                    opacity: entry.on ? 1 : 0.4
                                    animationDuration: Theme.anim.medium
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: Widgets.label(entry.cfg)
                                    elide: Text.ElideRight
                                    color: entry.on ? Colors.textOnSurface : Colors.textOnSurfaceVariant
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.normal
                                }

                                IconButton {
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    icon: "delete"
                                    opacity: rowHover.hovered ? 1 : 0
                                    enabled: rowHover.hovered
                                    onClicked: Widgets.remove(entry.modelData)

                                    Behavior on opacity {
                                        NumberAnimation { duration: Theme.anim.fast }
                                    }
                                }

                                Switch {
                                    checked: entry.on
                                    onToggled: Widgets.update(entry.modelData, { enabled: !entry.on })
                                }
                            }
                        }
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                visible: window.adding

                Repeater {
                    model: window.adding ? Widgets.available() : []

                    Item {
                        id: option

                        required property var modelData

                        width: parent.width
                        height: window.rowHeight + Theme.spacing.md

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radius.medium
                            color: optionMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.06) : "transparent"
                        }

                        MouseArea {
                            id: optionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.addType(option.modelData)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacing.sm
                            anchors.rightMargin: Theme.spacing.sm
                            spacing: Theme.spacing.md

                            MaterialShape {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                shape: MaterialShape[option.modelData.shape] ?? MaterialShape.Circle
                                color: Widgets.palette(option.modelData.color).fill

                                Text {
                                    anchors.centerIn: parent
                                    text: option.modelData.icon
                                    font.family: Theme.font.icons
                                    font.pixelSize: 20
                                    color: Widgets.palette(option.modelData.color).text
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: option.modelData.title
                                    elide: Text.ElideRight
                                    color: Colors.textOnSurface
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.normal
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: option.modelData.description
                                    elide: Text.ElideRight
                                    color: Colors.textOnSurfaceVariant
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.small
                                }
                            }
                        }
                    }
                }
            }

            ActionButton {
                Layout.alignment: Qt.AlignHCenter
                visible: !window.adding
                icon: "add"
                text: "Add widget"
                filled: true
                onClicked: window.adding = true
            }
        }
    }

    Shape {
        anchors.left: blob.right
        anchors.bottom: parent.bottom
        width: Theme.recorder.flare
        height: Theme.recorder.flare
        visible: blob.height > Theme.recorder.flare
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillColor: window.fill
            startX: Theme.recorder.flare; startY: Theme.recorder.flare
            PathArc { x: 0; y: 0; radiusX: Theme.recorder.flare; radiusY: Theme.recorder.flare; direction: PathArc.Clockwise }
            PathLine { x: 0; y: Theme.recorder.flare }
        }
    }
}
