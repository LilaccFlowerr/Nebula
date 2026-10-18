pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int normalTimeout: Settings.notifications.normalTimeout
    readonly property int urgentTimeout: Settings.notifications.urgentTimeout

    property bool paused: false
    property real remaining: 0
    property real startedAt: 0

    property var queue: []
    property Notification current: null
    readonly property bool urgent: current !== null && current.urgency === NotificationUrgency.Critical

    function next() {
        const q = queue.filter(n => n && n.tracked);
        current = q.length > 0 ? q[0] : null;
        queue = q.slice(1);
        timer.stop();
        if (current) {
            remaining = urgent ? urgentTimeout : normalTimeout;
            if (!paused) startTimer();
        }
    }

    function startTimer() {
        startedAt = Date.now();
        timer.interval = Math.max(remaining, 1500);
        timer.restart();
    }

    onPausedChanged: {
        if (!current) return;
        if (paused) {
            timer.stop();
            remaining -= Date.now() - startedAt;
        } else {
            startTimer();
        }
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

    function activate() {
        if (!current) return;
        const n = current;
        focusSource(n);
        const action = n.actions.find(a => a.identifier === "default") ?? n.actions[0];
        if (action) action.invoke();
        if (current === n) dismiss();
    }

    function dismiss() {
        if (!current) return;
        const n = current;
        next();
        n.dismiss();
    }

    NotificationServer {
        keepOnReload: false
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            if (Dnd.enabled && n.urgency !== NotificationUrgency.Critical) return;
            root.queue = [...root.queue, n];
            if (!root.current) root.next();
        }
    }

    Connections {
        target: root.current
        function onClosed() { root.next(); }
    }

    Timer {
        id: timer
        onTriggered: {
            const n = root.current;
            root.next();
            if (n) n.expire();
        }
    }
}
