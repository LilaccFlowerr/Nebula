pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int normalTimeout: Settings.notifications.normalTimeout
    readonly property int urgentTimeout: Settings.notifications.urgentTimeout
    readonly property int tick: 250
    readonly property int leaveFallback: 1200
    readonly property int emptyGrace: 600
    readonly property int maxMissed: 60

    property bool paused: false
    property var shown: []
    property var leaving: []
    property var groups: ({})
    property int revision: 0
    readonly property var current: shown.length > 0 ? shown[0] : null
    property var missed: []
    property int nextMissedId: 0
    property var uncached: []
    property bool missedLoaded: false
    readonly property string directory: Quickshell.env("HOME") + "/.local/state/nebula"
    readonly property var missedApps: {
        const apps = [];
        for (const entry of missed) {
            let app = apps.find(a => a.name === entry.data.appName);
            if (!app) {
                app = { name: entry.data.appName, data: entry.data, items: [], count: 0 };
                apps.push(app);
            }
            app.items.push(entry);
            app.count += entry.count;
        }
        return apps;
    }
    readonly property int missedCount: missed.reduce((sum, entry) => sum + entry.count, 0)

    signal bumped(string key)

    onMissedChanged: if (missedLoaded) saveTimer.restart()

    function keyOf(n) {
        return n.appName + "\u0001" + n.summary;
    }

    function group(key) {
        revision;
        return groups[key] ?? null;
    }

    function live(key) {
        revision;
        const g = groups[key];
        return g && g.members.length > 0 ? g.members[g.members.length - 1] : null;
    }

    function isUrgent(data) {
        return !!data && data.urgency === NotificationUrgency.Critical;
    }

    function timeoutFor(g) {
        return isUrgent(g.data) ? urgentTimeout : normalTimeout;
    }

    function snapshot(n) {
        return {
            appName: n.appName,
            appIcon: n.appIcon,
            image: n.image || (n.appIcon.startsWith("/") ? "file://" + n.appIcon : n.appIcon.startsWith("file://") ? n.appIcon : ""),
            summary: n.summary,
            body: n.body,
            urgency: n.urgency,
            desktopEntry: n.desktopEntry
        };
    }

    function add(n) {
        const key = keyOf(n);
        let g = groups[key];
        if (!g) {
            g = { members: [], count: 0, data: null, entries: [], remaining: 0, emptySince: 0, closing: null };
            groups[key] = g;
        }
        if (!g.members.includes(n)) {
            g.members.push(n);
            n.closed.connect(() => memberClosed(key, n));
        }
        g.count++;
        g.data = snapshot(n);
        g.entries.push(remember(g.data, 1));
        g.remaining = timeoutFor(g);
        g.emptySince = 0;
        g.closing = null;

        const wasShown = shown.includes(key);
        leaving = leaving.filter(k => k !== key);
        shown = [key, ...shown.filter(k => k !== key)];
        revision++;
        if (wasShown) bumped(key);
    }

    function memberClosed(key, n) {
        const g = groups[key];
        if (!g) return;
        g.members = g.members.filter(x => x !== n);
        if (g.members.length === 0) g.emptySince = Date.now();
        revision++;
    }

    function iconFor(data) {
        const entry = DesktopEntries.heuristicLookup(data.desktopEntry || data.appName);
        return Quickshell.iconPath(data.appIcon || entry?.icon || "", true);
    }

    function needsCache(image) {
        return image !== "" && !image.startsWith("image://icon/") && !image.includes(Quickshell.cacheDir);
    }

    function remember(data, count) {
        if (needsCache(data.image) && !uncached.includes(data.image)) uncached = [...uncached, data.image];
        const entry = { id: nextMissedId++, data: data, count: count, time: Date.now() };
        missed = [entry, ...missed].slice(0, maxMissed);
        return entry;
    }

    function seen(key) {
        const g = groups[key];
        if (g) missed = missed.filter(m => !g.entries.some(e => e.id === m.id));
    }

    function cacheImage(original, url) {
        uncached = uncached.filter(image => image !== original);
        if (url === "") return;
        for (const m of missed) {
            if (m.data.image === original) m.data.image = url;
        }
        missed = missed.slice();
    }

    function forget(entry) {
        missed = missed.filter(m => m.id !== entry.id);
    }

    function forgetApp(name) {
        missed = missed.filter(m => m.data.appName !== name);
    }

    function clearMissed() {
        missed = [];
    }

    function openMissed(entry) {
        focusSource(entry.data);
        forget(entry);
    }

    function resetTimers() {
        for (const key of shown) {
            const g = groups[key];
            if (g && !leaving.includes(key)) g.remaining = timeoutFor(g);
        }
    }

    onPausedChanged: if (!paused) resetTimers()

    function close(key, expired = false) {
        const g = groups[key];
        if (!g || leaving.includes(key)) return;
        g.closing = { expired: expired, at: Date.now() };
        leaving = [...leaving, key];
    }

    function finish(key) {
        if (!leaving.includes(key)) return;
        const g = groups[key];
        delete groups[key];
        shown = shown.filter(k => k !== key);
        leaving = leaving.filter(k => k !== key);
        revision++;
        if (!g) return;
        for (const n of g.members) {
            if (g.closing?.expired) n.expire();
            else n.dismiss();
        }
    }

    function focusSource(data) {
        const names = [data.desktopEntry, data.appName].filter(x => x).map(x => x.toLowerCase().replace(/\.desktop$/, ""));
        const window = Hyprland.toplevels.values.find(t => {
            const id = (t.wayland?.appId ?? "").toLowerCase();
            return id !== "" && names.some(x => x === id || x.endsWith("." + id) || id.endsWith("." + x));
        });
        if (!window) return;
        const address = String(window.address);
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address.startsWith("0x") ? address : "0x" + address}" })`);
    }

    function activate(key = current) {
        const g = groups[key];
        if (!g) return;
        focusSource(g.data);
        const n = live(key);
        const action = n ? (n.actions.find(a => a.identifier === "default") ?? n.actions[0]) : null;
        if (action) action.invoke();
        seen(key);
        close(key);
    }

    function dismiss(key = current) {
        seen(key);
        close(key);
    }

    function keepable(image) {
        return image === "" || image.startsWith("image://icon/") || image.startsWith("file://");
    }

    Timer {
        id: saveTimer
        interval: 1000
        onTriggered: storage.setText(JSON.stringify(root.missed.map(m => ({
            count: m.count,
            time: m.time,
            data: Object.assign({}, m.data, { image: root.keepable(m.data.image) ? m.data.image : "" })
        }))))
    }

    Process {
        id: createStorage
        command: ["sh", "-c", "mkdir -p \"$1\" && printf '[]' > \"$1/missed.json\"", "sh", root.directory]
    }

    FileView {
        id: storage
        path: root.directory + "/missed.json"
        printErrors: false
        onLoaded: {
            if (root.missedLoaded) return;
            let saved = [];
            try {
                saved = JSON.parse(text());
            } catch (e) {}
            const restored = saved.map(m => ({ id: root.nextMissedId++, count: m.count, time: m.time, data: m.data }));
            root.missed = [...root.missed, ...restored].slice(0, root.maxMissed);
            root.missedLoaded = true;
        }
        onLoadFailed: error => {
            root.missedLoaded = true;
            if (error === FileViewError.FileNotFound) createStorage.running = true;
        }
    }

    NotificationServer {
        keepOnReload: false
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            if (Dnd.enabled && n.urgency !== NotificationUrgency.Critical) {
                root.remember(root.snapshot(n), 1);
                return;
            }
            root.add(n);
        }
    }

    Timer {
        interval: root.tick
        repeat: true
        running: root.shown.length > 0
        onTriggered: {
            const now = Date.now();
            for (const key of [...root.shown]) {
                const g = root.groups[key];
                if (!g) {
                    root.shown = root.shown.filter(k => k !== key);
                    root.leaving = root.leaving.filter(k => k !== key);
                    continue;
                }
                if (root.leaving.includes(key)) {
                    if (now - g.closing.at > root.leaveFallback) root.finish(key);
                    continue;
                }
                if (g.emptySince > 0 && now - g.emptySince > root.emptyGrace) {
                    root.close(key);
                    continue;
                }
                if (root.paused) continue;
                g.remaining -= root.tick;
                if (g.remaining <= 0) root.close(key, true);
            }
        }
    }
}
