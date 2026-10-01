-- Shared variables, used by the files in hyprland/
-- Use them with: local vars = require("variables")

return {
    -- Apps
    terminal     = "ghostty",
    fileExplorer = "nautilus",
    editor       = "code",
    claude       = "claude-desktop-unofficial",
    launcher     = "qs -c nebula ipc call launcher toggle",

    -- Keybinds
    mainMod      = "SUPER",
}
