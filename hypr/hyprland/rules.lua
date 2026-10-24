-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Handles for rules the shell switches on and off at runtime (Settings > Bar > Layout and Windows)
NEBULA = { shellBlur = {} }

local function shell_blur(rule)
    table.insert(NEBULA.shellBlur, hl.layer_rule(rule))
end

-- Ignore maximize requests from all apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
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

-- "Smart gaps" / "No gaps when only": uncomment all to use
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- No animation on the slurp selection (screenshots), so it doesn't slide away and end up in the shot
hl.layer_rule({
    name    = "no-anim-slurp",
    match   = { namespace = "^selection$" },
    no_anim = true,
})

-- Quickshell bar: blur behind the islands. ignore_alpha skips fully transparent pixels,
-- so only the islands get blurred and not the empty space between them.
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

-- Quickshell launcher: no slide-in (the pill animation happens in QML), blur behind it
hl.layer_rule({
    name    = "quickshell-launcher",
    match   = { namespace = "^quickshell:launcher$" },
    no_anim = true,
})

shell_blur({
    name  = "blur-quickshell-launcher",
    match = { namespace = "^quickshell:launcher$" },
    blur  = true,
})

-- Layer rules (later: more Quickshell widgets)
-- hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })

-- Window blur off switch: disabled here, so windows blur unless the shell enables it
NEBULA.windowNoBlur = hl.window_rule({
    name    = "nebula-no-window-blur",
    match   = { class = ".*" },
    no_blur = true,
})
NEBULA.windowNoBlur:set_enabled(false)
