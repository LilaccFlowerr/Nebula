pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
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
        terminal: { title: "Fetch", description: "Your system at a glance, rice style", icon: "terminal", shape: "Square", size: 520, minSize: 240, maxSize: 1000, color: "surface" },
        text: { title: "Text", description: "A note on your desktop", icon: "sticky_note_2", shape: "Sunny", size: 180, minSize: 80, maxSize: 600, color: "tertiary" },
        lyrics: { title: "Lyrics", description: "The song's words, sung along", single: true, icon: "lyrics", shape: "Cookie4Sided", size: 520, minSize: 300, maxSize: 1100, color: "primary", aspect: 0.46, bare: true },
        visualizer: { title: "Visualizer", description: "Bars or a wave that move with the music", icon: "graphic_eq", shape: "Circle", size: 640, minSize: 24, maxSize: 4000, color: "primary", aspect: 0.28, bare: true }
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
        closeDesk();
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

    property bool deskOpen: false
    property string deskScreen: ""
    property real deskX: 0
    property real deskY: 0

    property string deskPage: "main"
    property real deskAlignX: 0
    property real deskAlignY: 0

    function openDesk(screenName, x, y, page = "main", alignX = 0, alignY = 0) {
        closeMenu();
        deskScreen = screenName;
        deskX = x;
        deskY = y;
        deskPage = page;
        deskAlignX = alignX;
        deskAlignY = alignY;
        deskOpen = true;
    }

    property bool editing: false
    property string editScreen: ""

    property string selected: ""
    property bool resizing: false
    property var history: []
    property int historyIndex: -1
    property bool restoring: false
    readonly property bool canUndo: historyIndex > 0
    readonly property bool canRedo: historyIndex < history.length - 1

    function frozen() {
        return JSON.stringify(list.filter(w => !leaving.includes(w.id)).map(w => {
            const copy = Object.assign({}, w);
            delete copy.z;
            return copy;
        }));
    }

    function resetHistory() {
        history = [frozen()];
        historyIndex = 0;
    }

    function commit() {
        const now = frozen();
        if (history[historyIndex] === now) return;
        history = history.slice(0, historyIndex + 1).concat([now]).slice(-50);
        historyIndex = history.length - 1;
    }

    function stepHistory(delta) {
        commit();
        const index = historyIndex + delta;
        if (index < 0 || index >= history.length) return;
        const next = parse(history[index]);
        const fresh = next.filter(w => get(w.id) === null).map(w => w.id);
        historyIndex = index;
        restoring = true;
        gliding();
        save(next);
        restoring = false;
        for (const id of fresh) added(id);
        if (selected !== "" && get(selected) === null) selected = "";
    }

    function undo() {
        stepHistory(-1);
    }

    function redo() {
        stepHistory(1);
    }

    function nudge(dx, dy) {
        const w = get(selected);
        if (!w) return;
        const screen = screenNamed(w.screen ?? "");
        const rect = rectOf(selected);
        update(selected, {
            x: Math.round(Math.max(0, Math.min(rect.x - screen.x + dx, screen.width - rect.width))),
            y: Math.round(Math.max(0, Math.min(rect.y - screen.y + dy, screen.height - rect.height)))
        });
    }

    function removeSelected() {
        if (selected === "") return;
        const id = selected;
        selected = "";
        remove(id);
    }

    Timer {
        id: commitTimer
        interval: 400
        onTriggered: root.commit()
    }

    function startEdit(screenName) {
        closeMenu();
        closeDesk();
        selected = "";
        resetHistory();
        editScreen = screenName;
        editing = true;
    }

    function stopEdit() {
        closeMenu();
        closeDesk();
        selected = "";
        editing = false;
    }

    function toggleEdit(screenName) {
        if (editing) stopEdit();
        else startEdit(screenName);
    }

    IpcHandler {
        target: "widgets"

        function edit(): void {
            root.toggleEdit(GlobalStates.focusedScreen());
        }
    }

    function closeDesk() {
        deskOpen = false;
    }

    function aspectOf(w) {
        return w?.aspect ?? types[w?.type]?.aspect ?? 1;
    }

    function reshape(id, width, height, at) {
        const w = get(id);
        if (!w) return;
        const s = screenNamed(w.screen ?? "");
        const r = rectOf(id);
        const x = at?.x ?? Math.round(r.x - s.x + r.width / 2 - width / 2);
        const y = at?.y ?? Math.round(r.y - s.y + r.height / 2 - height / 2);
        update(id, {
            size: Math.round(width),
            aspect: height / width,
            x: Math.max(0, Math.min(x, s.width - Math.round(width))),
            y: Math.max(0, Math.min(y, s.height - Math.round(height)))
        });
    }

    function turn(id, direction) {
        const w = get(id);
        if (!w) return;
        const r = rectOf(id);
        const upright = d => d === "left" || d === "right";
        if (upright(w.direction ?? "up") === upright(direction)) update(id, { direction: direction });
        else {
            update(id, { direction: direction });
            reshape(id, r.height, r.width);
        }
    }

    function thicken(id, ratio) {
        const w = get(id);
        if (!w) return;
        const r = rectOf(id);
        const upright = w.direction === "left" || w.direction === "right";
        if (upright) reshape(id, r.height * ratio, r.height);
        else reshape(id, r.width, r.width * ratio);
    }

    function stretch(id) {
        const w = get(id);
        if (!w) return;
        const s = screenNamed(w.screen ?? "");
        const r = rectOf(id);
        const direction = w.direction ?? "up";
        const mirror = w.mirror === true;
        if (direction === "left" || direction === "right") {
            const x = mirror ? r.x - s.x : direction === "right" ? 0 : s.width - r.width;
            reshape(id, r.width, s.height, { x: x, y: 0 });
        } else {
            const y = mirror ? r.y - s.y : direction === "down" ? 0 : s.height - r.height;
            reshape(id, s.width, r.height, { x: 0, y: y });
        }
    }

    function rectOf(id) {
        const w = get(id);
        if (!w) return Qt.rect(0, 0, 0, 0);
        const s = screenNamed(w.screen ?? "");
        const size = w.size ?? types[w.type]?.size ?? 200;
        const p = position(w, s);
        const x = p.x < 0 ? Theme.nowPlaying.margin : p.x;
        const tall = size * aspectOf(w);
        const y = p.y < 0 ? s.height - tall - Theme.nowPlaying.margin : p.y;
        return Qt.rect(s.x + x, s.y + y, size, tall);
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
        const halfTall = half * aspectOf(w);
        return {
            x: x < 0 ? x : Math.max(0, (x + half) * target.width / from.width - half),
            y: y < 0 ? y : Math.max(0, (y + halfTall) * target.height / from.height - halfTall)
        };
    }

    function edit(id) {
        const w = get(id);
        if (!w) return;
        openMenu(id, screenNamed(w.screen ?? "").name, rectOf(id), true);
    }

    property bool picking: false
    property string pickerTarget: ""
    property string pickerScreen: ""
    property string pickerDir: Quickshell.env("HOME") + "/Pictures"

    function openPicker(target, screenName) {
        if (picking) return;
        closeMenu();
        closeDesk();
        pickerTarget = target ?? "";
        pickerScreen = screenName || (GlobalStates.screen !== "" ? GlobalStates.screen : Quickshell.screens[0].name);
        picking = true;
        fileDialog.running = true;
    }

    function pickImage(path) {
        pickerDir = path.slice(0, path.lastIndexOf("/"));
        if (pickerTarget !== "" && get(pickerTarget)) update(pickerTarget, { source: path, zoom: 1, panX: 0, panY: 0 });
        else add("image", { source: path, screen: pickerScreen });
    }

    Process {
        id: fileDialog
        command: ["zenity", "--file-selection", "--title=Choose an image", "--filename=" + root.pickerDir + "/",
                  "--file-filter=Images | *.png *.jpg *.jpeg *.webp *.gif"]
        stdout: StdioCollector {
            onStreamFinished: if (text.trim() !== "") root.pickImage(text.trim())
        }
        onExited: root.picking = false
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
            .map(key => Object.assign({ key: key, taken: types[key].single ? (first(key)?.id ?? "") : "" }, types[key]));
    }

    function reveal(id) {
        const w = get(id);
        if (!w) return;
        if (w.enabled !== true) update(id, { enabled: true });
        raise(id);
        if (editing) selected = id;
        else edit(id);
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
        if (!restoring) commitTimer.restart();
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
        item.fy = (w.y ?? -1) < 0 ? -1 : (w.y + half * aspectOf(w)) / s.height;
        return item;
    }

    function restore(item) {
        const s = screenSize(item.screen);
        const half = (item.size ?? types[item.type]?.size ?? 200) / 2;
        const w = Object.assign({}, item);
        delete w.fx;
        delete w.fy;
        w.x = item.fx < 0 ? -1 : Math.max(0, Math.round(item.fx * s.width - half));
        w.y = item.fy < 0 ? -1 : Math.max(0, Math.round(item.fy * s.height - half * aspectOf(item)));
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
                next.y = Math.max(0, Math.round(w.y - shift * aspectOf(w)));
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
        if (selected === id) selected = "";
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
