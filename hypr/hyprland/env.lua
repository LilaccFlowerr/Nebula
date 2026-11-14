hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

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

local renderer = dgpu or igpu
if renderer then
    local nvidia = read("/sys/class/drm/card" .. renderer .. "/device/vendor") == "0x10de"
    hl.env("QT_FFMPEG_DECODING_HW_DEVICE_TYPES", nvidia and "cuda" or "vaapi")
end
