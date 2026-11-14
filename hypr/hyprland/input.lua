local vars = require("variables")

hl.config({
    input = {
        kb_layout  = vars.kbLayout,
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0,

        touchpad = {
            natural_scroll = vars.naturalScroll,
        },
    },
})

