local vars = require("variables")

local ok, colors = pcall(require, "colors")
if not ok then
    colors = { primary = "33ccff", tertiary = "00ff99", outline_variant = "595959" }
end

hl.config({
    general = {
        layout      = "dwindle",

        gaps_in     = 5,
        gaps_out    = 10,
        border_size = vars.borderSize,

        col = {
            active_border   = { colors = {"rgba(" .. colors.primary .. "ee)", "rgba(" .. colors.tertiary .. "ee)"}, angle = 45 },
            inactive_border = "rgba(" .. colors.outline_variant .. "aa)",
        },

        resize_on_border = vars.resizeOnBorder,

        allow_tearing = false,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },
})
