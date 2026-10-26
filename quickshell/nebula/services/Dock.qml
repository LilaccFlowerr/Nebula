pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import M3Shapes

Singleton {
    id: root

    readonly property var pinned: parse(Settings.bar.dockPinned)
    readonly property var windows: Hyprland.toplevels.values

    readonly property var apps: {
        DesktopEntries.applications.values;
        const map = {};
        for (const id of pinned) map[id] = make(id, DesktopEntries.byId(id));
        for (const w of windows) {
            const appId = w.wayland?.appId ?? w.lastIpcObject?.class ?? "";
            if (appId === "") continue;
            const entry = DesktopEntries.heuristicLookup(appId);
            const key = entry?.id ?? appId;
            if (!map[key]) map[key] = make(key, entry, appId);
            map[key].windows.push(w);
            if (w.activated) map[key].active = true;
        }
        return map;
    }

    readonly property var shapes: [MaterialShape.Cookie4Sided, MaterialShape.Cookie6Sided, MaterialShape.Cookie7Sided, MaterialShape.Cookie9Sided, MaterialShape.Cookie12Sided]
    readonly property int launchTimeout: 15000

    property var launching: ({})

    readonly property var running: Settings.bar.dockRunning
        ? Object.keys(apps).filter(key => !pinned.includes(key) && apps[key].windows.length > 0)
        : []

    function make(key, entry, appId) {
        return {
            key: key,
            entry: entry ?? null,
            name: entry?.name ?? appId ?? key,
            icon: Quickshell.iconPath(entry?.icon ?? appId ?? key, true),
            windows: [],
            active: false
        };
    }

    function shapeFor(key) {
        let h = 0;
        for (let i = 0; i < key.length; i++) h = (h * 31 + key.charCodeAt(i)) | 0;
        return shapes[Math.abs(h) % shapes.length];
    }

    function isLaunching(key) {
        return launching[key] !== undefined;
    }

    function setLaunching(key, on) {
        const next = Object.assign({}, launching);
        if (on) next[key] = { count: app(key)?.windows.length ?? 0, at: Date.now() };
        else delete next[key];
        launching = next;
    }

    onAppsChanged: {
        for (const key of Object.keys(launching)) {
            if ((apps[key]?.windows.length ?? 0) > launching[key].count) setLaunching(key, false);
        }
    }

    Timer {
        running: Object.keys(root.launching).length > 0
        interval: 1000
        repeat: true
        onTriggered: {
            for (const key of Object.keys(root.launching)) {
                if (Date.now() - root.launching[key].at > root.launchTimeout) root.setLaunching(key, false);
            }
        }
    }

    function parse(raw) {
        try {
            const data = JSON.parse(raw);
            return Array.isArray(data) ? data.filter(id => typeof id === "string") : [];
        } catch (e) {
            return [];
        }
    }

    function app(key) {
        return apps[key] ?? null;
    }

    function isPinned(key) {
        return pinned.includes(key);
    }

    function pin(key) {
        if (isPinned(key)) return;
        Settings.bar.dockPinned = JSON.stringify(pinned.concat([key]));
    }

    function unpin(key) {
        Settings.bar.dockPinned = JSON.stringify(pinned.filter(id => id !== key));
    }

    function togglePin(key) {
        if (isPinned(key)) unpin(key);
        else pin(key);
    }

    function focusWindow(w) {
        const address = String(w.address);
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address.startsWith("0x") ? address : "0x" + address}" })`);
    }

    function launch(key) {
        const a = app(key);
        if (!a?.entry) return;
        setLaunching(key, true);
        a.entry.execute();
    }

    function focus(w) {
        focusWindow(w);
    }

    function closeWindow(w) {
        w?.wayland?.close();
    }

    function killWindow(w) {
        const pid = w?.lastIpcObject?.pid;
        if (pid > 0) Quickshell.execDetached(["kill", "-9", String(pid)]);
    }

    function closeAll(key) {
        for (const w of app(key)?.windows ?? []) closeWindow(w);
    }

    function refresh() {
        Hyprland.refreshToplevels();
    }

    function activate(key) {
        const a = app(key);
        if (!a) return;
        if (a.windows.length === 0) {
            launch(key);
            return;
        }
        const current = a.windows.findIndex(w => w.activated);
        focusWindow(a.windows[(current + 1) % a.windows.length]);
    }
}
