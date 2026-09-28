pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property int groupSize: 5

    readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    readonly property int group: Math.floor((activeId - 1) / groupSize)
    readonly property int firstId: group * groupSize + 1

    function workspace(id) {
        return Hyprland.workspaces.values.find(ws => ws.id === id) ?? null;
    }

    function isOccupied(id) {
        const ws = workspace(id);
        return ws !== null && ws.toplevels.values.length > 0;
    }

    function isUrgent(id) {
        const ws = workspace(id);
        return ws !== null && ws.urgent;
    }

    function hasWindowsInGroup(g) {
        return Hyprland.workspaces.values.some(ws =>
            ws.id > 0 && Math.floor((ws.id - 1) / groupSize) === g && ws.toplevels.values.length > 0);
    }

    function focus(id) {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
    }

    function next() {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = "e+1" })`);
    }

    function previous() {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = "e-1" })`);
    }
}
