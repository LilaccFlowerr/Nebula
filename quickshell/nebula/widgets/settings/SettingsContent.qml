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
    property string sub: ""
    property string shownSub: ""
    property real pageT: 1
    property real slideX: 0
    property real pageScale: 1
    property int direction: 0

    readonly property var subpages: ({
        wallpapers: { title: "Wallpapers", subtitle: "Pick one, it applies right away", source: "WallpapersPage.qml" }
    })
    readonly property var current: shownSub !== "" ? subpages[shownSub] : pages[shownPage]

    readonly property var pages: [
        { key: "appearance", title: "Appearance", subtitle: "Wallpaper, colors and light or dark", icon: "palette", shape: MaterialShape.Flower, source: "AppearancePage.qml" },
        { key: "desktop", title: "Desktop", subtitle: "Widgets that live on your wallpaper", icon: "desktop_windows", shape: MaterialShape.Cookie6Sided, source: "DesktopPage.qml" },
        { key: "bar", title: "Bar", subtitle: "Customize each island", icon: "toolbar", shape: MaterialShape.Pill, source: "BarPage.qml" },
        { key: "connections", title: "Connections", subtitle: "Wifi, ethernet and bluetooth", icon: "wifi", shape: MaterialShape.Cookie12Sided, source: "ConnectionsPage.qml" },
        { key: "notifications", title: "Notifications", subtitle: "Popups in the island", icon: "notifications", shape: MaterialShape.Sunny, source: "NotificationsPage.qml" },
        { key: "recorder", title: "Recorder", subtitle: "Screen recording in the bottom-right corner", icon: "screen_record", shape: MaterialShape.Cookie4Sided, source: "RecorderPage.qml" },
        { key: "about", title: "About", subtitle: "This machine and this shell", icon: "info", shape: MaterialShape.Clover4Leaf, source: "AboutPage.qml" }
    ]

    function go(index) {
        if (index < 0 || index >= pages.length || (index === page && sub === "")) return;
        page = index;
        sub = "";
        swap.restart();
    }

    function navigate(target) {
        if (target === sub) return;
        direction = target !== "" ? 1 : -1;
        sub = target;
        slide.restart();
    }

    implicitWidth: Theme.settings.width
    implicitHeight: Theme.settings.height
    focus: true

    Keys.onEscapePressed: {
        if (Wifi.prompt) Wifi.prompt = null;
        else if (sub !== "") navigate("");
        else GlobalStates.settingsOpen = false;
    }

    onVisibleChanged: {
        if (!visible) {
            sub = "";
            shownSub = "";
            Wifi.prompt = null;
            return;
        }
        const index = pages.findIndex(p => p.key === GlobalStates.settingsPage);
        GlobalStates.settingsPage = "";
        if (index >= 0) {
            page = index;
            shownPage = index;
        }
    }
    Keys.onUpPressed: go(page - 1)
    Keys.onDownPressed: go(page + 1)
    Keys.onTabPressed: go((page + 1) % pages.length)

    SequentialAnimation {
        id: swap
        ScriptAction { script: root.slideX = 0 }
        NumberAnimation { target: root; property: "pageT"; to: 0; duration: Theme.anim.fast; easing.type: Easing.InCubic }
        ScriptAction { script: { root.shownPage = root.page; root.shownSub = root.sub; root.pageScale = Theme.settings.fadeThroughScale; flick.contentY = 0; } }
        ParallelAnimation {
            NumberAnimation { target: root; property: "pageT"; to: 1; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
            NumberAnimation { target: root; property: "pageScale"; to: 1; duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }
    }

    SequentialAnimation {
        id: slide
        ParallelAnimation {
            NumberAnimation { target: root; property: "pageT"; to: 0; duration: Theme.anim.fast; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "slideX"; to: -root.direction * Theme.settings.subSlide; duration: Theme.anim.fast; easing.type: Easing.InCubic }
        }
        ScriptAction { script: { root.shownPage = root.page; root.shownSub = root.sub; root.slideX = root.direction * Theme.settings.subSlide; flick.contentY = 0; } }
        ParallelAnimation {
            NumberAnimation { target: root; property: "pageT"; to: 1; duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
            NumberAnimation { target: root; property: "slideX"; to: 0; duration: Theme.anim.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.emphasizedDecel }
        }
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
                x: Theme.settings.padding + root.slideX
                y: Theme.settings.padding
                scale: root.pageScale
                transformOrigin: Item.Top
                width: flick.width - Theme.settings.padding * 2
                spacing: Theme.spacing.xl
                opacity: root.pageT

                RowLayout {
                    spacing: Theme.spacing.md

                    IconButton {
                        visible: root.shownSub !== ""
                        icon: "arrow_back"
                        onClicked: root.navigate("")
                    }

                    ColumnLayout {
                        spacing: Theme.spacing.xs

                        Text {
                            text: root.current.title
                            font.family: Theme.font.family
                            font.pixelSize: Theme.settings.titleSize
                            font.weight: Font.Bold
                            color: Colors.textOnSurface
                        }

                        Text {
                            text: root.current.subtitle
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            color: Colors.textOnSurfaceVariant
                        }
                    }
                }

                Loader {
                    id: loader
                    Layout.fillWidth: true
                    source: root.visible ? root.current.source : ""
                }

                Connections {
                    target: loader.item
                    ignoreUnknownSignals: true

                    function onNavigate(target) {
                        root.navigate(target);
                    }
                }
            }
        }
    }

    WifiPasswordDialog {
        anchors.fill: parent
        z: 1
    }

    IconButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.spacing.md + Theme.spacing.sm
        icon: "close"
        onClicked: GlobalStates.settingsOpen = false
    }
}
