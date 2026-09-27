// The focused window, for the center pill.
// Usage: import qs.services  →  ActiveWindow.hasWindow, ActiveWindow.title, ActiveWindow.appId

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    // Wayland knows the active window right away (Hyprland.activeToplevel only after the first focus change)
    readonly property Toplevel toplevel: ToplevelManager.activeToplevel

    // No window when the focused workspace is empty
    readonly property bool hasWindow: toplevel !== null
        && Hyprland.focusedWorkspace !== null
        && Hyprland.focusedWorkspace.toplevels.values.length > 0

    readonly property string title: hasWindow ? toplevel.title : ""
    readonly property string appId: hasWindow ? toplevel.appId : ""   // e.g. "com.mitchellh.ghostty"

    // App icon, found via the app's .desktop file. Empty when unknown.
    // Usage: IconImage { source: ActiveWindow.icon }  (import Quickshell.Widgets)
    readonly property string icon: {
        DesktopEntries.applications.values;   // re-run when the list of apps has loaded
        const entry = hasWindow ? DesktopEntries.heuristicLookup(appId) : null;
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }
}
