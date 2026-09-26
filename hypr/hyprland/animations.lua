-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- Curves are the Material 3 easings (same as Caelestia)

hl.config({
    animations = {
        enabled = true,
    },
})

-- Curves
hl.curve("standard",        { type = "bezier", points = { {0.2, 0},    {0, 1}      } })
hl.curve("emphasizedDecel", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1}    } }) -- things appearing
hl.curve("emphasizedAccel", { type = "bezier", points = { {0.3, 0},    {0.8, 0.15} } }) -- things disappearing
hl.curve("smooth",          { type = "bezier", points = { {0.4, 0},    {0.2, 1}    } }) -- calm start and end

-- Animations
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 5, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 4, bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "emphasizedDecel", style = "fade" })
hl.animation({ leaf = "fade",        enabled = true, speed = 6, bezier = "standard" })
hl.animation({ leaf = "border",      enabled = true, speed = 6, bezier = "standard" })
