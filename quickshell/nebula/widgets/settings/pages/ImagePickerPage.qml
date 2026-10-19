import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.services
import qs.theme
import qs.widgets.settings.components

ColumnLayout {
    id: page

    signal navigate(string target)

    readonly property string home: Quickshell.env("HOME")
    readonly property var places: [
        { name: "Pictures", icon: "image", path: home + "/Pictures" },
        { name: "Wallpapers", icon: "wallpaper", path: home + "/Pictures/Wallpapers" },
        { name: "Downloads", icon: "download", path: home + "/Downloads" },
        { name: "Home", icon: "home", path: home }
    ]
    property string directory: home + "/Pictures"
    readonly property string shown: directory === home ? "~" : directory.startsWith(home + "/") ? "~" + directory.slice(home.length) : directory

    function resolve(text) {
        let path = text.trim();
        if (path === "~" || path.startsWith("~/")) path = home + path.slice(1);
        if (path.length > 1 && path.endsWith("/")) path = path.slice(0, -1);
        return path;
    }

    function up() {
        if (directory === "/") return;
        const cut = directory.lastIndexOf("/");
        directory = cut <= 0 ? "/" : directory.slice(0, cut);
    }

    function choose(path) {
        if (Widgets.replacing !== "") {
            const id = Widgets.replacing;
            Widgets.replacing = "";
            Widgets.update(id, { source: path });
            navigate("widget:" + id);
            return;
        }
        navigate("widget:" + Widgets.add("image", { source: path }));
    }

    spacing: Theme.spacing.lg

    Flow {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        Repeater {
            model: page.places

            Rectangle {
                id: place

                required property var modelData
                readonly property bool active: modelData.path === page.directory

                implicitWidth: placeRow.implicitWidth + Theme.spacing.lg * 2
                implicitHeight: Theme.button.size
                radius: active ? height / 2 : Theme.radius.medium
                color: active ? Colors.secondaryContainer : placeMouse.containsMouse ? Qt.alpha(Colors.textOnSurface, 0.08) : "transparent"
                border.width: active ? 0 : 1
                border.color: Colors.outlineVariant

                Behavior on radius {
                    NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.standard }
                }

                Row {
                    id: placeRow
                    anchors.centerIn: parent
                    spacing: Theme.spacing.sm

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: place.modelData.icon
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: place.active ? Colors.textOnSecondaryContainer : Colors.primary
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: place.modelData.name
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        font.weight: place.active ? Font.DemiBold : Font.Normal
                        color: place.active ? Colors.textOnSecondaryContainer : Colors.textOnSurface
                    }
                }

                MouseArea {
                    id: placeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.directory = place.modelData.path
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        IconButton {
            icon: "arrow_upward"
            onClicked: page.up()
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: Theme.button.size
            radius: height / 2
            color: input.activeFocus ? Colors.surfaceContainerHighest : Colors.surfaceContainer
            border.width: input.activeFocus ? 2 : 1
            border.color: files.status === FolderListModel.Null ? Colors.errorColor : input.activeFocus ? Colors.primary : Colors.outlineVariant

            Text {
                id: folderIcon
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                text: "folder_open"
                font.family: Theme.font.icons
                font.pixelSize: Theme.settings.iconSize
                color: Colors.textOnSurfaceVariant
            }

            TextInput {
                id: input
                anchors.left: folderIcon.right
                anchors.leftMargin: Theme.spacing.sm
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                selectByMouse: true
                clip: true
                font.family: Theme.font.family
                font.pixelSize: Theme.font.normal
                font.weight: Font.DemiBold
                color: Colors.textOnSurface
                selectionColor: Colors.primary
                selectedTextColor: Colors.textOnPrimary
                onAccepted: {
                    page.directory = page.resolve(text);
                    focus = false;
                }
                onActiveFocusChanged: if (!activeFocus) text = page.shown

                Component.onCompleted: text = page.shown

                Connections {
                    target: page

                    function onDirectoryChanged() {
                        if (!input.activeFocus) input.text = page.shown;
                    }
                }
            }
        }
    }

    FolderListModel {
        id: files
        folder: "file://" + page.directory
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif"]
        caseSensitive: false
        showDirs: true
        showDotAndDotDot: false
        showHidden: false
        showDirsFirst: true
        sortField: FolderListModel.Name
    }

    Flow {
        Layout.fillWidth: true
        spacing: Theme.spacing.sm

        Repeater {
            model: files

            Rectangle {
                id: folderChip

                required property string filePath
                required property string fileName
                required property bool fileIsDir

                visible: fileIsDir
                implicitWidth: folderRow.implicitWidth + Theme.spacing.lg * 2
                implicitHeight: Theme.button.size - Theme.spacing.xs
                radius: height / 2
                color: folderMouse.containsMouse ? Colors.secondaryContainer : Colors.surfaceContainerHigh

                Behavior on color {
                    ColorAnimation { duration: Theme.anim.fast }
                }

                Row {
                    id: folderRow
                    anchors.centerIn: parent
                    spacing: Theme.spacing.sm

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "folder"
                        font.family: Theme.font.icons
                        font.pixelSize: Theme.settings.iconSize
                        color: Colors.primary
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: folderChip.fileName
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.normal
                        color: Colors.textOnSurface
                    }
                }

                MouseArea {
                    id: folderMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: page.directory = folderChip.filePath
                }
            }
        }
    }

    SettingGroup {
        Grid {
            id: grid

            readonly property real cell: (width - spacing * (columns - 1)) / columns

            Layout.fillWidth: true
            Layout.margins: Theme.spacing.md
            columns: 4
            spacing: Theme.spacing.md

            Repeater {
                model: files

                ColumnLayout {
                    id: entry

                    required property string filePath
                    required property string fileName
                    required property bool fileIsDir

                    visible: !fileIsDir
                    width: grid.cell
                    spacing: Theme.spacing.xs

                    ClippingRectangle {
                        Layout.preferredWidth: grid.cell
                        Layout.preferredHeight: grid.cell
                        radius: mouse.containsMouse ? Theme.radius.large : Theme.radius.medium
                        color: Colors.surfaceContainerHighest

                        Behavior on radius {
                            NumberAnimation { duration: Theme.anim.medium; easing.type: Easing.OutBack; easing.overshoot: Theme.anim.overshoot }
                        }

                        Image {
                            id: thumb
                            anchors.fill: parent
                            source: entry.fileIsDir ? "" : Wallpaper.url(entry.filePath)
                            sourceSize.width: Theme.settings.thumbWidth
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        LoadingIndicator {
                            anchors.centerIn: parent
                            width: parent.height * 0.4
                            height: width
                            running: thumb.status === Image.Loading
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: page.choose(entry.filePath)
                        }
                    }

                    Text {
                        Layout.preferredWidth: grid.cell
                        text: entry.fileName
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.small
                        color: Colors.textOnSurfaceVariant
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Theme.spacing.lg
            visible: files.status === FolderListModel.Null || files.count === 0
            text: files.status === FolderListModel.Null ? "That folder doesn't exist" : "Nothing here"
            font.family: Theme.font.family
            font.pixelSize: Theme.font.normal
            color: Colors.textOnSurfaceVariant
        }
    }
}
