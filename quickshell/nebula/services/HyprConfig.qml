pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.theme

Singleton {
    id: root

    property var monitors: []
    readonly property var saved: {
        try {
            return JSON.parse(Settings.displays.monitors || "{}");
        } catch (e) {
            return {};
        }
    }

    readonly property var appModes: {
        try {
            return JSON.parse(Settings.windows.appOpacity || "{}");
        } catch (e) {
            return {};
        }
    }
    readonly property var modeOpacity: ({ light: 0.95, solid: 1 })

    function lua(value) {
        if (typeof value === "string") return JSON.stringify(value);
        return String(value);
    }

    function run(code) {
        Quickshell.execDetached(["hyprctl", "eval", code]);
    }

    function applyInput() {
        const i = Settings.input;
        run(`hl.config({ input = { kb_layout = ${lua(i.layout)}, repeat_rate = ${i.repeatRate}, repeat_delay = ${i.repeatDelay}, `
            + `sensitivity = ${i.sensitivity}, accel_profile = ${lua(i.flatAccel ? "flat" : "")}, `
            + `touchpad = { natural_scroll = ${i.naturalScroll}, tap_to_click = ${i.tapToClick}, disable_while_typing = ${i.disableWhileTyping} } } })`);
    }

    function applyBlur() {
        const b = Settings.blur;
        const windows = Settings.windows.blurOn;
        run(`hl.config({ decoration = { blur = { enabled = ${b.shell || windows}, size = ${b.size}, passes = ${b.passes} } } })`);
        run(`for _, rule in ipairs(NEBULA.shellBlur) do rule:set_enabled(${b.shell}) end NEBULA.windowNoBlur:set_enabled(${!windows})`);
    }

    function applyWindows() {
        const w = Settings.windows;
        run(`hl.config({ general = { gaps_in = ${w.gapsIn}, gaps_out = ${w.gapsOut} }, decoration = { rounding = ${w.rounding}, `
            + `active_opacity = ${w.opacity / 100}, inactive_opacity = ${w.opacity / 100} } })`);
    }

    function appIdFor(entry) {
        return entry.id;
    }

    function setAppMode(appId, mode) {
        const all = Object.assign({}, appModes);
        all[appId] = mode;
        Settings.windows.appOpacity = JSON.stringify(all);
    }

    function removeApp(appId) {
        const all = Object.assign({}, appModes);
        delete all[appId];
        Settings.windows.appOpacity = JSON.stringify(all);
    }

    function applyApps() {
        let code = "NEBULA.appRules = NEBULA.appRules or {} for _, rule in pairs(NEBULA.appRules) do rule:set_enabled(false) end ";
        for (const appId of Object.keys(appModes)) {
            const opacity = modeOpacity[appModes[appId]];
            if (opacity === undefined) continue;
            const entry = DesktopEntries.heuristicLookup(appId);
            const classes = [...new Set([appId, entry?.id, entry?.startupClass].filter(c => c))];
            const pattern = "(?i)^(" + classes.map(c => c.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|") + ")$";
            const handle = `NEBULA.appRules[${lua(appId)}]`;
            code += `${handle} = hl.window_rule({ name = ${lua("nebula-app-" + appId)}, match = { class = ${lua(pattern)} }, opacity = "${opacity} override" }) ${handle}:set_enabled(true) `;
        }
        run(code);
    }

    function rgba(color, alpha) {
        return lua(`rgba(${String(color).slice(1, 7)}${alpha})`);
    }

    function applyBorders() {
        run(`hl.config({ general = { col = { active_border = { colors = { ${rgba(Colors.primary, "ee")}, ${rgba(Colors.tertiary, "ee")} }, angle = 45 }, `
            + `inactive_border = ${rgba(Colors.outlineVariant, "aa")} } } })`);
    }

    function monitorRule(name) {
        const m = saved[name];
        if (!m) return null;
        if (m.disabled) return `hl.monitor({ output = ${lua(name)}, disabled = true })`;
        return `hl.monitor({ output = ${lua(name)}, disabled = false, mode = ${lua(m.mode ?? "preferred")}, position = "auto", scale = ${m.scale ?? 1} })`;
    }

    function applyDisplays() {
        for (const name of Object.keys(saved)) {
            if (name.startsWith("eDP")) continue;
            const rule = monitorRule(name);
            if (rule) run(rule);
        }
        refreshTimer.restart();
    }

    function setMonitor(name, changes) {
        const all = Object.assign({}, saved);
        const current = monitors.find(m => m.name === name);
        const base = all[name] ?? (current ? { mode: current.mode, scale: current.scale, disabled: current.disabled } : {});
        all[name] = Object.assign({}, base, changes);
        Settings.displays.monitors = JSON.stringify(all);
        run(monitorRule(name));
        refreshTimer.restart();
    }

    function applyAll() {
        applyInput();
        applyBlur();
        applyWindows();
        applyApps();
        applyBorders();
        applyDisplays();
    }

    function refresh() {
        list.running = true;
    }

    Process {
        id: list
        command: ["hyprctl", "monitors", "all", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(text).map(m => ({
                        name: m.name,
                        description: m.description,
                        disabled: m.disabled,
                        scale: m.scale,
                        mode: `${m.width}x${m.height}@${Math.round(m.refreshRate)}`,
                        modes: [...new Set(m.availableModes.map(s => {
                            const [res, hz] = s.replace("Hz", "").split("@");
                            return `${res}@${Math.round(parseFloat(hz))}`;
                        }))]
                    }));
                } catch (e) {
                    console.warn("HyprConfig: could not read monitors", e);
                }
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 500
        onTriggered: root.refresh()
    }

    Timer {
        id: inputTimer
        interval: 200
        onTriggered: root.applyInput()
    }

    Timer {
        id: blurTimer
        interval: 150
        onTriggered: root.applyBlur()
    }

    Timer {
        id: windowsTimer
        interval: 150
        onTriggered: root.applyWindows()
    }

    Timer {
        id: appsTimer
        interval: 150
        onTriggered: root.applyApps()
    }

    Timer {
        id: bordersTimer
        interval: 150
        onTriggered: root.applyBorders()
    }

    Connections {
        target: Colors
        function onPrimaryChanged() { bordersTimer.restart(); }
        function onTertiaryChanged() { bordersTimer.restart(); }
        function onOutlineVariantChanged() { bordersTimer.restart(); }
    }

    Connections {
        target: Settings.blur
        function onShellChanged() { blurTimer.restart(); }
        function onSizeChanged() { blurTimer.restart(); }
        function onPassesChanged() { blurTimer.restart(); }
    }

    Connections {
        target: Settings.windows
        function onBlurOnChanged() { blurTimer.restart(); }
        function onOpacityChanged() { windowsTimer.restart(); }
        function onRoundingChanged() { windowsTimer.restart(); }
        function onGapsInChanged() { windowsTimer.restart(); }
        function onGapsOutChanged() { windowsTimer.restart(); }
        function onAppOpacityChanged() { appsTimer.restart(); }
    }

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() { appsTimer.restart(); }
    }

    Connections {
        target: Settings.input
        function onLayoutChanged() { inputTimer.restart(); }
        function onRepeatRateChanged() { inputTimer.restart(); }
        function onRepeatDelayChanged() { inputTimer.restart(); }
        function onSensitivityChanged() { inputTimer.restart(); }
        function onFlatAccelChanged() { inputTimer.restart(); }
        function onNaturalScrollChanged() { inputTimer.restart(); }
        function onTapToClickChanged() { inputTimer.restart(); }
        function onDisableWhileTypingChanged() { inputTimer.restart(); }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") applyTimer.restart();
            else if (event.name === "monitoradded" || event.name === "monitorremoved") refreshTimer.restart();
        }
    }

    Timer {
        id: applyTimer
        interval: 300
        onTriggered: root.applyAll()
    }

    Component.onCompleted: {
        refresh();
        applyTimer.start();
    }
}
