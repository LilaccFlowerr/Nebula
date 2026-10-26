import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
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
        { icon: "add", text: "New window", run: () => Dock.launch(root.shownKey), show: !!root.shownApp?.entry },
        { icon: "push_pin", text: pinned ? "Unpin" : "Pin", run: () => Dock.togglePin(root.shownKey), show: true },
        { icon: "close", text: windows.length > 1 ? "Close all" : "Close", run: () => Dock.closeAll(root.shownKey), show: windows.length > 0 }
    ].filter(a => a.show)

    signal requestClose()

    onKeyChanged: {
        if (key === "") return;
        shownKey = key;
        Dock.refresh();
    }

    implicitWidth: Math.max(Theme.dock.menuWidth, thumbs.implicitWidth, actionRow.implicitWidth) + Theme.spacing.md * 2
    implicitHeight: content.implicitHeight + Theme.spacing.md * 2
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
    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
    }
    Behavior on implicitHeight {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacing.md
        spacing: Theme.spacing.md

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.spacing.xs
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

            Text {
                visible: root.windows.length > 1
                text: root.windows.length + " windows"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
                color: Colors.textOnSurfaceVariant
            }
        }

        Row {
            id: thumbs
            Layout.alignment: Qt.AlignHCenter
            visible: root.windows.length > 0
            spacing: Theme.spacing.sm

            Repeater {
                model: root.open ? root.windows : []

                Rectangle {
                    id: card

                    required property var modelData
                    readonly property bool current: modelData.activated
                    readonly property size source: shot.sourceSize
                    readonly property real ratio: source.width > 0 ? source.height / source.width : 0.6

                    width: Theme.dock.thumbWidth + Theme.spacing.sm * 2
                    height: thumbBox.height + titleText.implicitHeight + Theme.spacing.sm * 3
                    radius: Theme.radius.medium
                    color: cardMouse.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
                    border.width: current ? 2 : 0
                    border.color: Colors.primary

                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.fast }
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Dock.focus(card.modelData);
                            root.requestClose();
                        }
                    }

                    ClippingRectangle {
                        id: thumbBox
                        x: Theme.spacing.sm
                        y: Theme.spacing.sm
                        width: Theme.dock.thumbWidth
                        height: Theme.dock.thumbHeight
                        radius: Theme.radius.small
                        color: Colors.surfaceContainer

                        ScreencopyView {
                            id: shot
                            anchors.centerIn: parent
                            width: card.ratio * parent.width > parent.height ? parent.height / card.ratio : parent.width
                            height: width * card.ratio
                            captureSource: root.open ? card.modelData.wayland : null
                            live: false
                            constraintSize: Qt.size(Theme.dock.thumbWidth * 2, Theme.dock.thumbHeight * 2)
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !shot.hasContent
                            text: "web_asset"
                            font.family: Theme.font.icons
                            font.pixelSize: 28
                            color: Colors.textOnSurfaceVariant
                        }

                        Row {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: Theme.spacing.xs
                            spacing: Theme.spacing.xs
                            opacity: cardMouse.containsMouse || killHover.hovered || closeHover.hovered ? 1 : 0
                            visible: opacity > 0

                            Behavior on opacity {
                                NumberAnimation { duration: Theme.anim.fast }
                            }

                            Rectangle {
                                width: Theme.dock.windowButton
                                height: width
                                radius: width / 2
                                color: killHover.hovered ? Colors.errorContainer : Qt.alpha(Colors.surface, 0.85)

                                HoverHandler { id: killHover }

                                Text {
                                    anchors.centerIn: parent
                                    text: "dangerous"
                                    font.family: Theme.font.icons
                                    font.pixelSize: Theme.dock.windowButton - 8
                                    color: killHover.hovered ? Colors.textOnErrorContainer : Colors.textOnSurface
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Dock.killWindow(card.modelData)
                                }
                            }

                            Rectangle {
                                width: Theme.dock.windowButton
                                height: width
                                radius: width / 2
                                color: closeHover.hovered ? Colors.primaryContainer : Qt.alpha(Colors.surface, 0.85)

                                HoverHandler { id: closeHover }

                                Text {
                                    anchors.centerIn: parent
                                    text: "close"
                                    font.family: Theme.font.icons
                                    font.pixelSize: Theme.dock.windowButton - 8
                                    color: closeHover.hovered ? Colors.textOnPrimaryContainer : Colors.textOnSurface
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Dock.closeWindow(card.modelData)
                                }
                            }
                        }
                    }

                    Text {
                        id: titleText
                        x: Theme.spacing.sm
                        anchors.top: thumbBox.bottom
                        anchors.topMargin: Theme.spacing.sm
                        width: Theme.dock.thumbWidth
                        text: card.modelData.title || root.shownApp?.name || ""
                        elide: Text.ElideRight
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        font.weight: card.current ? Font.DemiBold : Font.Normal
                        color: Colors.textOnSurface
                    }
                }
            }
        }

        Row {
            id: actionRow
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.settings.rowGap

            Repeater {
                model: root.actions

                Rectangle {
                    id: action

                    required property var modelData
                    required property int index

                    width: actionContent.implicitWidth + Theme.spacing.md * 2
                    height: Theme.tray.menuRowHeight
                    topLeftRadius: index === 0 ? height / 2 : Theme.settings.rowRadius
                    bottomLeftRadius: topLeftRadius
                    topRightRadius: index === root.actions.length - 1 ? height / 2 : Theme.settings.rowRadius
                    bottomRightRadius: topRightRadius
                    color: actionMouse.containsMouse ? Colors.secondaryContainer : Colors.surfaceContainerHigh

                    Behavior on color {
                        ColorAnimation { duration: Theme.anim.fast }
                    }

                    Row {
                        id: actionContent
                        anchors.centerIn: parent
                        spacing: Theme.spacing.xs

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: action.modelData.icon
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.tray.iconSize - 4
                            color: actionMouse.containsMouse ? Colors.textOnSecondaryContainer : Colors.primary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: action.modelData.text
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small
                            color: actionMouse.containsMouse ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            action.modelData.run();
                            root.requestClose();
                        }
                    }
                }
            }
        }
    }
}
