pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int normalTimeout: Settings.notifications.normalTimeout
    readonly property int urgentTimeout: Settings.notifications.urgentTimeout
    readonly property int tick: 250
    readonly property int leaveFallback: 1200
    readonly property int emptyGrace: 600

    property bool paused: false
    property var shown: []
    property var leaving: []
    property var groups: ({})
    property int revision: 0
    readonly property var current: shown.length > 0 ? shown[0] : null

    signal bumped(string key)

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
            image: n.image,
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
            g = { members: [], count: 0, data: null, remaining: 0, emptySince: 0, closing: null };
            groups[key] = g;
        }
        if (!g.members.includes(n)) {
            g.members.push(n);
            n.closed.connect(() => memberClosed(key, n));
        }
        g.count++;
        g.data = snapshot(n);
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
        close(key);
    }

    function dismiss(key = current) {
        close(key);
    }

    NotificationServer {
        keepOnReload: false
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            if (Dnd.enabled && n.urgency !== NotificationUrgency.Critical) return;
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
