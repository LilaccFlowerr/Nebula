-- See https://wiki.hypr.land/Configuring/Basics/Variables/#decoration

hl.config({
    decoration = {
        rounding       = 15,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 0.95,
        inactive_opacity = 0.95,

        blur = {
            enabled        = true,
            size           = 8,
            passes         = 2,
            ignore_opacity = true, -- needed to blur through transparent windows
            popups         = true,
        },

        shadow = {
            enabled      = true,
            range        = 15,
            render_power = 4,
            color        = 0x22000000,
        },
    },
})
