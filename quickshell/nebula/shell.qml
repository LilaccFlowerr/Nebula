//@ pragma IconTheme Papirus
import Quickshell
import qs.widgets.bar
import qs.widgets.recorder
import qs.widgets.launcher
import qs.widgets.wallpaper
import qs.widgets.desktop
import qs.services

ShellRoot {
    WallpaperWindow {}
    WidgetsWindow {}
    readonly property bool screenshotBusy: Screenshot.busy
    readonly property var hyprMonitors: HyprConfig.monitors

    
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

        WidgetsCorner {
            required property ShellScreen modelData
            screen: modelData
        }
    }

    ImagePickerWindow {}

    LauncherWindow {}

    
}
