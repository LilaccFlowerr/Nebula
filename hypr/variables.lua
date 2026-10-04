-- Shared variables, used by the files in hyprland/
-- Use them with: local vars = require("variables")

local vars = {
    -- Apps
    terminal     = "ghostty",
    browser      = "firefox",
    files        = "nautilus",
    editor       = "code",
    claude       = "claude-desktop-unofficial",
    launcher     = "qs -c nebula ipc call launcher toggle",

    -- Keybinds
    mainMod      = "SUPER",
}

-- apps.lua is written by the shell (Settings > Apps) and overrides the defaults above
local ok, chosen = pcall(require, "apps")
if ok and type(chosen) == "table" then
    for key, command in pairs(chosen) do
        vars[key] = command
    end
end

return vars
