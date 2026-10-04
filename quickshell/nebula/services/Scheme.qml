pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var schemes: [
        { name: "Tonal Spot", scheme: "scheme-tonal-spot" },
        { name: "Vibrant", scheme: "scheme-vibrant" },
        { name: "Expressive", scheme: "scheme-expressive" },
        { name: "Fidelity", scheme: "scheme-fidelity" },
        { name: "Monochrome", scheme: "scheme-monochrome" },
        { name: "Neutral", scheme: "scheme-neutral" },
        { name: "Rainbow", scheme: "scheme-rainbow" },
        { name: "Fruit Salad", scheme: "scheme-fruit-salad" }
    ]

    readonly property string current: Settings.theme.scheme
    readonly property bool dark: Settings.theme.mode !== "light"
    property var previews: ({})
    property var pending: ({})
    property string previewKey: ""

    function apply() {
        matugen.command = ["sh", "-c", "matugen image \"$1\" -t \"$2\" -m \"$3\" < /dev/null", "sh", Wallpaper.current, current, Settings.theme.mode];
        matugen.running = false;
        matugen.running = true;
    }

    function set(scheme) {
        if (!scheme) return;
        Settings.theme.scheme = scheme;
        apply();
    }

    function toggleMode() {
        Settings.theme.mode = dark ? "light" : "dark";
        apply();
        loadPreviews();
    }

    function loadPreviews() {
        const key = Wallpaper.current + "|" + Settings.theme.mode;
        if (key === previewKey) return;
        previewKey = key;
        pending = {};
        preview.command = ["sh", "-c", `
            for s in ${schemes.map(s => s.scheme).join(" ")}; do
                matugen image "$1" -t "$s" -m "$2" --dry-run --json hex < /dev/null 2>/dev/null \\
                    | jq -r --arg s "$s" --arg m "$2" '[$s, .colors.primary[$m], .colors.secondary[$m], .colors.tertiary[$m], .colors.primary_container[$m], .colors.surface_container_high[$m]] | join(" ")' &
            done
            wait`, "sh", Wallpaper.current, Settings.theme.mode];
        preview.running = false;
        preview.running = true;
    }

    Connections {
        target: Settings
        function onGroupReset(group) {
            if (group === "theme") root.apply();
        }
    }

    Process {
        id: matugen
        stderr: SplitParser {
            onRead: line => console.warn("matugen:", line)
        }
    }

    Process {
        id: preview
        stdout: SplitParser {
            onRead: line => {
                const [scheme, primary, secondary, tertiary, primaryContainer, surface] = line.split(" ");
                root.pending[scheme] = { primary, secondary, tertiary, primaryContainer, surface };
            }
        }
        onExited: root.previews = root.pending
    }

    IpcHandler {
        target: "scheme"

        function set(scheme: string): void { root.set(scheme); }
        function toggleMode(): void { root.toggleMode(); }
    }
}
