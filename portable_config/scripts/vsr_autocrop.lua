-- vsr_autocrop.lua (Echostorm Edition)
--
-- Applies NVIDIA VSR (d3d11vpp) upscaling when the video resolution is below
-- the display resolution and the pixel format is hardware-decoded. Also
-- detects and crops black bars (folded in from mpv core's autocrop.lua),
-- because the two features can't be two independent scripts.
--
-- Why crop detection lives here instead of in a separate autocrop.lua:
-- video-crop is applied by the VO *after* the entire vf chain runs
-- (verified against mpv's own source, player/video.c's apply_video_crop()).
-- cropdetect measures the crop rectangle against the RAW decoded frame, but
-- if @vsr has already upscaled that frame by the time video-crop reaches
-- the VO, the crop rectangle no longer matches the frame it's being
-- applied to -- it's in the wrong coordinate space entirely, not just
-- "slightly off". No amount of timing/ordering between two separate
-- scripts fixes that; the crop rectangle itself has to be scaled by
-- whatever factor VSR applies. That requires one script owning both.
--
-- Flow per file: wait <settle_delay> (hwdec settle) -> run cropdetect for
-- <detect_seconds> -> compute VSR's scale factor from the CROPPED content
-- size -> apply @vsr at that scale -> set video-crop using the detected
-- rectangle scaled by that same factor (so it lines up with the frame
-- @vsr actually outputs, not the raw decoded one).

local options = {
    -- Seconds after file-loaded before doing anything at all. Gives hwdec
    -- time to settle. This delay is intentional -- do not remove it.
    settle_delay = 3,

    -- Whether to auto-detect and crop black bars. VSR upscaling still
    -- works with this off, just without cropping first.
    auto_crop = true,

    -- Black threshold for cropdetect. Smaller values generally crop less.
    -- See limit: https://ffmpeg.org/ffmpeg-filters.html#cropdetect
    detect_limit = "24/255",
    -- The value which width/height should be divisible by. Smaller values
    -- have better detection accuracy.
    detect_round = 2,
    -- The ratio of the minimum clip size to the original (0 to 1). If the
    -- picture is over-cropped, try raising this.
    detect_min_ratio = 0.5,
    -- How long (seconds) to gather cropdetect data after settle_delay.
    detect_seconds = 1,

    -- Whether to suppress the OSD message when crop/VSR are applied.
    suppress_osd = false,
}

require "mp.options".read_options(options, "vsr_autocrop")

local cropdetect_label = mp.get_script_name() .. "-cropdetect"
local command_prefix = options.suppress_osd and "no-osd" or ""

local timers = {
    settle = nil,
    detect_crop = nil,
}

local applying       = false  -- guard against re-entrant trigger from vf changes
local vsr_was_applied = false -- tracks whether @vsr is currently in the chain
local hwdec_backup    = nil

local function kill_timer(key)
    if timers[key] then
        timers[key]:kill()
        timers[key] = nil
    end
end

local function remove_cropdetect()
    local vf = mp.get_property_native("vf") or {}
    for _, filter in pairs(vf) do
        if filter.label == cropdetect_label then
            mp.command(string.format("%s vf remove @%s", command_prefix, filter.label))
            return
        end
    end
end

local function restore_hwdec()
    if hwdec_backup then
        mp.set_property("hwdec", hwdec_backup)
        hwdec_backup = nil
    end
end

local function clear_all()
    -- Strip any existing @vsr filter and video-crop immediately (not
    -- after a delay), so a new file isn't briefly shown through a filter
    -- or crop rectangle computed for the previous one.
    applying = true

    remove_cropdetect()
    kill_timer("settle")
    kill_timer("detect_crop")
    restore_hwdec()

    local vf_current = mp.get_property("vf") or ""
    if vf_current:find("@vsr") then
        mp.command("vf remove @vsr")
    end
    vsr_was_applied = false

    if mp.get_property("video-crop") ~= "" then
        mp.command(string.format("%s set file-local-options/video-crop ''", command_prefix))
    end

    applying = false
end

local function is_cropable(time_needed)
    if mp.get_property_native("current-tracks/video/image") ~= false then
        return false
    end
    local playtime_remaining = mp.get_property_native("playtime-remaining")
    return playtime_remaining and (time_needed + 1) < playtime_remaining
end

-- Computes VSR's scale factor for the given content dimensions, applies
-- @vsr if warranted, and sets video-crop (if crop_meta is valid) using
-- coordinates scaled to match whatever @vsr actually outputs.
local function apply_combined(crop_meta)
    applying = true

    local display_width  = mp.get_property_native("display-width")
    local display_height = mp.get_property_native("display-height")
    local raw_width       = mp.get_property_native("width")
    local raw_height      = mp.get_property_native("height")
    local pixfmt = mp.get_property_native("video-params/hw-pixelformat")
               or mp.get_property_native("video-params/pixelformat")

    local vf_current = mp.get_property("vf") or ""
    if vf_current:find("@vsr") then
        mp.command("vf remove @vsr")
    end
    vsr_was_applied = false

    -- Use the cropped content size for the scale decision when we have a
    -- valid crop; otherwise fall back to the raw decoded size.
    local content_width  = (crop_meta and crop_meta.w) or raw_width
    local content_height = (crop_meta and crop_meta.h) or raw_height

    local scale = nil
    if content_width and display_width then
        scale = math.max(display_width, display_height)
              / math.max(content_width, content_height)
        scale = math.floor(scale * 10) / 10  -- round down to nearest 0.1
    end

    local vsr_applied_now = false
    if scale and scale > 1 then
        if pixfmt == "nv12" or pixfmt == "yuv420p" then
            mp.command("vf append @vsr:d3d11vpp:scaling-mode=nvidia:scale=" .. scale)
            vsr_applied_now = true
            vsr_was_applied = true
        else
            -- p010/p016 (10-bit HW decode) and other formats land here.
            -- NVIDIA VSR support for 10-bit is inconsistent; skipping to avoid errors.
            mp.msg.info("VSR skipped: unsupported pixel format " .. tostring(pixfmt))
        end
    end

    -- Crop rectangle: scale it by the same factor @vsr just applied, so it
    -- matches the frame video-crop actually gets applied against (the VO
    -- receives the POST-filter-chain frame, not the raw decoded one).
    if crop_meta then
        local f = vsr_applied_now and scale or 1
        local cw = math.floor(crop_meta.w * f)
        local ch = math.floor(crop_meta.h * f)
        local cx = math.floor(crop_meta.x * f)
        local cy = math.floor(crop_meta.y * f)
        mp.command(string.format("%s set file-local-options/video-crop %dx%d+%d+%d",
                                  command_prefix, cw, ch, cx, cy))
    else
        if mp.get_property("video-crop") ~= "" then
            mp.command(string.format("%s set file-local-options/video-crop ''", command_prefix))
        end
    end

    if vsr_applied_now then
        mp.osd_message("NVIDIA VSR: " .. scale .. "x upscale"
            .. (crop_meta and " (cropped)" or ""), 2)
    end

    applying = false
end

-- Reads cropdetect's vf-metadata, validates it (mirrors mpv core's
-- autocrop.lua checks), and hands off to apply_combined().
local function finish_detection()
    local metadata = mp.get_property_native("vf-metadata/" .. cropdetect_label)
    remove_cropdetect()
    kill_timer("detect_crop")
    restore_hwdec()

    local raw_width  = mp.get_property_native("width")
    local raw_height = mp.get_property_native("height")

    local crop_meta = nil
    if metadata and metadata["lavfi.cropdetect.w"] then
        local w = tonumber(metadata["lavfi.cropdetect.w"])
        local h = tonumber(metadata["lavfi.cropdetect.h"])
        local x = tonumber(metadata["lavfi.cropdetect.x"])
        local y = tonumber(metadata["lavfi.cropdetect.y"])

        local is_effective = w and h and x and y and
            (x > 0 or y > 0 or w < raw_width or h < raw_height)
        local is_excessive = is_effective and
            (w < raw_width * options.detect_min_ratio or h < raw_height * options.detect_min_ratio)

        if is_effective and not is_excessive then
            crop_meta = { w = w, h = h, x = x, y = y }
        elseif is_excessive then
            mp.msg.info("Crop area too large, skipping (try lowering detect_min_ratio).")
        end
    else
        mp.msg.warn("No cropdetect data -- was the filter inserted successfully?")
    end

    apply_combined(crop_meta)
end

-- Inserts the cropdetect filter and starts the detection timer. Mirrors
-- mpv core's autocrop.lua: hwdec is temporarily disabled during detection
-- since the plain cropdetect filter needs software-accessible frame data.
--
-- Sets `applying` for this function's entire duration through
-- finish_detection()/apply_combined() (not just the final apply step),
-- since the vf-remove and hwdec-toggle calls in between would otherwise
-- spuriously re-trigger the pixelformat/vf observers mid-flight -- via
-- our own changes, not an external one.
local function start_detection()
    applying = true

    if not is_cropable(options.detect_seconds) then
        apply_combined(nil)
        return
    end

    local hwdec_current = mp.get_property("hwdec-current", "no")
    if hwdec_current:find("-copy$") == nil and hwdec_current ~= "no" and
       hwdec_current ~= "crystalhd" and hwdec_current ~= "rkmpp" then
        hwdec_backup = mp.get_property("hwdec")
        mp.set_property("hwdec", "no")
    end

    mp.command(string.format(
        "%s vf pre @%s:cropdetect=limit=%s:round=%d:reset=0",
        command_prefix, cropdetect_label, options.detect_limit, options.detect_round
    ))

    timers.detect_crop = mp.add_timeout(options.detect_seconds, finish_detection)
end

local function begin_evaluation()
    if applying then return end

    if options.auto_crop then
        start_detection()
    else
        apply_combined(nil)
    end
end

-- Routes through the settle delay every time, not just on file-loaded --
-- e.g. the pixelformat observers below fire the moment hwdec/decode
-- format is known, which can be well before hwdec has actually settled.
-- Calling begin_evaluation() directly from those would bypass the delay
-- entirely (the same "evaluated too early" bug this script exists to fix
-- for crop, just via a different trigger).
local function schedule_evaluation()
    if applying then return end
    kill_timer("settle")
    timers.settle = mp.add_timeout(options.settle_delay, function()
        timers.settle = nil
        begin_evaluation()
    end)
end

local function on_file_loaded()
    clear_all()
    schedule_evaluation()
end

-- Manual toggle: "c" (autocrop.lua's own default key, taken over since
-- this script replaces it). If crop or VSR is currently active, clears
-- both; otherwise runs detection immediately (no settle delay -- this is
-- an explicit user action well into playback, hwdec is already stable).
local function on_toggle()
    kill_timer("settle")
    if mp.get_property("video-crop") ~= "" or vsr_was_applied then
        clear_all()
        return
    end
    if timers.detect_crop then
        mp.msg.warn("Already detecting crop!")
        return
    end
    begin_evaluation()
end

-- Toggles whether crop-detection runs automatically on file load. VSR
-- upscaling itself is unaffected -- it just runs against the raw
-- (uncropped) frame size when this is off.
local function toggle_auto_crop()
    options.auto_crop = not options.auto_crop
    mp.osd_message("auto-crop " .. (options.auto_crop and "enabled" or "disabled"), 2)
end

mp.add_key_binding("C", "toggle_crop", on_toggle)
mp.add_key_binding(nil, "toggle_auto_crop", toggle_auto_crop)
mp.register_event("file-loaded", on_file_loaded)
mp.register_event("end-file", clear_all)

-- Re-evaluate on format change too (track switch mid-file, hwdec settling)
mp.observe_property("video-params/pixelformat",    "native", schedule_evaluation)
mp.observe_property("video-params/hw-pixelformat", "native", schedule_evaluation)

-- Re-apply if vf chain is externally cleared (e.g. user runs 'vf clr')
-- but NOT when we're the ones changing it, and NOT on videos where VSR
-- was never applied (avoids spurious reschedules on deband toggle etc.)
mp.observe_property("vf", "native", function()
    if applying then return end
    local vf_current = mp.get_property("vf") or ""
    if vsr_was_applied and not vf_current:find("@vsr") then
        schedule_evaluation()
    end
end)
