-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        layout      = "dwindle",

        gaps_in     = 5,
        gaps_out    = 20,
        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        preserve_split = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
    scrolling = {
        fullscreen_on_one_column = true,
    },
})
