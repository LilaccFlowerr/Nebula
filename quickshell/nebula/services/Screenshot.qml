pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.theme

Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/Pictures/Screenshots"
    readonly property bool busy: proc.running || freezing
    readonly property bool copy: Settings.screenshot.copy
    readonly property bool notify: Settings.screenshot.notify
    readonly property bool freeze: Settings.screenshot.freeze

    property bool freezing: false
    property int frozen: 0

    readonly property string select: `select_region() {
        ws=$(hyprctl monitors -j | jq -c '[.[].activeWorkspace.id]')
        hyprctl clients -j | jq -r --argjson ws "$ws" '.[] | select(.mapped and (.hidden | not) and (.workspace.id as $w | $ws | index($w))) | "\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])"' |
            slurp -d -F "${Theme.font.family}" -w 3 -b "${hex(Colors.scrim, 0.45)}" -c "${hex(Colors.primary, 1)}" -s "${hex(Colors.primary, 0.12)}" -B "${hex(Colors.primary, 0.06)}" "$@"
    }`

    signal saved(string path)

    function hex(color, alpha) {
        const part = v => Math.round(v * 255).toString(16).padStart(2, "0");
        return "#" + part(color.r) + part(color.g) + part(color.b) + part(alpha);
    }

    function region() {
        take(true);
    }

    function screen() {
        take(false);
    }

    function openFolder() {
        Quickshell.execDetached(["sh", "-c", 'mkdir -p "$1" && xdg-open "$1"', "sh", directory]);
    }

    function take(useRegion) {
        if (busy) return;
        GlobalStates.capturing = true;
        if (useRegion && freeze) {
            frozen = 0;
            freezing = true;
            freezeTimeout.restart();
            return;
        }
        start(useRegion);
    }

    function markFrozen() {
        frozen++;
        if (freezing && frozen >= Quickshell.screens.length) start(true);
    }

    Timer {
        id: freezeTimeout
        interval: 600
        onTriggered: if (root.freezing) root.start(true)
    }

    function start(useRegion) {
        if (proc.running) return;
        freezeTimeout.stop();
        proc.command = ["sh", "-c", select + `
            dir=$1; region=$2; monitor=$3; copy=$4; notify=$5
            mkdir -p "$dir"
            file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
            if [ "$region" = 1 ]; then
                geometry=$(select_region) || exit 1
                grim -g "$geometry" "$file"
            else
                grim -o "$monitor" "$file"
            fi || exit 1
            [ "$copy" = 1 ] && wl-copy < "$file"
            [ "$notify" = 1 ] && notify-send -i "$file" "Screenshot" "Saved to $file"
            printf '%s' "$file"`,
            "sh", directory, useRegion ? "1" : "0", Hyprland.focusedMonitor?.name ?? "",
            copy ? "1" : "0", notify ? "1" : "0"];
        proc.running = true;
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: if (text !== "") root.saved(text)
        }
        onExited: {
            GlobalStates.capturing = false;
            root.freezing = false;
        }
    }

    IpcHandler {
        target: "screenshot"

        function region(): void { root.region(); }
        function screen(): void { root.screen(); }
    }
}
