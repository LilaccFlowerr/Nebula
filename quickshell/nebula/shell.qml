//@ pragma IconTheme Papirus
import Quickshell
import qs.widgets.bar
import qs.widgets.recorder
import qs.widgets.launcher
import qs.widgets.wallpaper
import qs.widgets.desktop
import qs.widgets.screenshot
import qs.widgets.galaxy
import qs.widgets.lock
import qs.widgets.popups.notifications
import qs.services

ShellRoot {
    WallpaperWindow {}
    WidgetsWindow {}
    readonly property bool screenshotBusy: Screenshot.busy
    readonly property var hyprMonitors: HyprConfig.monitors
    readonly property bool equalizer: Equalizer.available

    
    Bar {}

    Variants {
        model: Quickshell.screens

        RecorderCorner {
            required property ShellScreen modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        WidgetMenu {}
    }

    Variants {
        model: Quickshell.screens

        DesktopMenu {}
    }

    Variants {
        model: Quickshell.screens

        WidgetsCorner {
            required property ShellScreen modelData
            screen: modelData
        }
    }


    LauncherWindow {}

    GalaxyWindow {}

    ImageCache {}

    Variants {
        model: Quickshell.screens

        GalaxyPeek {
            required property ShellScreen modelData
            screen: modelData
        }
    }

    FreezeWindow {}

    LockWindow {}

    
}
