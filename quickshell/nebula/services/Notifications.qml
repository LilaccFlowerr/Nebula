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

    property bool paused: false
    property var shown: []
    property var remaining: ({})
    property var leaving: []
    property var closing: ({})
    readonly property int leaveFallback: 1200
    readonly property var current: shown.length > 0 ? shown[0] : null

    function isUrgent(n) {
        return n !== null && n.urgency === NotificationUrgency.Critical;
    }

    function add(n) {
        remaining[n.id] = isUrgent(n) ? urgentTimeout : normalTimeout;
        if (shown.includes(n)) return;
        shown = [n, ...shown];
        n.closed.connect(() => remove(n));
    }

    function resetTimers() {
        for (const n of shown) {
            if (!leaving.includes(n)) remaining[n.id] = isUrgent(n) ? urgentTimeout : normalTimeout;
        }
    }

    onPausedChanged: if (!paused) resetTimers()

    function remove(n) {
        delete remaining[n.id];
        delete closing[n.id];
        shown = shown.filter(x => x !== n);
        leaving = leaving.filter(x => x !== n);
    }

    function close(n, expired = false) {
        if (!n || leaving.includes(n)) return;
        closing[n.id] = { expired: expired, at: Date.now() };
        leaving = [...leaving, n];
    }

    function finish(n) {
        if (!leaving.includes(n)) return;
        const expired = closing[n.id]?.expired ?? false;
        remove(n);
        if (expired) n.expire();
        else n.dismiss();
    }

    function focusSource(n) {
        const names = [n.desktopEntry, n.appName].filter(x => x).map(x => x.toLowerCase().replace(/\.desktop$/, ""));
        const window = Hyprland.toplevels.values.find(t => {
            const id = (t.wayland?.appId ?? "").toLowerCase();
            return id !== "" && names.some(x => x === id || x.endsWith("." + id) || id.endsWith("." + x));
        });
        if (!window) return;
        const address = String(window.address);
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address.startsWith("0x") ? address : "0x" + address}" })`);
    }

    function activate(n = current) {
        if (!n) return;
        focusSource(n);
        const action = n.actions.find(a => a.identifier === "default") ?? n.actions[0];
        if (action) action.invoke();
        dismiss(n);
    }

    function dismiss(n = current) {
        close(n);
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
            for (const n of [...root.leaving]) {
                if (now - root.closing[n.id].at > root.leaveFallback) root.finish(n);
            }
            if (root.paused) return;
            for (const n of root.shown) {
                if (root.leaving.includes(n)) continue;
                root.remaining[n.id] -= root.tick;
                if (root.remaining[n.id] <= 0) root.close(n, true);
            }
        }
    }
}
