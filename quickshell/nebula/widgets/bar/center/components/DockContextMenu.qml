import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.services
import qs.theme

Rectangle {
    id: root

    property string key: ""

    readonly property bool open: key !== ""
    property string shownKey: ""
    readonly property var shownApp: Dock.app(shownKey)
    readonly property var windows: shownApp?.windows ?? []
    readonly property bool pinned: Dock.isPinned(shownKey)
    readonly property var actions: [
        { icon: "add", text: windows.length > 0 ? "New window" : "Open", run: () => Dock.launch(root.shownKey), show: !!root.shownApp?.entry },
        { icon: "push_pin", text: pinned ? "Unpin" : "Pin", run: () => Dock.togglePin(root.shownKey), show: true },
        { icon: "close", text: windows.length > 1 ? "Close all" : "Close", run: () => Dock.closeAll(root.shownKey), show: windows.length > 0 }
    ].filter(a => a.show)

    signal requestClose()

    onKeyChanged: {
        if (key === "") return;
        shownKey = key;
        Dock.refresh();
    }

    HyprlandFocusGrab {
        windows: [root.QsWindow.window]
        active: root.open && !GlobalStates.capturing
        onCleared: root.requestClose()
    }

    implicitWidth: Theme.dock.menuWidth
    implicitHeight: content.implicitHeight + Theme.spacing.sm * 2
    radius: Theme.radius.large
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.85
    transformOrigin: Item.Top

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }
    Behavior on scale {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
    }
    Behavior on implicitHeight {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
    }

    component Entry: Rectangle {
        id: entry

        property string icon: ""
        property string text: ""
        property bool current: false

        signal clicked()

        Layout.fillWidth: true
        implicitHeight: Theme.tray.menuRowHeight
        radius: Theme.radius.medium
        color: entryMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh

        Behavior on color {
            ColorAnimation { duration: Theme.anim.fast }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.md
            anchors.rightMargin: Theme.spacing.md
            spacing: Theme.spacing.sm

            Text {
                visible: entry.icon !== ""
                text: entry.icon
                font.family: Theme.font.icons
                font.pixelSize: Theme.settings.iconSize
                color: entry.current ? Colors.primary : Colors.textOnSurfaceVariant
            }

            Text {
                Layout.fillWidth: true
                text: entry.text
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: entry.current ? Font.DemiBold : Font.Normal
                color: Colors.textOnSurface
            }
        }

        MouseArea {
            id: entryMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: entry.clicked()
        }
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacing.sm
        spacing: Theme.settings.rowGap

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacing.sm
            Layout.rightMargin: Theme.spacing.sm
            Layout.topMargin: Theme.spacing.xs
            Layout.bottomMargin: Theme.spacing.xs
            spacing: Theme.spacing.sm

            IconImage {
                implicitSize: Theme.tray.iconSize
                source: root.shownApp?.icon ?? ""
                visible: source !== ""
            }

            Text {
                Layout.fillWidth: true
                text: root.shownApp?.name ?? ""
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                color: Colors.textOnSurface
            }
        }

        Repeater {
            model: root.open ? root.windows : []

            Entry {
                required property var modelData

                icon: modelData.activated ? "radio_button_checked" : "web_asset"
                text: modelData.title || root.shownApp?.name || ""
                current: modelData.activated
                onClicked: {
                    Dock.focus(modelData);
                    root.requestClose();
                }
            }
        }

        Item {
            visible: root.windows.length > 0
            Layout.fillWidth: true
            implicitHeight: Theme.spacing.sm

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - Theme.spacing.lg * 2
                height: 1
                color: Colors.outlineVariant
            }
        }

        Repeater {
            model: root.actions

            Entry {
                required property var modelData

                icon: modelData.icon
                text: modelData.text
                onClicked: {
                    modelData.run();
                    root.requestClose();
                }
            }
        }
    }
}
