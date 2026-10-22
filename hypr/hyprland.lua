-- Entry point: Hyprland loads this file, which loads everything else.
-- require("hyprland.env") loads hyprland/env.lua

local home = os.getenv("HOME")
local user = home .. "/.config/nebula"
package.path = package.path .. ";" .. user .. "/?.lua"

-- Your own files live in ~/.config/nebula (outside git). Created empty when missing.
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

-- Monitors, see https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Every monitor: preferred mode, placed automatically, scale 1 (a reload keeps it;
-- "auto" made the screen jump big on every reload).
-- Set your own with hl.monitor({ output = "...", mode = "1920x1080@144", position = "0x0", scale = 1 }),
-- or in Settings > System > Displays.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Configs
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

-- Your own config, last so it can override anything above
require("hypr-user")
