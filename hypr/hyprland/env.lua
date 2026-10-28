-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Hybrid GPUs: when a screen on the dedicated GPU's HDMI port is plugged in at login, let that GPU render
-- (no slow copy from the iGPU every frame). Otherwise the iGPU renders and the dedicated GPU can sleep.
-- Only read at Hyprland startup, so plugging in later needs a re-login.
local function read(path)
    local f = io.open(path)
    if not f then return nil end
    local s = f:read("l")
    f:close()
    return s
end

local dgpu, igpu
for n = 0, 3 do
    if read("/sys/class/drm/card" .. n .. "-eDP-1/status") then igpu = n end
end
for n = 0, 3 do
    if n ~= igpu and read("/sys/class/drm/card" .. n .. "-HDMI-A-1/status") == "connected" then dgpu = n end
end

if dgpu and igpu then
    hl.env("AQ_DRM_DEVICES", "/dev/dri/card" .. dgpu .. ":/dev/dri/card" .. igpu)
end

-- Video in Quickshell decodes on the GPU that renders: CUDA on NVIDIA, VA-API on Intel/AMD.
local renderer = dgpu or igpu
if renderer then
    local nvidia = read("/sys/class/drm/card" .. renderer .. "/device/vendor") == "0x10de"
    hl.env("QT_FFMPEG_DECODING_HW_DEVICE_TYPES", nvidia and "cuda" or "vaapi")
end
