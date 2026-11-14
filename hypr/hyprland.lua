local home = os.getenv("HOME")
local user = home .. "/.config/nebula"
package.path = package.path .. ";" .. user .. "/?.lua"

local function maybe_create(file, content)
    local f = io.open(file)
    if f then
        f:close()
        return
    end
    os.execute("mkdir -p '" .. user .. "'")
    f = io.open(file, "w")
    if f then
        f:write(content)
        f:close()
    end
end

maybe_create(user .. "/hypr-vars.lua", [[
-- Overrides the defaults in hypr/variables.lua, loaded before everything else.
-- Every name in that file works here, for example:
-- return {
--     terminal = "kitty",
--     gapsIn = 8,
--     rounding = 10,
--     kbLayout = "nl",
--     kbTerminal = { "SUPER + T", "SUPER + Return" },
-- }
return {}
]])

maybe_create(user .. "/hypr-user.lua", [[
-- Loaded last, after all of the config. Add your own binds, rules, monitors and autostart here.
-- hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "auto", scale = 1 })
-- hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
]])

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

require("hyprland.env")
require("hyprland.general")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.animations")
require("hyprland.decoration")
require("hyprland.execs")
require("hyprland.rules")
require("hyprland.gestures")
require("hyprland.keybinds")

require("hypr-user")
