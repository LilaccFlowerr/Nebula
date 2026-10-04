pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int bars: 64
    property var values: []
    readonly property bool running: Media.playing && Settings.bar.visualizer

    readonly property string config: [
        "[general]", "bars = " + bars, "framerate = 60",
        "[input]", "method = pulse",
        "[output]", "method = raw", "raw_target = /dev/stdout", "data_format = ascii",
        "ascii_max_range = 100", "bar_delimiter = 59", "frame_delimiter = 10"
    ].join("\n")

    Process {
        running: root.running
        command: ["sh", "-c", "f=\"$XDG_RUNTIME_DIR/nebula-cava.conf\"; printf '%s\\n' \"$1\" > \"$f\" && exec cava -p \"$f\"", "sh", root.config]
        stdout: SplitParser {
            onRead: line => root.values = line.split(";").filter(v => v !== "").map(v => parseInt(v) / 100)
        }
        onRunningChanged: if (!running) root.values = []
    }
}
