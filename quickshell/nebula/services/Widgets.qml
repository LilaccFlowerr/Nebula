pragma Singleton

import QtQuick
import Quickshell
import qs.theme

Singleton {
    id: root

    readonly property var types: ({
        nowplaying: { title: "Now playing", icon: "music_note", shape: "Cookie12Sided", size: 280, minSize: 120, maxSize: 480, color: "secondary" },
        image: { title: "Image", icon: "image", shape: "Clover4Leaf", size: 200, minSize: 80, maxSize: 600, color: "secondary" },
        text: { title: "Text", icon: "sticky_note_2", shape: "Sunny", size: 180, minSize: 80, maxSize: 600, color: "tertiary" }
    })

    readonly property var shapes: ["Circle", "Square", "Slanted", "Arch", "Oval", "Pill", "Diamond", "Pentagon", "Gem", "Sunny", "VerySunny", "Cookie4Sided", "Cookie6Sided", "Cookie7Sided", "Cookie9Sided", "Cookie12Sided", "Ghostish", "Clover4Leaf", "Clover8Leaf", "Burst", "SoftBurst", "Boom", "SoftBoom", "Flower", "Puffy", "PuffyDiamond", "PixelCircle", "Bun"]

    property string replacing: ""

    function label(w) {
        if (!w) return "";
        if (w.type === "image") return (w.source ?? "").split("/").pop() || "Image";
        if (w.type === "text") return w.source !== "" ? w.source : "Note";
        return types[w.type]?.title ?? w.type;
    }

    readonly property var colorRoles: ["primary", "secondary", "tertiary", "surface"]

    function palette(role) {
        switch (role) {
        case "primary": return { fill: Colors.primaryContainer, text: Colors.textOnPrimaryContainer };
        case "tertiary": return { fill: Colors.tertiaryContainer, text: Colors.textOnTertiaryContainer };
        case "surface": return { fill: Colors.surfaceContainerHigh, text: Colors.textOnSurface };
        default: return { fill: Colors.secondaryContainer, text: Colors.textOnSecondaryContainer };
        }
    }

    property string dragId: ""
    property string dragSource: ""
    property real dragX: 0
    property real dragY: 0

    function screenAt(x, y) {
        let best = Quickshell.screens[0];
        let bestDistance = Infinity;
        for (const s of Quickshell.screens) {
            const dx = Math.max(s.x - x, 0, x - (s.x + s.width));
            const dy = Math.max(s.y - y, 0, y - (s.y + s.height));
            const d = dx * dx + dy * dy;
            if (d < bestDistance) {
                bestDistance = d;
                best = s;
            }
        }
        return best;
    }

    function screenNamed(name) {
        return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
    }

    function spawn(size, screenName) {
        const screen = screenNamed(screenName);
        const shift = list.filter(w => w.type !== "nowplaying").length % 6 * 36;
        return {
            x: Math.max(0, Math.round((screen.width - size) / 2 + shift)),
            y: Math.max(0, Math.round((screen.height - size) / 2 + shift))
        };
    }

    property var list: []
    property var ids: []

    onListChanged: {
        const next = list.map(w => w.id);
        if (next.join(",") !== ids.join(",")) ids = next;
    }

    function parse(raw) {
        try {
            const data = JSON.parse(raw);
            return Array.isArray(data) ? data : [];
        } catch (e) {
            return [];
        }
    }

    function save(next) {
        list = next;
        Settings.widgets.items = JSON.stringify(next);
    }

    function get(id) {
        return list.find(w => w.id === id) ?? null;
    }

    function first(type) {
        return list.find(w => w.type === type) ?? null;
    }

    function add(type, props) {
        const t = types[type];
        if (!t) return "";
        const id = type + "-" + Date.now().toString(36);
        const screenName = props?.screen ?? (GlobalStates.screen !== "" ? GlobalStates.screen : Quickshell.screens[0].name);
        save(list.concat([Object.assign({
            id: id,
            type: type,
            enabled: true,
            shape: t.shape,
            size: t.size,
            color: t.color,
            opacity: 1,
            textScale: 1,
            screen: screenName,
            source: ""
        }, spawn(t.size, screenName), props ?? {})]));
        return id;
    }

    function update(id, props) {
        save(list.map(w => w.id === id ? Object.assign({}, w, props) : w));
    }

    function raise(id) {
        const mine = get(id)?.z ?? 0;
        const others = Math.max(0, ...list.filter(w => w.id !== id).map(w => w.z ?? 0));
        if (mine > others) return;
        update(id, { z: others + 1 });
    }

    function remove(id) {
        save(list.filter(w => w.id !== id));
    }

    function migrate() {
        const old = Settings.nowPlaying;
        save([{
            id: "nowplaying-1",
            type: "nowplaying",
            enabled: old.enabled,
            shape: types.nowplaying.shape,
            size: types.nowplaying.size,
            x: old.x,
            y: old.y,
            source: ""
        }]);
    }

    function sync() {
        if (!Settings.ready) return;
        if (Settings.widgets.items === "") migrate();
        else list = parse(Settings.widgets.items);
    }

    Connections {
        target: Settings
        function onReadyChanged() { root.sync(); }
    }

    Connections {
        target: Settings.widgets
        function onItemsChanged() {
            if (Settings.widgets.items !== JSON.stringify(root.list)) root.sync();
        }
    }

    Component.onCompleted: sync()
}
