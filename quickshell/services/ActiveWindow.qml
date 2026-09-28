pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    readonly property Toplevel toplevel: ToplevelManager.activeToplevel

    readonly property bool hasWindow: toplevel !== null
        && Hyprland.focusedWorkspace !== null
        && Hyprland.focusedWorkspace.toplevels.values.length > 0

    readonly property string title: hasWindow ? toplevel.title : ""
    readonly property string appId: hasWindow ? toplevel.appId : ""

    readonly property string icon: {
        DesktopEntries.applications.values;
        const entry = hasWindow ? DesktopEntries.heuristicLookup(appId) : null;
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }
}
