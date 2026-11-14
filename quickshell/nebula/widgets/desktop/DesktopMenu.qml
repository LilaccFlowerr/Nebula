import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

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
    mask: window.open ? cardMask : emptyMask

    property Region cardMask: Region { item: card }
    property Region emptyMask: Region {}

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:desktopmenu"
    WlrLayershell.keyboardFocus: window.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    readonly property bool open: Widgets.deskOpen && Widgets.deskScreen === modelData.name
    readonly property real gap: Theme.spacing.md
    readonly property var titles: ({ add: "Add widget", layouts: "Layouts" })
    property string page: "main"
    property string renaming: ""

    onOpenChanged: if (open) {
        page = Widgets.deskPage;
        renaming = "";
    }

    function addType(entry) {
        Widgets.closeDesk();
        if (entry.picker) {
            Widgets.openPicker("", modelData.name);
            return;
        }
        Widgets.add(entry.key, { screen: modelData.name });
    }

    function toggleEdit() {
        const x = card.targetX;
        const y = card.targetY;
        if (Widgets.editing) {
            Widgets.stopEdit();
            return;
        }
        WidgetSnap.focus(x, y);
        Widgets.startEdit(modelData.name);
    }

    function saveNew() {
        const name = Widgets.freeName();
        Widgets.savePreset(name);
        renaming = name;
    }

    function rename(name) {
        Widgets.renamePreset(renaming, name);
        renaming = Widgets.presetNamed(name) ? "" : renaming;
    }

    function settings(page) {
        Widgets.closeDesk();
        GlobalStates.openSettings(page);
    }

    HyprlandFocusGrab {
        windows: [window]
        active: window.open
        onCleared: Widgets.closeDesk()
    }

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            if (window.open) Widgets.closeDesk();
        }

        function onFocusedMonitorChanged() {
            if (window.open) Widgets.closeDesk();
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: window.open
        onActivated: {
            if (window.renaming !== "") window.renaming = "";
            else Widgets.closeDesk();
        }
    }

    Rectangle {
        id: card

        readonly property real targetX: Widgets.deskX - window.modelData.x
        readonly property real targetY: Widgets.deskY - window.modelData.y

        width: Theme.deskMenu.width
        height: column.implicitHeight + Theme.spacing.md * 2
        x: Math.max(window.gap, Math.min(targetX - Widgets.deskAlignX * width, window.modelData.width - width - window.gap))
        y: Math.max(window.gap, Math.min(targetY - Widgets.deskAlignY * height, window.modelData.height - height - window.gap))
        radius: Theme.radius.large
        color: Qt.alpha(Colors.surfaceContainer, 0.97)
        border.width: 1
        border.color: Colors.outlineVariant
        clip: true
        opacity: window.open ? 1 : 0
        scale: window.open ? 1 : 0.92
        transformOrigin: Item.TopLeft

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }

        Behavior on scale {
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
        }

        Behavior on height {
            enabled: window.open
            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
        }

        ColumnLayout {
            id: column

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.md
            spacing: Theme.settings.rowGap

            RowLayout {
                visible: window.page !== "main"
                Layout.fillWidth: true
                Layout.bottomMargin: Theme.spacing.xs
                spacing: Theme.spacing.sm

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: Theme.spacing.xs
                    text: window.titles[window.page] ?? ""
                    elide: Text.ElideRight
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.large
                    font.weight: Font.DemiBold
                    color: Colors.textOnSurface
                }
            }

            ColumnLayout {
                visible: window.page === "main"
                Layout.fillWidth: true
                spacing: Theme.settings.rowGap

                MenuRow {
                    icon: Widgets.editing ? "check" : "edit"
                    text: Widgets.editing ? "Done editing" : "Edit widgets"
                    accent: true
                    onClicked: window.toggleEdit()
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: Theme.spacing.sm

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacing.lg * 2
                        height: 1
                        color: Colors.outlineVariant
                    }
                }

                MenuRow {
                    icon: "wallpaper"
                    text: "Change wallpaper"
                    onClicked: window.settings("appearance")
                }

                MenuRow {
                    icon: "settings"
                    text: "Settings"
                    onClicked: window.settings("desktop")
                }
            }

            GridLayout {
                visible: window.page === "add"
                Layout.fillWidth: true
                columns: 2
                columnSpacing: Theme.settings.rowGap
                rowSpacing: Theme.settings.rowGap

                Repeater {
                    model: window.page === "add" ? Widgets.available() : []

                    Rectangle {
                        id: tile

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        implicitHeight: Theme.deskMenu.tileHeight
                        radius: Theme.radius.medium
                        color: tileMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh

                        MaterialShape {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: Theme.spacing.md
                            implicitSize: Theme.deskMenu.tileShape
                            shape: MaterialShape[tile.modelData.shape] ?? MaterialShape.Circle
                            color: Colors.primaryContainer

                            Text {
                                anchors.centerIn: parent
                                text: tile.modelData.icon
                                font.family: Theme.font.icons
                                font.pixelSize: Theme.settings.iconSize
                                color: Colors.textOnPrimaryContainer
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.spacing.sm
                            text: tile.modelData.title
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            color: Colors.textOnSurface
                        }

                        MouseArea {
                            id: tileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: window.addType(tile.modelData)
                        }
                    }
                }
            }

            ColumnLayout {
                visible: window.page === "layouts"
                Layout.fillWidth: true
                spacing: Theme.settings.rowGap

                Repeater {
                    model: window.page === "layouts" ? Widgets.presets : []

                    ColumnLayout {
                        id: layout

                        required property var modelData
                        readonly property bool current: Widgets.activePreset === modelData.name
                        readonly property bool editing: window.renaming === modelData.name

                        Layout.fillWidth: true
                        spacing: Theme.settings.rowGap

                        MenuRow {
                            visible: !layout.editing
                            icon: "dashboard"
                            text: layout.modelData.name + (layout.current && Widgets.modified ? " •" : "")
                            trailing: layout.current ? "check" : ""
                            onClicked: {
                                Widgets.closeDesk();
                                Widgets.loadPreset(layout.modelData.name);
                            }
                            onRightClicked: window.renaming = layout.modelData.name
                        }

                        RowLayout {
                            visible: layout.editing
                            Layout.fillWidth: true
                            spacing: Theme.spacing.xs

                            TextField {
                                Layout.fillWidth: true
                                text: layout.modelData.name
                                placeholder: "Layout name"
                                onEdited: name => window.rename(name)
                            }

                            IconButton {
                                implicitWidth: 36
                                implicitHeight: 36
                                icon: "sync"
                                onClicked: {
                                    Widgets.updatePreset(layout.modelData.name);
                                    window.renaming = "";
                                }
                            }

                            IconButton {
                                implicitWidth: 36
                                implicitHeight: 36
                                icon: "delete"
                                onClicked: {
                                    window.renaming = "";
                                    Widgets.deletePreset(layout.modelData.name);
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: Widgets.presets.length === 0
                    Layout.fillWidth: true
                    Layout.margins: Theme.spacing.sm
                    text: "No layouts yet"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Colors.textOnSurfaceVariant
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: Theme.spacing.sm

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacing.lg * 2
                        height: 1
                        color: Colors.outlineVariant
                    }
                }

                MenuRow {
                    icon: "save"
                    text: "Save current as new"
                    onClicked: window.saveNew()
                }

                MenuRow {
                    visible: Widgets.activePreset !== "" && Widgets.modified
                    icon: "sync"
                    text: "Update \"" + Widgets.activePreset + "\""
                    onClicked: Widgets.updatePreset(Widgets.activePreset)
                }
            }
        }
    }
}
