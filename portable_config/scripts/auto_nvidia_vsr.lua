-- auto_nvidia_vsr.lua (Echostorm Edition)
-- Applies NVIDIA VSR (d3d11vpp) upscaling when the video resolution is below
-- the display resolution and the pixel format is hardware-decoded.
-- 3-second delay is intentional: gives hwdec time to settle after file load.
--
-- Crop-aware: autocrop.lua's video-crop property is applied by the VO
-- *after* the whole vf chain runs (confirmed against mpv's own source,
-- player/video.c apply_video_crop()), so the @vsr filter never actually
-- sees the cropped frame -- only the raw decoded one, bars included.
-- Using an actual vf crop filter instead would let VSR see the crop
-- directly, but the mpv manual explicitly says video-crop "works with
-- hwdec, unlike the equivalent lavfi-crop", so that would break hardware
-- decoding. Given that constraint, this script instead reads the current
-- video-crop rectangle and uses ITS dimensions (not the raw frame size)
-- to decide whether/how much to upscale, so a letterboxed/pillarboxed
-- video still gets correctly identified as needing an upscale once
-- cropped, even though VSR itself still processes the uncropped frame.

local pending_timer  = nil
local applying       = false  -- guard against re-entrant trigger from vf changes
local vsr_was_applied = false  -- tracks whether VSR is currently in the chain

-- Returns the effective content width/height: the current video-crop
-- rectangle's size if autocrop has cropped the frame, otherwise the raw
-- decoded dimensions.
local function get_effective_dims()
    local video_width  = mp.get_property_native("width")
    local video_height = mp.get_property_native("height")

    local crop = mp.get_property("video-crop") or ""
    local cw, ch = crop:match("^(%d+)x(%d+)%+")
    if cw and ch then
        return tonumber(cw), tonumber(ch)
    end
    return video_width, video_height
end

local function apply_vsr()
    applying = true

    local display_width  = mp.get_property_native("display-width")
    local display_height = mp.get_property_native("display-height")
    local video_width, video_height = get_effective_dims()
    local pixfmt = mp.get_property_native("video-params/hw-pixelformat")
               or mp.get_property_native("video-params/pixelformat")

    -- Remove existing VSR filter if present
    local vf_current = mp.get_property("vf") or ""
    if vf_current:find("@vsr") then
        mp.command("vf remove @vsr")
    end

    vsr_was_applied = false  -- reset; will be set true below if we apply

    if video_width and display_width then
        local scale = math.max(display_width, display_height)
                    / math.max(video_width, video_height)
        scale = math.floor(scale * 10) / 10  -- round down to nearest 0.1

        if scale > 1 then
            if pixfmt == "nv12" or pixfmt == "yuv420p" then
                mp.command("vf append @vsr:d3d11vpp:scaling-mode=nvidia:scale=" .. scale)
                mp.osd_message("NVIDIA VSR: " .. scale .. "x upscale", 2)
                vsr_was_applied = true
            else
                -- p010/p016 (10-bit HW decode) and other formats land here.
                -- NVIDIA VSR support for 10-bit is inconsistent; skipping to avoid errors.
                mp.msg.info("VSR skipped: unsupported pixel format " .. tostring(pixfmt))
            end
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

-- Strip a leftover @vsr filter immediately (not after the 3s delay), so a
-- new file isn't briefly shown through a filter scaled for the previous
-- one. Guarded with `applying` so the vf observer below doesn't re-enter.
local function clear_vsr()
    applying = true
    local vf_current = mp.get_property("vf") or ""
    if vf_current:find("@vsr") then
        mp.command("vf remove @vsr")
    end
    vsr_was_applied = false
    applying = false
end

-- file-loaded is the authoritative per-file trigger: it fires on every
-- file regardless of whether the pixel-format string happens to differ
-- from the previous file (e.g. two back-to-back NV12 files at different
-- resolutions wouldn't otherwise change video-params/pixelformat at all).
local function on_file_loaded()
    clear_vsr()
    schedule_vsr()
end

mp.register_event("file-loaded", on_file_loaded)

-- Trigger on format change too (track switch mid-file, hwdec settling)
mp.observe_property("video-params/pixelformat",    "native", schedule_vsr)
mp.observe_property("video-params/hw-pixelformat", "native", schedule_vsr)

-- autocrop.lua applies its crop ~4s after file-loaded (auto_delay), which
-- lands AFTER our own 3s trigger already ran once with the uncropped
-- size. Re-evaluate immediately (no extra delay -- hwdec has long since
-- settled by the time autocrop's independent timer fires) whenever the
-- crop rectangle appears, changes, or is cleared.
mp.observe_property("video-crop", "string", function()
    if applying then return end
    apply_vsr()
end)

-- Re-apply if vf chain is externally cleared (e.g. user runs 'vf clr')
-- but NOT when we're the ones changing it, and NOT on videos where VSR
-- was never applied (avoids spurious reschedules on deband toggle etc.)
mp.observe_property("vf", "native", function()
    if applying then return end
    local vf_current = mp.get_property("vf") or ""
    if vsr_was_applied and not vf_current:find("@vsr") then
        schedule_vsr()
    end
end)
