-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local vars    = require("variables")
local mainMod = vars.mainMod

-- Apps
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(vars.editor))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.fileExplorer))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(vars.claude))
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(vars.launcher), { release = true })

-- Windows
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Lock (goes through hypridle's lock_cmd, so it keeps working when hyprlock is replaced)
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- Screen recording (Quickshell recorder): full screen / region
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("qs -c nebula ipc call recorder toggle"))
hl.bind(mainMod .. " + SHIFT + ALT + R", hl.dsp.exec_cmd("qs -c nebula ipc call recorder region"))

-- Screenshots (Quickshell screenshot service): saved to ~/Pictures/Screenshots and copied to the
-- clipboard. Open popups stay open while selecting, so they end up in the shot.
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("qs -c nebula ipc call screenshot region"))
hl.bind("Print", hl.dsp.exec_cmd("qs -c nebula ipc call screenshot screen"))

-- Clipboard history: pick an entry with fuzzel
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

-- Exit Hyprland
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Move focus with mainMod + CTRL + arrow keys
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Previous / next workspace
hl.bind(mainMod .. " + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "e+1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + ALT + S",   hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume and brightness keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Media keys (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
