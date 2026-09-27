pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property list<MprisPlayer> players: Mpris.players.values.filter(p => !p.dbusName.includes("playerctld"))

    readonly property MprisPlayer player: players.find(p => p.isPlaying) ?? players[0] ?? null

    readonly property bool active: player !== null && title !== ""
    readonly property bool playing: player?.isPlaying ?? false

    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string artUrl: player?.trackArtUrl ?? ""

    readonly property string track: title + " — " + artist

    readonly property real position: player?.position ?? 0
    readonly property real length: player?.length ?? 0
    readonly property real progress: length > 0 ? position / length : 0

    Timer {
        interval: 1000
        running: root.playing
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    function togglePlaying() { if (player?.canTogglePlaying) player.togglePlaying(); }
    function next()          { if (player?.canGoNext) player.next(); }
    function previous()      { if (player?.canGoPrevious) player.previous(); }

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }
}
