hl.config({
    gestures = {
        workspace_swipe_distance     = 700,
        workspace_swipe_cancel_ratio = 0.15,
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
