-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/

hl.config({
    gestures = {
        workspace_swipe_distance     = 700,  -- px of swiping for one full workspace (higher = slower)
        workspace_swipe_cancel_ratio = 0.15, -- let go before this part of the swipe and it snaps back
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
