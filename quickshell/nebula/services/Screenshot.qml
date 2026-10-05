pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/Pictures/Screenshots"
    readonly property bool busy: proc.running
    readonly property bool copy: Settings.screenshot.copy
    readonly property bool notify: Settings.screenshot.notify

    signal saved(string path)

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
        if (proc.running) return;
        GlobalStates.capturing = true;
        proc.command = ["sh", "-c", `
            dir=$1; region=$2; monitor=$3; copy=$4; notify=$5
            mkdir -p "$dir"
            file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
            if [ "$region" = 1 ]; then
                geometry=$(slurp < /dev/null) || exit 1
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
        onExited: GlobalStates.capturing = false
    }

    IpcHandler {
        target: "screenshot"

        function region(): void { root.region(); }
        function screen(): void { root.screen(); }
    }
}
