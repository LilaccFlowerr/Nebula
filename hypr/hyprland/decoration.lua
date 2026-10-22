-- See https://wiki.hypr.land/Configuring/Basics/Variables/#decoration

local vars = require("variables")

hl.config({
    decoration = {
        rounding       = vars.rounding,
        rounding_power = vars.roundingPower,

        -- Change transparency of focused and unfocused windows
        active_opacity   = vars.windowOpacity,
        inactive_opacity = vars.windowOpacity,

        blur = {
            enabled        = vars.blurEnabled,
            size           = vars.blurSize,
            passes         = vars.blurPasses,
            ignore_opacity = true, -- needed to blur through transparent windows
            popups         = true,
        },

        shadow = {
            enabled      = vars.shadowEnabled,
            range        = vars.shadowRange,
            render_power = 4,
            color        = 0x22000000,
        },
    },
})
