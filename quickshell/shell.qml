// Entry point: Quickshell loads this file. It only puts the widgets on screen;
// each widget lives in its own folder under widgets/.
// Run: `qs` (or `quickshell`). Saving any file reloads the shell automatically.

import Quickshell
import qs.widgets.bar

ShellRoot {
    Bar {}

    // Later:
    // NowPlaying {}
    // DesktopShapes {}
}
