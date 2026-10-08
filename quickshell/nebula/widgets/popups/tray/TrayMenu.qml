import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.components
import qs.services
import qs.theme

Rectangle {
    id: root

    property SystemTrayItem item: null
    property var menuStack: []
    property var titles: []

    readonly property bool open: item !== null

    signal requestClose()

    function back() {
        menuStack = menuStack.slice(0, -1);
        titles = titles.slice(0, -1);
    }

    function close() {
        requestClose();
    }

    onItemChanged: {
        if (!item) return;
        menuStack = [item.menu];
        titles = [item.tooltipTitle || item.title || item.id];
    }

    implicitWidth: Theme.tray.menuWidth
    implicitHeight: content.implicitHeight + Theme.spacing.lg * 2
    radius: Theme.radius.large
    color: Qt.alpha(Colors.surface, Theme.bar.opacity)

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.85
    transformOrigin: Item.TopRight

    Behavior on opacity {
        NumberAnimation { duration: Theme.anim.fast }
    }
    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.medium
            easing.type: Easing.OutBack
            easing.overshoot: Theme.anim.overshoot
        }
    }
    Behavior on implicitHeight {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
    }

    QsMenuOpener {
        id: opener
        menu: root.menuStack[root.menuStack.length - 1] ?? null
    }

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.sm

            IconButton {
                visible: root.menuStack.length > 1
                icon: "arrow_back"
                onClicked: root.back()
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: root.menuStack.length > 1 ? 0 : Theme.spacing.xs
                text: root.titles[root.titles.length - 1] ?? ""
                elide: Text.ElideRight
                font.family: Theme.font.family
                font.pixelSize: Theme.font.large
                font.weight: Font.DemiBold
                color: Colors.textOnSurface
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.settings.rowGap

            Repeater {
                model: opener.children

                Rectangle {
                    id: entry

                    required property QsMenuEntry modelData

                    Layout.fillWidth: true
                    implicitHeight: modelData.isSeparator ? Theme.spacing.sm : Theme.tray.menuRowHeight
                    radius: Theme.radius.medium
                    color: modelData.isSeparator ? "transparent"
                         : entryMouse.containsMouse && modelData.enabled ? Colors.surfaceContainerHighest
                         : Colors.surfaceContainerHigh

                    Rectangle {
                        visible: entry.modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacing.lg * 2
                        height: 1
                        color: Colors.outlineVariant
                    }

                    RowLayout {
                        visible: !entry.modelData.isSeparator
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacing.md
                        anchors.rightMargin: Theme.spacing.md
                        spacing: Theme.spacing.sm
                        opacity: entry.modelData.enabled ? 1 : 0.4

                        Text {
                            visible: entry.modelData.buttonType !== QsMenuButtonType.None
                            text: entry.modelData.checkState === Qt.Checked
                                ? (entry.modelData.buttonType === QsMenuButtonType.RadioButton ? "radio_button_checked" : "check_box")
                                : (entry.modelData.buttonType === QsMenuButtonType.RadioButton ? "radio_button_unchecked" : "check_box_outline_blank")
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: Colors.primary
                        }

                        IconImage {
                            visible: entry.modelData.icon !== ""
                            implicitSize: Theme.settings.iconSize
                            source: entry.modelData.icon
                        }

                        Text {
                            Layout.fillWidth: true
                            text: entry.modelData.text
                            elide: Text.ElideRight
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            color: Colors.textOnSurface
                        }

                        Text {
                            visible: entry.modelData.hasChildren
                            text: "chevron_right"
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: Colors.textOnSurfaceVariant
                        }
                    }

                    MouseArea {
                        id: entryMouse
                        anchors.fill: parent
                        enabled: !entry.modelData.isSeparator && entry.modelData.enabled
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (entry.modelData.hasChildren) {
                                root.titles = root.titles.concat([entry.modelData.text]);
                                root.menuStack = root.menuStack.concat([entry.modelData]);
                            } else {
                                entry.modelData.triggered();
                                root.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
