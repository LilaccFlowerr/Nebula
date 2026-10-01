pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink

    readonly property bool ready: sink !== null && sink.ready
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property int percent: Math.round(volume * 100)

    readonly property string icon: muted || volume === 0 ? "volume_off"
                                  : volume < 0.5         ? "volume_down"
                                  :                        "volume_up"

    PwObjectTracker {
        objects: [root.sink]
    }

    function setVolume(value) {
        if (ready) sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute() {
        if (ready) sink.audio.muted = !muted;
    }
}
