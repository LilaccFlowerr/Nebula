-- Autostart, see https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Runs once when Hyprland starts (not on reload)

hl.on("hyprland.start", function ()
    -- Auth: password prompt when apps ask for admin rights
    hl.exec_cmd("/usr/libexec/polkit-mate-authentication-agent-1")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("swaybg -i ~/Pictures/zelda.jpeg -m fill")

    hl.exec_cmd("hypridle")

    -- Quickshell: the bar, notifications and (later) all other widgets
    hl.exec_cmd("qs -c nebula")

    -- Apps on a specific workspace at login
    -- hl.dispatch(hl.dsp.exec_cmd("ghostty", { workspace = 1 }))
    -- hl.dispatch(hl.dsp.exec_cmd("code",    { workspace = 2 }))
end)
