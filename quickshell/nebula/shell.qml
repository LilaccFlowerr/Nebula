//@ pragma IconTheme Papirus
import Quickshell
import qs.widgets.bar
import qs.widgets.recorder
import qs.widgets.launcher
import qs.widgets.wallpaper
import qs.services

ShellRoot {
    WallpaperWindow {}
    readonly property bool screenshotBusy: Screenshot.busy

    
    Bar {}

    RecorderCorner {}

    LauncherWindow {}
    
}
