hl.on("hyprland.start", function ()
    hl.exec_cmd("/usr/lib/mate-polkit/polkit-mate-authentication-agent-1")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("hypridle")

    hl.exec_cmd("qs -c nebula")

end)
