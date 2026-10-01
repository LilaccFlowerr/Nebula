pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/Videos/Recordings"
    readonly property bool sound: Settings.recorder.sound
    readonly property bool useRegion: Settings.recorder.useRegion
    readonly property int framerate: Settings.recorder.framerate

    property bool external: false
    readonly property bool recording: proc.running || external
    property bool paused: false
    property int elapsed: 0
    property string file: ""
    property string lastFile: ""

    property var recent: []

    function refreshRecent() {
        recentProc.running = false;
        recentProc.running = true;
    }

    function deleteFile(path) {
        Quickshell.execDetached(["rm", "-f", "--", path]);
        if (path === lastFile) lastFile = "";
        recent = recent.filter(r => r.path !== path);
        refreshTimer.restart();
    }

    function openFile(path) {
        Qt.openUrlExternally("file://" + path);
    }

    readonly property string elapsedText: Math.floor(elapsed / 60) + ":" + String(elapsed % 60).padStart(2, "0")

    signal saved(string path)
    signal failed()

    function start(region) {
        if (recording) return;
        const stamp = new Date().toLocaleString(Qt.locale("en_US"), "yyyyMMdd_HH-mm-ss");
        file = directory + "/recording_" + stamp + ".mp4";
        const monitor = Hyprland.focusedMonitor?.name ?? "screen";
        const args = region ? ["-w", "region", "-region", region] : ["-w", monitor];
        args.push("-f", String(framerate));
        if (sound) args.push("-a", "default_output");
        elapsed = 0;
        paused = false;
        proc.command = ["sh", "-c",
            "dir=$1; out=$2; shift 2; mkdir -p \"$dir\" && flatpak run --command=gpu-screen-recorder com.dec05eba.gpu_screen_recorder \"$@\" -o \"$out\"; test -s \"$out\"",
            "sh", directory, file, ...args];
        proc.running = true;
    }

    function startRegion() {
        if (recording) return;
        Quickshell.execDetached(["sh", "-c",
            "r=$(slurp -b '#00000066' -c '#ffffffff' -w 2 -f '%wx%h+%x+%y') && qs -c nebula ipc call recorder startRegion \"$r\""]);
    }

    function stop() {
        if (!recording) return;
        Quickshell.execDetached(["pkill", "-INT", "-x", "gpu-screen-reco"]);
        if (external) externalCheck.running = true;
    }

    function togglePause() {
        if (!recording) return;
        Quickshell.execDetached(["pkill", "-USR2", "-x", "gpu-screen-reco"]);
        paused = !paused;
    }

    function toggle() {
        if (recording) stop();
        else start("");
    }

    function record() {
        if (recording) stop();
        else if (useRegion) startRegion();
        else start("");
    }

    function watch() {
        if (lastFile) Qt.openUrlExternally("file://" + lastFile);
    }

    function openFolder() {
        Quickshell.execDetached(["dbus-send", "--session", "--dest=org.freedesktop.FileManager1", "--type=method_call",
            "/org/freedesktop/FileManager1", "org.freedesktop.FileManager1.ShowItems",
            "array:string:file://" + (lastFile || directory), "string:"]);
    }

    function deleteLast() {
        if (lastFile) deleteFile(lastFile);
    }

    Process {
        id: proc
        stderr: SplitParser {
            onRead: line => console.warn("recorder:", line)
        }
        onExited: code => {
            root.paused = false;
            if (code === 0) {
                root.lastFile = root.file;
                Quickshell.execDetached(["sh", "-c", "printf 'file://%s\\n' \"$1\" | wl-copy --type text/uri-list", "sh", root.file]);
                root.saved(root.file);
                root.refreshRecent();
            } else {
                root.failed();
            }
            root.file = "";
        }
    }

    Process {
        id: recentProc
        running: true
        command: ["sh", "-c", `
            dir=$1; current=$2; n=0
            for f in $(ls -t "$dir"/*.mp4 2>/dev/null); do
                [ "$n" -ge 3 ] && break
                [ "$f" = "$current" ] && continue
                d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null)
                [ -n "$d" ] || continue
                m=$(stat -c %Y "$f")
                printf '%s\t%s\t%s\n' "$f" "$d" "$m"
                n=$((n + 1))
            done`, "sh", root.directory, root.file]
        stdout: StdioCollector {
            onStreamFinished: root.recent = text.trim().split("\n").filter(l => l !== "").map(l => {
                const [path, duration, mtime] = l.split("\t");
                const secs = Math.round(parseFloat(duration) || 0);
                return {
                    path: path,
                    duration: Math.floor(secs / 60) + ":" + String(secs % 60).padStart(2, "0"),
                    date: new Date(parseInt(mtime) * 1000).toLocaleString(Qt.locale("en_US"), "MMM d, h:mm AP")
                };
            })
        }
    }

    Timer {
        id: refreshTimer
        interval: 300
        onTriggered: root.refreshRecent()
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.recording && !root.paused
        onTriggered: root.elapsed++
    }

    IpcHandler {
        target: "recorder"

        function toggle(): void { root.toggle(); }
        function region(): void { root.recording ? root.stop() : root.startRegion(); }
        function pause(): void { root.togglePause(); }
        function startRegion(region: string): void { root.start(region); }
    }
}
