pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/.local/state/nebula"
    readonly property int appSlots: 8
    readonly property int commandSlots: 7
    readonly property int recentLimit: 20

    property string query: ""
    property string picker: ""
    readonly property bool wallpaperMode: picker === "wallpaper"
    readonly property bool themeMode: picker === "theme"
    readonly property bool commandMode: picker === "" && query.startsWith(">")
    readonly property string search: (commandMode ? query.slice(1) : query).trim().toLowerCase()
    readonly property int slots: commandMode ? commandSlots : appSlots

    readonly property var apps: DesktopEntries.applications.values
        .filter(e => !e.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    readonly property var commands: [
        { name: "Theme", icon: "palette", keepOpen: true, run: () => root.enterThemes() },
        { name: "Settings", icon: "settings", run: () => GlobalStates.toggleSettings() },
        { name: "Lock", icon: "lock", run: () => Power.lock() },
        { name: "Sleep", icon: "bedtime", run: () => Power.suspend() },
        { name: "Restart", icon: "restart_alt", run: () => Power.reboot() },
        { name: "Shutdown", icon: "power_settings_new", run: () => Power.shutdown() },
        { name: "Log out", icon: "logout", run: () => Power.logout() },
        { name: "Record", icon: "screen_record", run: () => Recorder.record() },
        { name: "Wallpaper", icon: "wallpaper", keepOpen: true, run: () => root.enterWallpapers() },
        { name: Scheme.dark ? "Light mode" : "Dark mode", icon: Scheme.dark ? "light_mode" : "dark_mode", run: () => Scheme.toggleMode() }
    ]

    readonly property var wallpapers: Wallpaper.files.map(path => ({ name: Wallpaper.name(path), path: path }))

    signal clearRequested()

    function enterWallpapers() {
        picker = "wallpaper";
        clearRequested();
    }

    function enterThemes() {
        picker = "theme";
        Scheme.loadPreviews();
        clearRequested();
    }

    readonly property var results: {
        if (wallpaperMode)
            return rank(wallpapers, w => [w.name]);
        if (themeMode)
            return rank(Scheme.schemes, s => [s.name]).slice(0, appSlots);
        if (commandMode)
            return rank(commands, c => [c.name]).slice(0, slots);
        if (search === "") {
            const recent = adapter.recent.map(id => apps.find(e => e.id === id)).filter(e => e);
            const rest = apps.filter(e => !recent.includes(e));
            return recent.concat(rest).slice(0, slots);
        }
        return rank(apps, e => [e.name, e.genericName, ...e.keywords]).slice(0, slots);
    }

    function score(text) {
        const t = (text ?? "").toLowerCase();
        if (t === "" || search === "") return search === "" ? 1 : 0;
        if (t.startsWith(search)) return 4;
        if (t.split(/[\s\-_]/).some(w => w.startsWith(search))) return 3;
        if (t.includes(search)) return 2;
        return 0;
    }

    function rank(items, fields) {
        return items
            .map((item, i) => ({ item, i, s: Math.max(...fields(item).map(f => score(f))) }))
            .filter(r => r.s > 0)
            .sort((a, b) => b.s - a.s || a.i - b.i)
            .map(r => r.item);
    }

    function clearRecent() {
        adapter.recent = [];
    }

    function open() {
        query = "";
        picker = "";
        if (!GlobalStates.launcherOpen) GlobalStates.toggleLauncher();
    }

    function close() {
        GlobalStates.launcherOpen = false;
    }

    function toggle() {
        GlobalStates.launcherOpen ? close() : open();
    }

    function activate(item) {
        if (!item) return;
        if (wallpaperMode) {
            close();
            Wallpaper.set(item.path);
            return;
        }
        if (themeMode) {
            close();
            Scheme.set(item.scheme);
            return;
        }
        if (commandMode) {
            if (!item.keepOpen) close();
            item.run();
            return;
        }
        close();
        item.execute();
        adapter.recent = [item.id, ...adapter.recent.filter(id => id !== item.id)].slice(0, recentLimit);
    }

    Process {
        running: true
        command: ["mkdir", "-p", root.directory]
    }

    FileView {
        path: root.directory + "/launcher.json"
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property var recent: []
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { root.close(); }
        function onFocusedMonitorChanged() { root.close(); }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.toggle(); }
        function open(): void { root.open(); }
        function close(): void { root.close(); }
    }
}
