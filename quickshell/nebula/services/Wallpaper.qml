pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import M3Shapes

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string directory: Settings.wallpaper.directory || home + "/Pictures/Wallpapers"
    readonly property string current: Settings.wallpaper.path || directory + "/zelda.jpeg"
    property var files: []

    readonly property var transitions: [
        { key: "random", name: "Random", shape: -1 },
        { key: "cookie9", name: "Cookie", shape: MaterialShape.Cookie9Sided },
        { key: "flower", name: "Flower", shape: MaterialShape.Flower },
        { key: "sunny", name: "Sunny", shape: MaterialShape.Sunny },
        { key: "clover", name: "Clover", shape: MaterialShape.Clover8Leaf },
        { key: "puffy", name: "Puffy", shape: MaterialShape.Puffy },
        { key: "burst", name: "Burst", shape: MaterialShape.SoftBurst },
        { key: "heart", name: "Heart", shape: MaterialShape.Heart },
        { key: "circle", name: "Circle", shape: MaterialShape.Circle },
        { key: "fade", name: "Fade", shape: -1 },
        { key: "none", name: "None", shape: -1 }
    ]
    readonly property var transition: transitions.find(t => t.key === Settings.wallpaper.transition) ?? transitions[0]
    readonly property var shapes: transitions.filter(t => t.shape >= 0).map(t => t.shape)
    property int rolled: MaterialShape.Cookie9Sided
    readonly property int transitionShape: transition.key === "random" ? rolled : transition.shape >= 0 ? transition.shape : MaterialShape.Cookie9Sided

    function roll() {
        if (transition.key !== "random") return;
        let next = rolled;
        while (next === rolled) next = shapes[Math.floor(Math.random() * shapes.length)];
        rolled = next;
    }

    signal replayRequested()

    function replay() {
        roll();
        replayRequested();
    }

    function url(path) {
        return "file://" + path.split("/").map(encodeURIComponent).join("/");
    }

    function name(path) {
        return path.split("/").pop().replace(/\.[^.]+$/, "");
    }

    function set(path) {
        if (!path) return;
        roll();
        Settings.wallpaper.path = path;
        Scheme.apply();
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

    IpcHandler {
        target: "wallpaper"

        function set(path: string): void { root.set(path); }
        function replay(): void { root.replay(); }
    }
}
