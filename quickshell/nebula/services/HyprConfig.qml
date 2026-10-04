pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

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

    function monitorRule(name) {
        const m = saved[name];
        if (!m) return null;
        if (m.disabled) return `hl.monitor({ output = ${lua(name)}, disabled = true })`;
        return `hl.monitor({ output = ${lua(name)}, mode = ${lua(m.mode ?? "preferred")}, position = "auto", scale = ${m.scale ?? 1} })`;
    }

    function applyDisplays() {
        for (const name of Object.keys(saved)) {
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
