pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var labels: ["32", "64", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"]
    readonly property int maxDb: 12
    readonly property var builtIn: ({
        Flat: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        Bass: [5, 7, 5, 2, 1, 0, 0, 0, 1, 2],
        Treble: [-2, -1, 0, 1, 2, 3, 4, 5, 6, 6],
        Vocal: [-2, -1, 1, 3, 5, 5, 4, 2, 1, 0],
        Pop: [2, 4, 2, 0, 1, 2, 4, 2, 1, 2],
        Rock: [5, 4, 2, -1, -2, -1, 2, 4, 5, 6],
        Jazz: [3, 3, 1, 1, 1, 1, 2, 1, 2, 3],
        Classic: [0, 1, 2, 2, 2, 2, 1, 2, 3, 4]
    })
    readonly property var saved: JSON.parse(Settings.sound.eqSaved)
    readonly property var presets: Object.assign({}, builtIn, saved)
    readonly property var presetNames: Object.keys(presets)

    readonly property var gains: Settings.sound.eqGains.split(",").map(Number)
    readonly property string preset: Settings.sound.eqPreset
    readonly property bool available: Pipewire.nodes.values.some(n => n.name === "nebula_eq")

    signal presetChanging()

    function setGain(index, db) {
        const next = gains.slice();
        next[index] = Math.round(Math.max(-maxDb, Math.min(maxDb, db)));
        if (next[index] === gains[index]) return false;
        Settings.sound.eqGains = next.join(",");
        Settings.sound.eqPreset = "Custom";
        return true;
    }

    function usePreset(name) {
        presetChanging();
        Settings.sound.eqGains = presets[name].join(",");
        Settings.sound.eqPreset = name;
    }

    function save() {
        let n = 1;
        while (presets["Mine " + n]) n++;
        const name = "Mine " + n;
        Settings.sound.eqSaved = JSON.stringify(Object.assign({}, saved, { [name]: gains }));
        Settings.sound.eqPreset = name;
    }

    function remove(name) {
        if (!(name in saved)) return;
        const next = Object.assign({}, saved);
        delete next[name];
        Settings.sound.eqSaved = JSON.stringify(next);
        if (preset === name) Settings.sound.eqPreset = "Custom";
    }

    function apply() {
        if (!available) return;
        const params = gains.map((db, i) => `"eq_band_${i + 1}:Gain" ${db.toFixed(1)}`).join(" ");
        Quickshell.execDetached(["pw-cli", "set-param", "nebula_eq", "Props", `{ params = [ ${params} ] }`]);
    }

    onGainsChanged: apply()
    onAvailableChanged: apply()

    Process {
        id: engine
        running: true
        command: ["sh", "-c", 'pw-cli ls Node | grep -q \'node.name = "nebula_eq"\' || exec pipewire -c "$1"', "sh", Quickshell.shellPath("assets/nebula-eq.conf")]
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 3000
        onTriggered: engine.running = true
    }
}
