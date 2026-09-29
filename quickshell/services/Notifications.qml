pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property int normalTimeout: 3000
    property int urgentTimeout: 5000

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

    function activate() {
        if (!current) return;
        const n = current;
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
