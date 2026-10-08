import QtQuick
import QtQuick.Layouts
import M3Shapes
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components
import qs.widgets.settings.pages.connections
import "../../components/Curves.js" as Curves
import "SettingsIndex.js" as SettingsIndex

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
        wallpapers: { title: "Wallpapers", subtitle: "Click one to use it", source: "pages/appearance/WallpapersPage.qml" }
    })
    readonly property string subKey: shownSub.split(":")[0]
    readonly property string subArg: shownSub.split(":")[1] ?? ""
    readonly property var current: shownSub === "" ? pages?.[shownPage]
        : subKey === "section" ? pages?.[shownPage]?.sections?.find(x => x.key === subArg) ?? pages?.[shownPage]
        : subKey === "app" ? ({ title: Apps.roles.find(r => r.key === subArg)?.title ?? "App", subtitle: "Pick one", source: "pages/apps/AppPickerPage.qml" })
        : subpages?.[subKey] ?? pages?.[shownPage]

    readonly property var pages: [
        { key: "appearance", title: "Appearance", subtitle: "Wallpaper and colors", icon: "palette", shape: MaterialShape.Flower, source: "pages/appearance/AppearancePage.qml", reset: ["theme", "wallpaper.transition"] },
        { key: "desktop", title: "Desktop", subtitle: "Stuff on your wallpaper", icon: "desktop_windows", shape: MaterialShape.Cookie6Sided, source: "pages/DesktopPage.qml", reset: ["nowPlaying"] },
        { key: "bar", title: "Bar", subtitle: "Tweak each island", icon: "toolbar", shape: MaterialShape.Pill, source: "pages/SectionsPage.qml", reset: ["bar", "clock", "weather", "quickSettings"], sections: [
            { key: "left", title: "Left island", subtitle: "Workspaces", icon: "view_week", source: "pages/bar/LeftTab.qml" },
            { key: "middle", title: "Middle island", subtitle: "Visualizer, lyrics and popups", icon: "graphic_eq", source: "pages/bar/MiddleTab.qml" },
            { key: "right", title: "Right island", subtitle: "Clock, buttons, weather and tiles", icon: "schedule", source: "pages/bar/RightTab.qml" }
        ] },
        { key: "connections", title: "Connections", subtitle: "Wifi, cable and bluetooth", icon: "wifi", shape: MaterialShape.Cookie12Sided, source: "pages/SectionsPage.qml", sections: [
            { key: "wifi", title: "Wifi", subtitle: "Networks and passwords", icon: "wifi", source: "pages/connections/WifiTab.qml" },
            { key: "ethernet", title: "Ethernet", subtitle: "Cable, IP and MAC address", icon: "lan", source: "pages/connections/EthernetTab.qml" },
            { key: "bluetooth", title: "Bluetooth", subtitle: "Devices and pairing", icon: "bluetooth", source: "pages/connections/BluetoothTab.qml" }
        ] },
        { key: "system", title: "System", subtitle: "Screens, battery and input", icon: "tune", shape: MaterialShape.Gem, source: "pages/SectionsPage.qml", reset: ["input", "power"], sections: [
            { key: "displays", title: "Displays", subtitle: "Resolution, scale and brightness", icon: "monitor", source: "pages/system/DisplaysTab.qml" },
            { key: "power", title: "Power", subtitle: "Power mode and battery", icon: "battery_horiz_075", source: "pages/system/PowerTab.qml" },
            { key: "input", title: "Input", subtitle: "Keyboard, mouse and touchpad", icon: "keyboard", source: "pages/system/InputTab.qml" }
        ] },
        { key: "apps", title: "Apps", subtitle: "What opens what", icon: "apps", shape: MaterialShape.Puffy, source: "pages/apps/AppsPage.qml", reset: ["apps"] },
        { key: "notifications", title: "Notifications", subtitle: "The popups in the island", icon: "notifications", shape: MaterialShape.Sunny, source: "pages/NotificationsPage.qml", reset: ["notifications"] },
        { key: "recorder", title: "Recorder", subtitle: "Recordings and screenshots", icon: "screen_record", shape: MaterialShape.Cookie4Sided, source: "pages/SectionsPage.qml", reset: ["recorder", "screenshot"], sections: [
            { key: "recording", title: "Recording", subtitle: "Audio, region and framerate", icon: "videocam", source: "pages/recorder/RecordingTab.qml" },
            { key: "screenshots", title: "Screenshots", subtitle: "Clipboard, notification and folder", icon: "screenshot_region", source: "pages/recorder/ScreenshotsTab.qml" }
        ] },
        { key: "about", title: "About", subtitle: "This machine", icon: "info", shape: MaterialShape.Clover4Leaf, source: "pages/AboutPage.qml" }
    ]

    readonly property var groups: [
        { label: "Look", keys: ["appearance", "desktop", "bar"] },
        { label: "Connect", keys: ["connections"] },
        { label: "System", keys: ["system", "apps", "notifications", "recorder", "about"] }
    ]
    readonly property var railEntries: {
        const out = [];
        groups.forEach((g, gi) => {
            out.push({ label: g.label, firstGroup: gi === 0 });
            g.keys.forEach((k, i) => out.push({ page: pages.findIndex(p => p.key === k), first: i === 0, last: i === g.keys.length - 1 }));
        });
        return out;
    }
    property real railT: Settings.settingsWindow.railOpen ? 1 : 0

    Behavior on railT {
        NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
    }

    function lerp(a, b, t) {
        return a + (b - a) * t;
    }

    property string query: ""
    property int resultIndex: 0
    readonly property bool searching: query.trim() !== ""
    readonly property var results: SettingsIndex.search(query, pages)

    onQueryChanged: resultIndex = 0

    function focusSearch() {
        if (!Settings.settingsWindow.railOpen) Settings.settingsWindow.railOpen = true;
        searchInput.forceActiveFocus();
    }

    function clearSearch() {
        query = "";
        root.forceActiveFocus();
    }

    function openResult(result) {
        if (!result) return;
        const index = pages.findIndex(p => p.key === result.page);
        const target = result.tab && pages[index]?.sections ? "section:" + result.tab : "";
        clearSearch();
        if (index === page) {
            if (target !== sub) navigate(target);
            return;
        }
        page = index;
        sub = target;
        swap.restart();
    }

    function toggleRail() {
        Settings.settingsWindow.railOpen = !Settings.settingsWindow.railOpen;
    }

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

    Keys.onPressed: event => {
        if (event.key === Qt.Key_F && (event.modifiers & Qt.ControlModifier)) {
            root.focusSearch();
            event.accepted = true;
        }
    }

    Keys.onEscapePressed: {
        if (root.searching) root.clearSearch();
        else if (Wifi.prompt) Wifi.prompt = null;
        else if (sub !== "") navigate("");
        else GlobalStates.settingsOpen = false;
    }

    onVisibleChanged: {
        if (!visible) {
            query = "";
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
            if (GlobalStates.settingsTab !== "" && pages[index].sections) {
                sub = "section:" + GlobalStates.settingsTab;
                shownSub = sub;
            }
        }
        GlobalStates.settingsTab = "";
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
        width: root.lerp(Theme.settings.railClosedWidth, Theme.settings.railOpenWidth, root.railT)
        clip: true

        readonly property real closedX: (Theme.settings.railClosedWidth - Theme.settings.railButtonSize) / 2

        Item {
            id: railTop
            width: parent.width
            height: root.lerp(Theme.settings.railButtonSize * 2 + Theme.spacing.sm, Theme.settings.railButtonSize, root.railT)

            Rectangle {
                x: rail.closedX
                y: 0
                width: root.lerp(Theme.settings.railButtonSize, rail.width - Theme.settings.railButtonSize - Theme.spacing.sm, root.railT)
                height: Theme.settings.railButtonSize
                radius: height / 2
                color: Colors.surfaceContainerLowest
                border.width: 1
                border.color: Colors.outlineVariant

                Text {
                    x: root.lerp((parent.height - width) / 2, Theme.spacing.lg, root.railT)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "search"
                    font.family: Theme.font.icons
                    font.pixelSize: Theme.settings.iconSize
                    color: Colors.textOnSurfaceVariant
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Settings.settingsWindow.railOpen ? Qt.IBeamCursor : Qt.PointingHandCursor
                    onClicked: root.focusSearch()
                }

                Text {
                    x: searchInput.x
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: Curves.phase(root.railT, 0.5, 0.5)
                    visible: opacity > 0 && searchInput.text === ""
                    text: "Search"
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Colors.textOnSurfaceVariant
                }

                TextInput {
                    id: searchInput

                    x: Theme.spacing.lg + Theme.settings.iconSize + Theme.spacing.sm
                    width: parent.width - x - Theme.spacing.md
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: Curves.phase(root.railT, 0.5, 0.5)
                    visible: opacity > 0
                    clip: true
                    text: root.query
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.normal
                    color: Colors.textOnSurface
                    selectionColor: Colors.primary
                    selectedTextColor: Colors.textOnPrimary
                    onTextEdited: root.query = text

                    Keys.onEscapePressed: root.clearSearch()
                    Keys.onUpPressed: root.resultIndex = Math.max(0, root.resultIndex - 1)
                    Keys.onDownPressed: root.resultIndex = Math.min(root.results.length - 1, root.resultIndex + 1)
                    Keys.onReturnPressed: root.openResult(root.results[root.resultIndex])
                    Keys.onEnterPressed: root.openResult(root.results[root.resultIndex])
                }
            }

            IconButton {
                x: root.lerp(rail.closedX, rail.width - Theme.settings.railButtonSize, root.railT)
                y: root.lerp(Theme.settings.railButtonSize + Theme.spacing.sm, 0, root.railT)
                icon: Settings.settingsWindow.railOpen ? "left_panel_close" : "left_panel_open"
                onClicked: root.toggleRail()
            }
        }

        Column {
            anchors.top: railTop.bottom
            anchors.topMargin: Theme.spacing.md
            width: parent.width
            spacing: Theme.settings.rowGap
            opacity: root.searching ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.fast }
            }

            Text {
                x: Theme.spacing.sm
                height: Theme.settings.railLabelHeight
                verticalAlignment: Text.AlignBottom
                text: root.results.length > 0 ? "Results" : "Nothing found"
                font.family: Theme.font.family
                font.pixelSize: Theme.font.small
                color: Colors.textOnSurfaceVariant
            }

            Repeater {
                model: root.results

                Rectangle {
                    id: result

                    required property var modelData
                    required property int index
                    readonly property var page: root.pages.find(p => p.key === modelData.page) ?? null
                    readonly property bool selected: index === root.resultIndex
                    readonly property bool first: index === 0
                    readonly property bool last: index === root.results.length - 1

                    width: parent.width
                    height: Theme.settings.railRowHeight
                    color: selected ? Colors.secondaryContainer : Colors.surfaceContainer
                    topLeftRadius: first ? Theme.radius.large - Theme.spacing.xs : Theme.settings.railRowRadius
                    topRightRadius: topLeftRadius
                    bottomLeftRadius: last ? Theme.radius.large - Theme.spacing.xs : Theme.settings.railRowRadius
                    bottomRightRadius: bottomLeftRadius

                    MaterialShape {
                        id: resultShape
                        x: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        width: Theme.settings.railShapeSize
                        height: Theme.settings.railShapeSize
                        implicitSize: Theme.settings.railShapeSize
                        shape: result.selected ? result.page?.shape ?? MaterialShape.Circle : MaterialShape.Circle
                        color: result.selected ? Colors.primaryContainer : Colors.surfaceContainerHigh
                    }

                    Text {
                        anchors.centerIn: resultShape
                        text: result.page?.icon ?? ""
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: result.selected ? Colors.textOnPrimaryContainer : Colors.primary
                    }

                    Column {
                        x: resultShape.x + resultShape.width + Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x - Theme.spacing.sm

                        Text {
                            width: parent.width
                            text: result.modelData.title
                            elide: Text.ElideRight
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            font.weight: result.selected ? Font.DemiBold : Font.Medium
                            color: result.selected ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                        }

                        Text {
                            width: parent.width
                            text: (result.page?.title ?? "") + (result.modelData.tab ? " › " + result.modelData.tab.charAt(0).toUpperCase() + result.modelData.tab.slice(1) : "")
                            elide: Text.ElideRight
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.small - 1
                            color: result.selected ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.resultIndex = result.index
                        onClicked: root.openResult(result.modelData)
                    }
                }
            }
        }

        Column {
            anchors.top: railTop.bottom
            anchors.topMargin: root.lerp(Theme.spacing.lg, Theme.spacing.md, root.railT)
            width: parent.width
            spacing: root.lerp(Theme.spacing.xs + 2, Theme.settings.rowGap, root.railT)
            opacity: root.searching ? 0 : 1
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: Theme.anim.fast }
            }

            Repeater {
                model: root.railEntries

                Item {
                    id: entry

                    required property var modelData
                    readonly property bool isLabel: modelData.label !== undefined
                    readonly property int pageIndex: modelData.page ?? -1
                    readonly property bool active: pageIndex === root.page
                    readonly property var page: isLabel ? null : root.pages[pageIndex]
                    property real squish: mouse.pressed ? 0.45 : 1

                    Behavior on squish {
                        NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                    }

                    width: rail.width
                    height: isLabel
                        ? root.lerp(modelData.firstGroup ? 0 : Theme.settings.railGroupGap - Theme.spacing.sm, Theme.settings.railLabelHeight, root.railT)
                        : root.lerp(Theme.settings.railButtonSize, Theme.settings.railRowHeight, root.railT)

                    Text {
                        visible: entry.isLabel && opacity > 0
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.spacing.xs
                        x: Theme.spacing.sm
                        opacity: Curves.phase(root.railT, 0.5, 0.5)
                        text: entry.modelData.label ?? ""
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        color: Colors.textOnSurfaceVariant
                    }

                    Rectangle {
                        id: block

                        readonly property real round: height / 2
                        readonly property real openTop: entry.active ? round : entry.modelData.first ? Theme.radius.large - Theme.spacing.xs : Theme.settings.railRowRadius
                        readonly property real openBottom: entry.active ? round : entry.modelData.last ? Theme.radius.large - Theme.spacing.xs : Theme.settings.railRowRadius

                        visible: !entry.isLabel
                        x: root.lerp(rail.closedX, 0, root.railT)
                        width: root.lerp(Theme.settings.railButtonSize, rail.width, root.railT)
                        height: parent.height
                        color: entry.active ? Qt.alpha(Colors.secondaryContainer, root.railT) : Colors.surfaceContainer
                        topLeftRadius: root.lerp(round, openTop, root.railT) * entry.squish
                        topRightRadius: topLeftRadius
                        bottomLeftRadius: root.lerp(round, openBottom, root.railT) * entry.squish
                        bottomRightRadius: bottomLeftRadius

                        Rectangle {
                            anchors.fill: parent
                            topLeftRadius: parent.topLeftRadius
                            topRightRadius: parent.topRightRadius
                            bottomLeftRadius: parent.bottomLeftRadius
                            bottomRightRadius: parent.bottomRightRadius
                            color: Colors.textOnSurface
                            opacity: mouse.containsMouse && !entry.active ? 0.06 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: Theme.anim.fast }
                            }
                        }

                        MaterialShape {
                            id: shape

                            readonly property real size: root.lerp(Theme.settings.railButtonSize, Theme.settings.railShapeSize, root.railT)

                            x: root.lerp(0, Theme.spacing.sm, root.railT)
                            anchors.verticalCenter: parent.verticalCenter
                            width: size
                            height: size
                            implicitSize: size
                            visible: entry.active || root.railT > 0
                            shape: entry.active ? entry.page?.shape ?? MaterialShape.Circle : MaterialShape.Circle
                            color: entry.active ? Colors.primaryContainer : Qt.alpha(Colors.surfaceContainerHigh, root.railT)
                            animationDuration: Theme.anim.island
                            animationEasing.type: Easing.OutBack
                            animationEasing.overshoot: Theme.anim.overshoot
                        }

                        Text {
                            anchors.centerIn: shape
                            text: entry.page?.icon ?? ""
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.iconSize
                            color: entry.active ? Colors.textOnPrimaryContainer : root.railT > 0.5 ? Colors.primary : Colors.textOnSurfaceVariant
                        }

                        Column {
                            x: shape.x + shape.width + Theme.spacing.md
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - x - Theme.spacing.sm
                            opacity: Curves.phase(root.railT, 0.45, 0.55)
                            visible: opacity > 0

                            Text {
                                width: parent.width
                                text: entry.page?.title ?? ""
                                elide: Text.ElideRight
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.normal
                                font.weight: entry.active ? Font.DemiBold : Font.Medium
                                color: entry.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                            }

                            Text {
                                width: parent.width
                                text: entry.page?.subtitle ?? ""
                                elide: Text.ElideRight
                                font.family: Theme.font.family
                                font.pixelSize: Theme.font.small - 1
                                color: entry.active ? Colors.textOnSecondaryContainer : Colors.textOnSurfaceVariant
                            }
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.go(entry.pageIndex)
                        }
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
                    Layout.fillWidth: true
                    spacing: Theme.spacing.md

                    IconButton {
                        visible: root.shownSub !== ""
                        icon: "arrow_back"
                        onClicked: root.navigate("")
                    }

                    MaterialShape {
                        visible: root.shownSub === ""
                        implicitSize: Theme.settings.headerShapeSize
                        implicitWidth: Theme.settings.headerShapeSize
                        implicitHeight: Theme.settings.headerShapeSize
                        shape: root.current?.shape ?? MaterialShape.Circle
                        color: Colors.primaryContainer

                        Text {
                            anchors.centerIn: parent
                            text: root.current?.icon ?? ""
                            font.family: Theme.font.icons
                            font.pixelSize: Theme.settings.headerIconSize
                            color: Colors.textOnPrimaryContainer
                        }
                    }

                    ColumnLayout {
                        spacing: Theme.spacing.xs

                        Text {
                            text: root.current?.title ?? ""
                            font.family: Theme.font.family
                            font.pixelSize: Theme.settings.titleSize
                            font.weight: Font.Bold
                            color: Colors.textOnSurface
                        }

                        Text {
                            text: root.current?.subtitle ?? ""
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.normal
                            color: Colors.textOnSurfaceVariant
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ActionButton {
                        visible: root.shownSub === "" && !!root.current?.reset
                        Layout.rightMargin: Theme.button.size - Theme.spacing.sm
                        icon: "restart_alt"
                        text: "Reset"
                        onClicked: Settings.reset(root.current.reset)
                    }
                }

                Loader {
                    id: loader
                    Layout.fillWidth: true
                    source: root.visible ? root.current?.source ?? "" : ""
                    onLoaded: {
                        if (item.arg !== undefined) item.arg = Qt.binding(() => root.subArg);
                        if (item.sections !== undefined) item.sections = Qt.binding(() => root.current?.sections ?? []);
                    }
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
