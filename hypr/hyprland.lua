-- Entry point: Hyprland loads this file, which loads everything else.
-- require("hyprland.env") loads hyprland/env.lua

-- Monitors, see https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Laptop screen: native 1080p at 144Hz, no scaling
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
})

-- Fallback for any other monitor
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
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
