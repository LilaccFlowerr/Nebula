NEBULA = { shellBlur = {} }

local function shell_blur(rule)
    table.insert(NEBULA.shellBlur, hl.layer_rule(rule))
end

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.layer_rule({
    name    = "no-anim-slurp",
    match   = { namespace = "^selection$" },
    no_anim = true,
})

shell_blur({
    name         = "blur-quickshell-bar",
    match        = { namespace = "^quickshell:bar$" },
    blur         = true,
    ignore_alpha = 0.1,
})

shell_blur({
    name         = "blur-quickshell-recorder",
    match        = { namespace = "^quickshell:recorder$" },
    blur         = true,
    ignore_alpha = 0.1,
})

shell_blur({
    name         = "blur-quickshell-widgetcorner",
    match        = { namespace = "^quickshell:widget(corner|menu)$" },
    blur         = true,
    ignore_alpha = 0.1,
})

shell_blur({
    name         = "blur-quickshell-widgets",
    match        = { namespace = "^quickshell:widgets$" },
    blur         = true,
    ignore_alpha = 0.1,
})

hl.layer_rule({
    name    = "quickshell-launcher",
    match   = { namespace = "^quickshell:launcher$" },
    no_anim = true,
})

hl.layer_rule({
    name    = "quickshell-galaxy",
    match   = { namespace = "^quickshell:galaxy(peek)?$" },
    no_anim = true,
})

shell_blur({
    name  = "blur-quickshell-launcher",
    match = { namespace = "^quickshell:launcher$" },
    blur  = true,
})

NEBULA.windowNoBlur = hl.window_rule({
    name    = "nebula-no-window-blur",
    match   = { class = ".*" },
    no_blur = true,
})
NEBULA.windowNoBlur:set_enabled(false)
