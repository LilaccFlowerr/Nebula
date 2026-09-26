-- See https://wiki.hypr.land/Configuring/Basics/Variables/

-- Colors from matugen (hypr/colors.lua), with a fallback when it hasn't run yet
local ok, colors = pcall(require, "colors")
if not ok then
    colors = { primary = "33ccff", tertiary = "00ff99", outline_variant = "595959" }
end

hl.config({
    general = {
        layout      = "dwindle",

        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 1,

        col = {
            active_border   = { colors = {"rgba(" .. colors.primary .. "ee)", "rgba(" .. colors.tertiary .. "ee)"}, angle = 45 },
            inactive_border = "rgba(" .. colors.outline_variant .. "aa)",
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
