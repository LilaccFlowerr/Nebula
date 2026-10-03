//@ pragma IconTheme Papirus
import Quickshell
import qs.widgets.bar
import qs.widgets.recorder
import qs.widgets.launcher
import qs.widgets.wallpaper
import qs.widgets.desktop.nowplaying
import qs.services

ShellRoot {
    WallpaperWindow {}
    NowPlayingWindow {}
    readonly property bool screenshotBusy: Screenshot.busy

    
    Bar {}

    RecorderCorner {}

    LauncherWindow {}
    
}
