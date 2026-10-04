import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    property int page: 0
    property int shownPage: 0
    property real pageT: 1

    readonly property var pages: [
        { title: "Appearance", subtitle: "Wallpaper, colors and light or dark", icon: "palette", shape: MaterialShape.Flower, source: "AppearancePage.qml" },
        { title: "Clock", subtitle: "How the time shows up in the bar", icon: "schedule", shape: MaterialShape.Cookie9Sided, source: "ClockPage.qml" },
        { title: "Notifications", subtitle: "Popups in the island", icon: "notifications", shape: MaterialShape.Sunny, source: "NotificationsPage.qml" },
        { title: "Recorder", subtitle: "Screen recording in the bottom-right corner", icon: "screen_record", shape: MaterialShape.Cookie4Sided, source: "RecorderPage.qml" },
        { title: "About", subtitle: "This machine and this shell", icon: "info", shape: MaterialShape.Clover4Leaf, source: "AboutPage.qml" }
    ]

    function go(index) {
        if (index < 0 || index >= pages.length || index === page) return;
        page = index;
        swap.restart();
    }

    implicitWidth: Theme.settings.width
    implicitHeight: Theme.settings.height
    focus: true

    Keys.onEscapePressed: GlobalStates.settingsOpen = false
    Keys.onUpPressed: go(page - 1)
    Keys.onDownPressed: go(page + 1)
    Keys.onTabPressed: go((page + 1) % pages.length)

    SequentialAnimation {
        id: swap
        NumberAnimation { target: root; property: "pageT"; to: 0; duration: Theme.anim.fast; easing.type: Easing.InCubic }
        ScriptAction { script: { root.shownPage = root.page; flick.contentY = 0; } }
        NumberAnimation { target: root; property: "pageT"; to: 1; duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
    }

    Item {
        id: rail
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.md
        width: Theme.settings.railWidth

        Text {
            id: heading
            x: Theme.spacing.lg
            y: Theme.spacing.lg
            text: "Settings"
            font.family: Theme.font.family
            font.pixelSize: Theme.settings.titleSize * 0.8
            font.weight: Font.Bold
            color: Colors.textOnSurface
        }

        Item {
            id: items
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: heading.bottom
            anchors.topMargin: Theme.spacing.xl
            height: root.pages.length * Theme.settings.railItemHeight

            Rectangle {
                width: parent.width
                height: Theme.settings.railItemHeight
                radius: height / 2
                color: Colors.secondaryContainer
                y: root.page * Theme.settings.railItemHeight

                Behavior on y {
                    NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                }
            }

            MaterialShape {
                x: Theme.spacing.md
                y: root.page * Theme.settings.railItemHeight + (Theme.settings.railItemHeight - height) / 2
                width: Theme.settings.indicatorSize
                height: Theme.settings.indicatorSize
                shape: root.pages[root.page].shape
                color: Colors.primary
                animationDuration: Theme.anim.island
                animationEasing.type: Easing.OutBack
                animationEasing.overshoot: Theme.anim.overshoot

                Behavior on y {
                    NumberAnimation { duration: Theme.anim.island; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                }
            }

            Repeater {
                model: root.pages

                Item {
                    id: item
                    required property var modelData
                    required property int index
                    readonly property bool active: index === root.page

                    y: index * Theme.settings.railItemHeight
                    width: items.width
                    height: Theme.settings.railItemHeight

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: Colors.textOnSurface
                        opacity: itemMouse.containsMouse && !item.active ? 0.06 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.anim.fast }
                        }
                    }

                    Text {
                        x: Theme.spacing.md + (Theme.settings.indicatorSize - width) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: item.modelData.icon
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: item.active ? Colors.textOnPrimary : Colors.textOnSurfaceVariant

                        Behavior on color {
                            ColorAnimation { duration: Theme.anim.medium }
                        }
                    }

                    Text {
                        x: Theme.spacing.md + Theme.settings.indicatorSize + Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter
                        text: item.modelData.title
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: item.active ? Font.DemiBold : Font.Medium
                        color: item.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.go(item.index)
                    }
                }
            }
        }

        IconButton {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Theme.spacing.sm
            icon: "close"
            onClicked: GlobalStates.settingsOpen = false
        }
    }

    Rectangle {
        id: panel
        anchors.left: rail.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacing.md
        radius: Theme.radius.large
        color: Colors.surfaceContainerLow
        clip: true

        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: width
            contentHeight: body.implicitHeight + Theme.settings.padding * 2
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: body
                x: Theme.settings.padding
                y: Theme.settings.padding + (1 - root.pageT) * Theme.settings.slide
                width: flick.width - Theme.settings.padding * 2
                spacing: Theme.spacing.xl
                opacity: root.pageT

                ColumnLayout {
                    spacing: Theme.spacing.xs

                    Text {
                        text: root.pages[root.shownPage].title
                        font.family: Theme.font.family
                        font.pixelSize: Theme.settings.titleSize
                        font.weight: Font.Bold
                        color: Colors.textOnSurface
                    }

                    Text {
                        text: root.pages[root.shownPage].subtitle
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        color: Colors.textOnSurfaceVariant
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    source: root.visible ? root.pages[root.shownPage].source : ""
                }
            }
        }
    }
}
