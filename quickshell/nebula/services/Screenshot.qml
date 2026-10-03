pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/Pictures/Screenshots"
    readonly property bool busy: proc.running

    signal saved(string path)

    function region() {
        take(true);
    }

    function screen() {
        take(false);
    }

    function take(useRegion) {
        if (proc.running) return;
        GlobalStates.capturing = true;
        proc.command = ["sh", "-c", `
            dir=$1; region=$2; monitor=$3
            mkdir -p "$dir"
            file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
            if [ "$region" = 1 ]; then
                geometry=$(slurp < /dev/null) || exit 1
                grim -g "$geometry" "$file"
            else
                grim -o "$monitor" "$file"
            fi || exit 1
            wl-copy < "$file"
            notify-send -i "$file" "Screenshot" "Saved to $file"
            printf '%s' "$file"`,
            "sh", directory, useRegion ? "1" : "0", Hyprland.focusedMonitor?.name ?? ""];
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
