pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool ready: sink !== null && sink.ready
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property int percent: Math.round(volume * 100)

    readonly property string icon: muted || volume === 0 ? "volume_off"
                                  : volume < 0.5         ? "volume_down"
                                  :                        "volume_up"

    readonly property bool micReady: source !== null && source.ready
    readonly property bool micMuted: micReady ? source.audio.muted : false
    readonly property string micIcon: micMuted ? "mic_off" : "mic"

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    function setVolume(value) {
        if (ready) sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute() {
        if (ready) sink.audio.muted = !muted;
    }

    function toggleMic() {
        if (micReady) source.audio.muted = !micMuted;
    }
}
