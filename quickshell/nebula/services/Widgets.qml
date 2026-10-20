pragma Singleton

import QtQuick
import Quickshell
import qs.theme

Singleton {
    id: root

    readonly property var types: ({
        nowplaying: { title: "Now playing", description: "Album art and controls", single: true, icon: "music_note", shape: "Cookie12Sided", size: 280, minSize: 120, maxSize: 480, color: "secondary" },
        image: { title: "Image", description: "Any picture, in a shape", picker: true, icon: "image", shape: "Clover4Leaf", size: 200, minSize: 80, maxSize: 600, color: "secondary" },
        clock: { title: "Clock", description: "An analog clock in a shape", icon: "schedule", shape: "Cookie12Sided", size: 220, minSize: 100, maxSize: 600, color: "primary" },
        calendar: { title: "Calendar", description: "Today, tap to open the month", icon: "calendar_month", shape: "Cookie9Sided", size: 200, minSize: 140, maxSize: 420, color: "tertiary" },
        text: { title: "Text", description: "A note on your desktop", icon: "sticky_note_2", shape: "Sunny", size: 180, minSize: 80, maxSize: 600, color: "tertiary" }
    })

    readonly property var shapes: ["Circle", "Square", "Slanted", "Arch", "Oval", "Pill", "Diamond", "Pentagon", "Gem", "Sunny", "VerySunny", "Cookie4Sided", "Cookie6Sided", "Cookie7Sided", "Cookie9Sided", "Cookie12Sided", "Ghostish", "Clover4Leaf", "Clover8Leaf", "Burst", "SoftBurst", "Boom", "SoftBoom", "Flower", "Puffy", "PuffyDiamond", "PixelCircle", "Bun"]

    property string replacing: ""

    function label(w) {
        if (!w) return "";
        if (w.type === "image") return (w.source ?? "").split("/").pop() || "Image";
        if (w.type === "text") return w.source !== "" ? w.source : "Note";
        return types[w.type]?.title ?? w.type ?? "";
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

    property string menuId: ""
    property string menuScreen: ""
    property real menuX: 0
    property real menuY: 0
    property real menuW: 0
    property real menuH: 0

    function openMenu(id, screenName, rect) {
        menuScreen = screenName;
        menuX = rect.x;
        menuY = rect.y;
        menuW = rect.width;
        menuH = rect.height;
        menuId = id;
    }

    function closeMenu() {
        menuId = "";
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

    function available() {
        return Object.keys(types)
            .filter(key => !types[key].single || first(key) === null)
            .map(key => Object.assign({ key: key }, types[key]));
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

    ListModel {
        id: idModel
    }

    readonly property alias idModel: idModel

    function hasRow(id) {
        for (let i = 0; i < idModel.count; i++) if (idModel.get(i).modelData === id) return true;
        return false;
    }

    onListChanged: {
        const next = list.map(w => w.id);
        for (let i = idModel.count - 1; i >= 0; i--) {
            if (!next.includes(idModel.get(i).modelData)) idModel.remove(i);
        }
        for (const id of next) {
            if (!hasRow(id)) idModel.append({ modelData: id });
        }
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

    property bool pending: false
    property double holdUntil: 0

    function save(next) {
        list = next;
        pending = true;
        saveTimer.restart();
    }

    Timer {
        id: saveTimer
        interval: 250
        onTriggered: {
            root.holdUntil = Date.now() + 1000;
            Settings.widgets.items = JSON.stringify(root.list);
            root.pending = false;
        }
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
        save(list.map(w => {
            if (w.id !== id) return w;
            const next = Object.assign({}, w, props);
            const grows = props.size !== undefined && w.size !== undefined && props.x === undefined && props.y === undefined;
            if (grows && (w.x ?? -1) >= 0 && (w.y ?? -1) >= 0) {
                const shift = (props.size - w.size) / 2;
                next.x = Math.max(0, Math.round(w.x - shift));
                next.y = Math.max(0, Math.round(w.y - shift));
            }
            return next;
        }));
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
            if (root.pending || Date.now() < root.holdUntil) return;
            if (Settings.widgets.items !== JSON.stringify(root.list)) root.sync();
        }
    }

    Component.onCompleted: sync()
}
