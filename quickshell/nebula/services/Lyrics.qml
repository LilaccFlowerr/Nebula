pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var lines: []
    property string plain: ""
    property string status: "none"

    readonly property bool synced: status === "synced"
    readonly property bool wanted: Settings.bar.lyrics || Lock.wanted || Widgets.list.some(w => w.type === "lyrics" && w.enabled === true)
    function clock() {
        return Media.playing && syncedAt > 0 ? basePosition + (Date.now() - syncedAt) / 1000 : position;
    }

    function timing(all, index) {
        const line = all[index];
        if (!line || line.text === "") return [];
        const parts = line.text.split(/\s+/).filter(part => part !== "");
        if (parts.length === 0) return [];
        const until = all[index + 1]?.time ?? line.time + 5;
        const gap = Math.max(0.4, until - line.time);
        const weights = parts.map(part => part.replace(/[^\p{L}\p{N}]/gu, "").length + 1.5);
        const total = weights.reduce((sum, weight) => sum + weight, 0);
        const span = Math.min(gap * 0.97, Math.max(total * 0.09, Math.min(gap * 0.9, total * 0.2)));
        let passed = 0;
        return parts.map((part, i) => {
            const start = line.time + span * passed / total;
            passed += weights[i];
            return { text: part, start: start, end: line.time + span * passed / total };
        });
    }
    readonly property string key: Media.artist + "|" + Media.title

    property real position: 0
    property real syncedAt: 0
    property real basePosition: 0

    readonly property int currentIndex: {
        let index = -1;
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].time <= position) index = i;
            else break;
        }
        return index;
    }
    readonly property string currentLine: currentIndex >= 0 ? lines[currentIndex].text : ""

    property var cache: ({})
    property int request: 0

    onKeyChanged: fetchTimer.restart()

    onWantedChanged: fetchTimer.restart()

    Timer {
        id: fetchTimer
        interval: 300
        onTriggered: root.fetch()
    }

    Connections {
        target: Media
        function onPositionChanged() {
            root.basePosition = Media.position;
            root.syncedAt = Date.now();
            root.position = Media.position;
        }
    }

    Timer {
        interval: 100
        repeat: true
        running: root.synced && Media.playing
        onTriggered: root.position = root.basePosition + (Date.now() - root.syncedAt) / 1000
    }

    function fetch() {
        lines = [];
        plain = "";
        if (!Media.active || !wanted) {
            status = "none";
            return;
        }
        const k = key;
        if (cache[k]) {
            apply(cache[k]);
            return;
        }
        status = "loading";
        const id = ++request;
        const params = "artist_name=" + encodeURIComponent(Media.artist)
            + "&track_name=" + encodeURIComponent(Media.title)
            + (Media.length > 0 ? "&duration=" + Math.round(Media.length) : "");
        get("https://lrclib.net/api/get?" + params, (ok, data) => {
            if (id !== request) return;
            if (ok && data) {
                store(k, data);
                return;
            }
            const q = "artist_name=" + encodeURIComponent(Media.artist) + "&track_name=" + encodeURIComponent(Media.title);
            get("https://lrclib.net/api/search?" + q, (ok2, results, failed) => {
                if (id !== request) return;
                if (failed) {
                    root.status = "none";
                    return;
                }
                const best = ok2 && Array.isArray(results)
                    ? (results.find(r => r.syncedLyrics) ?? results.find(r => r.plainLyrics) ?? null)
                    : null;
                store(k, best);
            });
        });
    }

    function get(url, callback) {
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            let data = null;
            try { data = JSON.parse(xhr.responseText); } catch (e) {}
            callback(xhr.status === 200, data, xhr.status === 0);
        };
        xhr.open("GET", url);
        xhr.setRequestHeader("User-Agent", "Nebula (https://github.com/LilaccFlowerr/Nebula)");
        xhr.send();
    }

    function store(k, data) {
        const entry = !data ? { status: "none" }
            : data.instrumental ? { status: "instrumental" }
            : data.syncedLyrics ? { status: "synced", lines: parse(data.syncedLyrics) }
            : data.plainLyrics ? { status: "plain", plain: data.plainLyrics }
            : { status: "none" };
        cache[k] = entry;
        apply(entry);
    }

    function apply(entry) {
        lines = entry.lines ?? [];
        plain = entry.plain ?? "";
        status = entry.status;
    }

    function parse(lrc) {
        const result = [];
        for (const raw of lrc.split("\n")) {
            const match = raw.match(/^\[(\d+):(\d+(?:\.\d+)?)\](.*)$/);
            if (!match) continue;
            result.push({ time: parseInt(match[1]) * 60 + parseFloat(match[2]), text: match[3].trim() });
        }
        result.sort((a, b) => a.time - b.time);
        if (result.length > 0 && result[0].time > 1) result.unshift({ time: 0, text: "" });
        return result;
    }

    function seekToLine(index) {
        if (index < 0 || index >= lines.length || Media.length <= 0) return;
        Media.seekTo(lines[index].time / Media.length);
    }
}
