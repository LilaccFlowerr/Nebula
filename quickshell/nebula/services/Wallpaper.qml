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
    readonly property string fallback: Quickshell.shellDir + "/assets/default.jpg"
    readonly property string current: Settings.wallpaper.path || fallback
    property var files: []
    readonly property var videoTypes: ["mp4", "webm", "mkv", "mov", "gif"]
    readonly property string posterDir: home + "/.cache/nebula/posters"
    readonly property string still: isVideo(current) ? poster(current) : current

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
        { key: "glitch", name: "Glitch", shape: -1 },
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

    function isVideo(path) {
        return videoTypes.includes(String(path).split(".").pop().toLowerCase());
    }

    function poster(path) {
        return posterDir + "/" + Qt.md5(path) + ".jpg";
    }

    function thumb(path) {
        return url(isVideo(path) ? poster(path) : path);
    }

    function makePosters(paths, done) {
        const videos = paths.filter(isVideo);
        if (videos.length === 0) {
            done();
            return;
        }
        const proc = posterProc.createObject(root, { done: done });
        proc.command = ["sh", "-c", `
            mkdir -p "$0"
            while [ $# -gt 0 ]; do
                [ -s "$2" ] || ffmpeg -v error -y -i "$1" -vf "thumbnail,scale=1920:-2" -frames:v 1 "$2" < /dev/null
                shift 2
            done`, posterDir].concat(...videos.map(v => [v, poster(v)]));
        proc.running = true;
    }

    function name(path) {
        return path.split("/").pop().replace(/\.[^.]+$/, "");
    }

    function set(path) {
        if (!path) return;
        roll();
        Settings.wallpaper.path = path;
        makePosters([path], () => Scheme.apply());
    }

    Component {
        id: posterProc

        Process {
            property var done
            onExited: {
                done();
                destroy();
            }
        }
    }

    FolderListModel {
        id: folder
        folder: "file://" + root.directory
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"].concat(root.videoTypes.map(t => "*." + t))
        caseSensitive: false
        showDirs: false
        sortField: FolderListModel.Name
        function update() {
            const paths = Array.from({ length: count }, (_, i) => get(i, "filePath"));
            root.makePosters(paths, () => root.files = paths);
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
