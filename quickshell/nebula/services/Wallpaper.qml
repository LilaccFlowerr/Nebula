pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string directory: Settings.wallpaper.directory || home + "/Pictures/Wallpapers"
    readonly property string current: Settings.wallpaper.path || directory + "/zelda.jpeg"
    property var files: []

    function url(path) {
        return "file://" + path.split("/").map(encodeURIComponent).join("/");
    }

    function name(path) {
        return path.split("/").pop().replace(/\.[^.]+$/, "");
    }

    function set(path) {
        if (!path) return;
        Settings.wallpaper.path = path;
        matugen.command = ["sh", "-c", "matugen image \"$1\" < /dev/null", "sh", path];
        matugen.running = false;
        matugen.running = true;
    }

    FolderListModel {
        id: folder
        folder: "file://" + root.directory
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        caseSensitive: false
        showDirs: false
        sortField: FolderListModel.Name
        function update() {
            root.files = Array.from({ length: count }, (_, i) => get(i, "filePath"));
        }

        onCountChanged: update()
        onStatusChanged: if (status === FolderListModel.Ready) update()
    }

    Process {
        id: matugen
        stderr: SplitParser {
            onRead: line => console.warn("matugen:", line)
        }
    }

    IpcHandler {
        target: "wallpaper"

        function set(path: string): void { root.set(path); }
    }
}
