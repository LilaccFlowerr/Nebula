pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
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
    readonly property var windows: Hyprland.toplevels.values

    function raise() {
        if (!player) return;
        const names = [player.desktopEntry, player.identity].filter(n => n).map(n => n.toLowerCase());
        const window = windows.find(t => names.includes((t.wayland?.appId ?? "").toLowerCase()));
        if (window) {
            const address = String(window.address);
            Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address.startsWith("0x") ? address : "0x" + address}" })`);
        } else if (player.canRaise) {
            player.raise();
        }
    }

    function seekTo(fraction) { if (player?.canSeek && length > 0) player.position = Math.max(0, Math.min(1, fraction)) * length; }

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }
}
