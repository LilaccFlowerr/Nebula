-- Shared variables, used by the files in hyprland/
-- Use them with: local vars = require("variables")
--
-- Override order: the defaults below, then apps.lua (written by Settings > Apps),
-- then ~/.config/nebula/hypr-vars.lua (yours, never touched by git).

local mainMod = "SUPER"

local vars = {
    -- Apps
    terminal             = "ghostty",
    browser              = "firefox",
    files                = "nautilus",
    editor               = "code",
    launcher             = "qs -c nebula ipc call launcher toggle",

    -- Keybinds
    mainMod              = mainMod,

    -- Windows
    gapsIn               = 5,
    gapsOut              = 10,
    borderSize           = 1,
    rounding             = 15,
    roundingPower        = 2,
    windowOpacity        = 0.95,
    resizeOnBorder       = false,

    -- Blur and shadow
    blurEnabled          = true,
    blurSize             = 4,
    blurPasses           = 1,
    shadowEnabled        = true,
    shadowRange          = 15,

    -- Input
    kbLayout             = "us",
    naturalScroll        = false,

    -- Binds: a string, or a list of strings to bind several keys to one action
    kbTerminal           = mainMod .. " + T",
    kbBrowser            = mainMod .. " + W",
    kbEditor             = mainMod .. " + C",
    kbFiles              = mainMod .. " + E",
    kbLauncher           = mainMod .. " + SUPER_L",
    kbClose              = mainMod .. " + Q",
    kbFloat              = mainMod .. " + V",
    kbFullscreen         = mainMod .. " + F",
    kbPseudo             = mainMod .. " + P",
    kbToggleSplit        = mainMod .. " + J",
    kbLock               = mainMod .. " + L",
    kbRecord             = mainMod .. " + SHIFT + R",
    kbRecordRegion       = mainMod .. " + SHIFT + ALT + R",
    kbMedia              = mainMod .. " + N",
    kbOverview           = mainMod .. " + TAB",
    kbScreenshotRegion   = mainMod .. " + SHIFT + S",
    kbScreenshotScreen   = "Print",
    kbClipboard          = mainMod .. " + SHIFT + V",
    kbExit               = mainMod .. " + M",
    kbSpecial            = mainMod .. " + S",
    kbMoveToSpecial      = mainMod .. " + ALT + S",
}

local function override(file)
    local ok, chosen = pcall(require, file)
    if ok and type(chosen) == "table" then
        for key, value in pairs(chosen) do
            vars[key] = value
        end
    end
end

override("apps")
override("hypr-vars")

return vars
