-- auto_nvidia_vsr.lua (Echostorm Edition)
-- Applies NVIDIA VSR (d3d11vpp) upscaling when the video resolution is below
-- the display resolution and the pixel format is hardware-decoded.
-- 3-second delay is intentional: gives hwdec time to settle after file load.

local pending_timer = nil
local applying = false  -- guard against re-entrant trigger from vf changes

local function apply_vsr()
    applying = true

    local display_width  = mp.get_property_native("display-width")
    local display_height = mp.get_property_native("display-height")
    local video_width    = mp.get_property_native("width")
    local video_height   = mp.get_property_native("height")
    local pixfmt = mp.get_property_native("video-params/hw-pixelformat")
               or mp.get_property_native("video-params/pixelformat")

    -- Remove existing VSR filter if present
    local vf_current = mp.get_property("vf") or ""
    if vf_current:find("@vsr") then
        mp.command("vf remove @vsr")
    end

    if video_width and display_width then
        local scale = math.max(display_width, display_height)
                    / math.max(video_width, video_height)
        scale = math.floor(scale * 10) / 10  -- round down to nearest 0.1

        if scale > 1 and (pixfmt == "nv12" or pixfmt == "yuv420p") then
            mp.command("vf append @vsr:d3d11vpp:scaling-mode=nvidia:scale=" .. scale)
            mp.osd_message("NVIDIA VSR: " .. scale .. "x upscale", 2)
        end
    end

    applying = false
end

local function schedule_vsr()
    -- Don't re-trigger if we're in the middle of applying (vf change from ourselves)
    if applying then return end

    -- Cancel any pending timer so rapid changes don't stack
    if pending_timer then
        pending_timer:kill()
        pending_timer = nil
    end

    pending_timer = mp.add_timeout(3, function()
        pending_timer = nil
        apply_vsr()
    end)
end

-- Trigger on format change (file load, track switch)
mp.observe_property("video-params/pixelformat", "native", schedule_vsr)
mp.observe_property("video-params/hw-pixelformat", "native", schedule_vsr)

-- Re-apply if vf chain is externally cleared (e.g. user runs 'vf clr')
-- but NOT when we're the ones changing it
mp.observe_property("vf", "native", function()
    if applying then return end
    -- Only reschedule if VSR was present and now isn't (someone cleared it)
    local vf_current = mp.get_property("vf") or ""
    if not vf_current:find("@vsr") then
        schedule_vsr()
    end
end)
