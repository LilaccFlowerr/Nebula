import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.services
import qs.theme

PanelWindow {
    id: window

    anchors {
        bottom: true
        right: true
    }
    implicitWidth: Theme.recorder.windowSize
    implicitHeight: Theme.recorder.windowSize
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:recorder"

    mask: Region { item: hitArea }

    property bool open: false
    onOpenChanged: if (open) Recorder.refreshRecent()
    property bool showSaved: false
    readonly property bool showTab: Recorder.recording || showSaved
    readonly property string mode: Recorder.recording ? "recording" : showSaved ? "saved" : "idle"
    readonly property color fill: Qt.alpha(Colors.surface, Theme.bar.opacity)

    Connections {
        target: Recorder
        function onSaved() {
            window.showSaved = true;
            savedTimer.restart();
        }
        function onRecordingChanged() {
            if (Recorder.recording) window.showSaved = false;
        }
    }

    Timer {
        id: savedTimer
        interval: Theme.recorder.savedDuration
        running: window.showSaved && !hover.hovered
        onTriggered: window.showSaved = false
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

    readonly property real targetWidth: open ? Theme.recorder.openWidth
        : showTab ? tabContent.implicitWidth + Theme.spacing.lg * 2
        : Theme.recorder.hotWidth - Theme.recorder.flare * 2
    readonly property real targetHeight: open ? openContent.implicitHeight + Theme.spacing.lg * 2
        : showTab ? Theme.recorder.tabHeight
        : 0

    Item {
        id: hitArea
        anchors.right: blob.right
        anchors.rightMargin: -Theme.recorder.flare
        anchors.bottom: parent.bottom
        width: Math.max(Theme.recorder.hotWidth, window.targetWidth + Theme.recorder.flare * 2)
        height: Math.max(Theme.recorder.hotHeight, window.targetHeight)
    }

    Rectangle {
        id: blob
        anchors.right: parent.right
        anchors.rightMargin: Theme.recorder.margin
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

        Shape {
            x: -Theme.recorder.flare
            anchors.bottom: parent.bottom
            width: Theme.recorder.flare
            height: Theme.recorder.flare
            visible: blob.height > Theme.recorder.flare
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: -1
                fillColor: window.fill
                startX: 0; startY: Theme.recorder.flare
                PathArc { x: Theme.recorder.flare; y: 0; radiusX: Theme.recorder.flare; radiusY: Theme.recorder.flare }
                PathLine { x: Theme.recorder.flare; y: Theme.recorder.flare }
            }
        }

        RowLayout {
            id: tabContent
            anchors.centerIn: parent
            visible: !window.open && window.showTab
            spacing: Theme.spacing.sm

            Rectangle {
                visible: window.mode === "recording"
                implicitWidth: 10
                implicitHeight: 10
                radius: 5
                color: Colors.errorColor

                SequentialAnimation on opacity {
                    running: Recorder.recording && !Recorder.paused
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.3; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.3; to: 1; duration: 700; easing.type: Easing.InOutSine }
                }
            }

            Text {
                text: window.mode === "recording" ? Recorder.elapsedText : "Saved"
                color: Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                font.features: { "tnum": 1 }
            }
        }

        ColumnLayout {
            id: openContent
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.lg
            visible: window.open
            spacing: Theme.spacing.md

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: window.mode === "recording" ? (Recorder.paused ? "Paused" : "Recording")
                        : window.mode === "saved" ? "Recording saved"
                        : "Screen recording"
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                }

                IconButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    icon: "folder_open"
                    onClicked: Recorder.openFolder()
                }
            }

            SegmentedButton {
                Layout.fillWidth: true
                visible: window.mode !== "recording"
                options: ["Screen", "Region"]
                currentIndex: Recorder.useRegion ? 1 : 0
                onSelected: index => Settings.recorder.useRegion = index === 1
            }

            RowLayout {
                Layout.fillWidth: true
                visible: window.mode !== "recording"
                spacing: Theme.spacing.sm

                Text {
                    text: Recorder.sound ? "volume_up" : "volume_off"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.button.iconSize
                    color: Colors.textOnSurfaceVariant
                }

                Text {
                    Layout.fillWidth: true
                    text: "System audio"
                    color: Colors.textOnSurface
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                }

                Switch {
                    checked: Recorder.sound
                    onToggled: Settings.recorder.sound = !Recorder.sound
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: window.mode === "recording"
                text: Recorder.elapsedText
                color: Recorder.paused ? Colors.textOnSurfaceVariant : Colors.textOnSurface
                font.family: Theme.font.family
                font.pixelSize: Theme.recorder.timerSize
                font.weight: Font.DemiBold
                font.features: { "tnum": 1 }
            }

            Item {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.xs
                implicitHeight: Theme.recorder.buttonSize

                MorphButton {
                    id: recordButton
                    anchors.centerIn: parent
                    implicitWidth: Theme.recorder.buttonSize
                    implicitHeight: Theme.recorder.buttonSize
                    morph: Recorder.recording ? 1 : 0
                    color: Recorder.recording ? Colors.errorColor : Colors.primary
                    onClicked: {
                        if (!Recorder.recording && Recorder.useRegion) window.open = false;
                        Recorder.record();
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        property real size: Recorder.recording ? 18 : 22
                        width: size
                        height: size
                        radius: Recorder.recording ? 4 : size / 2
                        rotation: -recordButton.rotation
                        color: Recorder.recording ? Colors.textOnError : Colors.textOnPrimary

                        Behavior on size {
                            NumberAnimation { duration: Theme.anim.medium }
                        }
                        Behavior on radius {
                            NumberAnimation { duration: Theme.anim.medium }
                        }
                    }
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: recordButton.left
                    anchors.rightMargin: Theme.spacing.lg
                    visible: window.mode === "recording"
                    icon: Recorder.paused ? "play_arrow" : "pause"
                    onClicked: Recorder.togglePause()
                }
            }

            Text {
                Layout.topMargin: Theme.spacing.xs
                visible: recentList.visible
                text: "Recent"
                color: Colors.textOnSurfaceVariant
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
                font.weight: Font.DemiBold
            }

            ColumnLayout {
                id: recentList
                Layout.fillWidth: true
                visible: window.mode !== "recording" && Recorder.recent.length > 0
                spacing: Theme.spacing.xs

                Repeater {
                    model: Recorder.recent

                    Rectangle {
                        id: item
                        required property var modelData
                        required property int index
                        readonly property bool isNew: window.showSaved && modelData.path === Recorder.lastFile

                        Layout.fillWidth: true
                        implicitHeight: Theme.recorder.rowHeight
                        radius: Theme.radius.medium
                        color: itemHover.hovered ? Colors.surfaceContainerHigh : isNew ? Qt.alpha(Colors.primaryContainer, 0.5) : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: Theme.anim.fast }
                        }

                        HoverHandler {
                            id: itemHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Recorder.openFile(item.modelData.path)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.spacing.sm
                            spacing: Theme.spacing.md

                            Text {
                                text: "play_circle"
                                font.family: Theme.font.icons
                                font.pixelSize: Theme.button.iconSize
                                color: item.isNew ? Colors.primary : Colors.textOnSurfaceVariant
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Text {
                                    Layout.fillWidth: true
                                    text: item.modelData.date
                                    elide: Text.ElideRight
                                    color: Colors.textOnSurface
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.small
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    visible: item.isNew
                                    text: "New"
                                    color: Colors.primary
                                    font.family: Theme.font.family
                                    font.pixelSize: Theme.font.small
                                }
                            }

                            Text {
                                visible: !itemHover.hovered
                                text: item.modelData.duration
                                color: Colors.textOnSurfaceVariant
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.small
                                font.features: { "tnum": 1 }
                            }

                            Row {
                                visible: itemHover.hovered
                                spacing: 0

                                IconButton {
                                    implicitWidth: 28
                                    implicitHeight: 28
                                    color: "transparent"
                                    icon: "folder_open"
                                    onClicked: Recorder.openFolder()
                                }

                                IconButton {
                                    implicitWidth: 28
                                    implicitHeight: 28
                                    color: "transparent"
                                    icon: "delete"
                                    onClicked: Recorder.deleteFile(item.modelData.path)
                                }
                            }
                        }
                    }
                }
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
            startX: 0; startY: 0
            PathArc { x: Theme.recorder.flare; y: Theme.recorder.flare; radiusX: Theme.recorder.flare; radiusY: Theme.recorder.flare }
            PathLine { x: 0; y: Theme.recorder.flare }
        }
    }
}
