local vars = require("variables")

hl.config({
    decoration = {
        rounding       = 15,
        rounding_power = vars.roundingPower,

        active_opacity   = 0.95,
        inactive_opacity = 0.95,

        blur = {
            enabled        = true,
            size           = 4,
            passes         = 1,
            ignore_opacity = true,
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
