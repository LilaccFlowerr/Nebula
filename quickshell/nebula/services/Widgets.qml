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
        battery: { title: "Battery", description: "Fills like water as you charge", icon: "battery_full", shape: "Cookie12Sided", size: 200, minSize: 120, maxSize: 480, color: "secondary" },
        weather: { title: "Weather", description: "Today's weather, in its own shape", icon: "partly_cloudy_day", shape: "Cookie9Sided", size: 220, minSize: 140, maxSize: 480, color: "primary" },
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
    property bool menuExpanded: false

    function openMenu(id, screenName, rect, expanded) {
        menuExpanded = expanded === true;
        menuScreen = screenName;
        menuX = rect.x;
        menuY = rect.y;
        menuW = rect.width;
        menuH = rect.height;
        menuId = id;
    }

    function closeMenu() {
        menuId = "";
        menuExpanded = false;
    }

    function rectOf(id) {
        const w = get(id);
        if (!w) return Qt.rect(0, 0, 0, 0);
        const s = screenNamed(w.screen ?? "");
        const size = w.size ?? types[w.type]?.size ?? 200;
        const p = position(w, s);
        const x = p.x < 0 ? Theme.nowPlaying.margin : p.x;
        const y = p.y < 0 ? s.height - size - Theme.nowPlaying.margin : p.y;
        return Qt.rect(s.x + x, s.y + y, size, size);
    }

    function present(name) {
        return Quickshell.screens.some(s => s.name === name);
    }

    function shownOn(w, screenName) {
        if (!w.screen) return true;
        if (present(w.screen)) return w.screen === screenName;
        return Quickshell.screens[0]?.name === screenName;
    }

    function sizeOf(name) {
        const live = Quickshell.screens.find(s => s.name === name);
        if (live) return { width: live.width, height: live.height };
        const m = HyprConfig.monitors.find(m => m.name === name);
        if (!m) return null;
        const [width, height] = m.mode.split("@")[0].split("x").map(Number);
        const scale = m.scale || 1;
        return { width: width / scale, height: height / scale };
    }

    function position(w, target) {
        const x = w.x ?? -1;
        const y = w.y ?? -1;
        const from = !w.screen || present(w.screen) ? null : sizeOf(w.screen);
        if (!from || !target) return { x: x, y: y };
        const half = (w.size ?? types[w.type]?.size ?? 200) / 2;
        return {
            x: x < 0 ? x : Math.max(0, (x + half) * target.width / from.width - half),
            y: y < 0 ? y : Math.max(0, (y + half) * target.height / from.height - half)
        };
    }

    function edit(id) {
        const w = get(id);
        if (!w) return;
        openMenu(id, screenNamed(w.screen ?? "").name, rectOf(id), true);
    }

    property bool pickerOpen: false
    property string pickerTarget: ""
    property string pickerScreen: ""

    function openPicker(target, screenName) {
        closeMenu();
        pickerTarget = target ?? "";
        pickerScreen = screenName || (GlobalStates.screen !== "" ? GlobalStates.screen : Quickshell.screens[0].name);
        pickerOpen = true;
    }

    function closePicker() {
        pickerOpen = false;
    }

    function pickImage(path) {
        if (pickerTarget !== "" && get(pickerTarget)) update(pickerTarget, { source: path, zoom: 1, panX: 0, panY: 0 });
        else add("image", { source: path, screen: pickerScreen });
        closePicker();
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

    property var presets: []
    property string activePreset: ""
    readonly property bool modified: activePreset !== "" && differs(list.filter(w => !leaving.includes(w.id)), presetNamed(activePreset))

    signal gliding()

    function parsePresets(raw) {
        try {
            const data = JSON.parse(raw);
            return Array.isArray(data) ? data : [];
        } catch (e) {
            return [];
        }
    }

    property bool writingPresets: false

    function savePresets(next, active) {
        presets = next;
        if (active !== undefined) activePreset = active;
        writingPresets = true;
        Settings.widgets.presets = JSON.stringify(next);
        Settings.widgets.preset = activePreset;
        writingPresets = false;
    }

    function syncPresets() {
        if (writingPresets) return;
        presets = parsePresets(Settings.widgets.presets);
        activePreset = Settings.widgets.preset;
    }

    function presetNamed(name) {
        return presets.find(p => p.name === name) ?? null;
    }

    function freeName() {
        let n = presets.length + 1;
        while (presetNamed("Preset " + n)) n++;
        return "Preset " + n;
    }

    function screenSize(name) {
        return sizeOf(name ?? "") ?? screenNamed(name ?? "");
    }

    function snapshot(w) {
        const s = screenSize(w.screen);
        const half = (w.size ?? types[w.type]?.size ?? 200) / 2;
        const item = Object.assign({}, w);
        delete item.x;
        delete item.y;
        delete item.z;
        item.fx = (w.x ?? -1) < 0 ? -1 : (w.x + half) / s.width;
        item.fy = (w.y ?? -1) < 0 ? -1 : (w.y + half) / s.height;
        return item;
    }

    function restore(item) {
        const s = screenSize(item.screen);
        const half = (item.size ?? types[item.type]?.size ?? 200) / 2;
        const w = Object.assign({}, item);
        delete w.fx;
        delete w.fy;
        w.x = item.fx < 0 ? -1 : Math.max(0, Math.round(item.fx * s.width - half));
        w.y = item.fy < 0 ? -1 : Math.max(0, Math.round(item.fy * s.height - half));
        return w;
    }

    function savePreset(name) {
        const entry = { name: name, items: list.filter(w => !leaving.includes(w.id)).map(snapshot) };
        const exists = presetNamed(name) !== null;
        savePresets(exists ? presets.map(p => p.name === name ? entry : p) : presets.concat([entry]), name);
    }

    function loadPreset(name) {
        const p = presetNamed(name);
        if (!p) return;
        const next = p.items.map(restore);
        const nextIds = next.map(w => w.id);
        const gone = list.filter(w => !nextIds.includes(w.id));
        const fresh = nextIds.filter(id => get(id) === null);
        gliding();
        save(next.concat(gone));
        savePresets(presets, name);
        for (const w of gone) remove(w.id);
        for (const id of fresh) added(id);
    }

    function updatePreset(name) {
        savePreset(name);
    }

    function renamePreset(from, to) {
        const name = to.trim();
        if (name === "" || name === from || presetNamed(name)) return;
        savePresets(presets.map(p => p.name === from ? Object.assign({}, p, { name: name }) : p), activePreset === from ? name : undefined);
    }

    function deletePreset(name) {
        savePresets(presets.filter(p => p.name !== name), activePreset === name ? "" : undefined);
    }

    function differs(current, preset) {
        if (!preset) return false;
        if (current.length !== preset.items.length) return true;
        return current.map(snapshot).some(a => {
            const b = preset.items.find(i => i.id === a.id);
            if (!b) return true;
            const keys = new Set(Object.keys(a).concat(Object.keys(b)));
            for (const key of keys) {
                if (key === "fx" || key === "fy") {
                    if (Math.abs((a[key] ?? -1) - (b[key] ?? -1)) > 0.002) return true;
                } else if (JSON.stringify(a[key]) !== JSON.stringify(b[key])) {
                    return true;
                }
            }
            return false;
        });
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
        added(id);
        return id;
    }

    function duplicate(id) {
        const w = get(id);
        if (!w || types[w.type]?.single) return "";
        const copy = Object.assign({}, w, { x: (w.x ?? 0) + 36, y: (w.y ?? 0) + 36 });
        delete copy.id;
        delete copy.z;
        return add(w.type, copy);
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

    signal added(string id)
    property var leaving: []

    function remove(id) {
        if (leaving.includes(id)) return;
        leaving = leaving.concat([id]);
        removal.createObject(root, { target: id });
    }

    function finishRemove(id) {
        leaving = leaving.filter(l => l !== id);
        save(list.filter(w => w.id !== id));
    }

    Component {
        id: removal

        Timer {
            required property string target
            interval: Theme.anim.medium
            running: true
            onTriggered: {
                root.finishRemove(target);
                destroy();
            }
        }
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
        syncPresets();
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
        function onPresetsChanged() { root.syncPresets(); }
        function onPresetChanged() { root.syncPresets(); }
    }

    Component.onCompleted: sync()
}
