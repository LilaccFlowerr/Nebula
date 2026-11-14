local vars    = require("variables")
local mainMod = vars.mainMod

local function bind(keys, dispatcher, opts)
    if type(keys) ~= "table" then keys = { keys } end
    for _, key in ipairs(keys) do
        hl.bind(key, dispatcher, opts)
    end
end

bind(vars.kbTerminal, hl.dsp.exec_cmd(vars.terminal))
bind(vars.kbBrowser,  hl.dsp.exec_cmd(vars.browser))
bind(vars.kbEditor,   hl.dsp.exec_cmd(vars.editor))
bind(vars.kbFiles,    hl.dsp.exec_cmd(vars.files))
bind(vars.kbLauncher, hl.dsp.exec_cmd(vars.launcher), { release = true })

bind(vars.kbClose,       hl.dsp.window.close())
bind(vars.kbFloat,       hl.dsp.window.float({ action = "toggle" }))
bind(vars.kbFullscreen,  hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind(vars.kbPseudo,      hl.dsp.window.pseudo())
bind(vars.kbToggleSplit, hl.dsp.layout("togglesplit"))

bind(vars.kbLock, hl.dsp.exec_cmd("loginctl lock-session"))

bind(vars.kbRecord,       hl.dsp.exec_cmd("qs -c nebula ipc call recorder toggle"))
bind(vars.kbRecordRegion, hl.dsp.exec_cmd("qs -c nebula ipc call recorder region"))

bind(vars.kbMedia, hl.dsp.exec_cmd("qs -c nebula ipc call media toggle"))

bind(vars.kbMissed, hl.dsp.exec_cmd("qs -c nebula ipc call missed toggle"))

bind(vars.kbEditWidgets, hl.dsp.exec_cmd("qs -c nebula ipc call widgets edit"))

bind(vars.kbScreenshotRegion, hl.dsp.exec_cmd("qs -c nebula ipc call screenshot region"))
bind(vars.kbScreenshotScreen, hl.dsp.exec_cmd("qs -c nebula ipc call screenshot screen"))

bind(vars.kbClipboard, hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

bind(vars.kbExit, hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + left",  hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "+1" }))

bind(vars.kbSpecial,       hl.dsp.workspace.toggle_special("magic"))
bind(vars.kbMoveToSpecial, hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
