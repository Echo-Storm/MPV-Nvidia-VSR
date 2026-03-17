# 🎬 MPV Echostorm Edition

## 🧠 Overview

This setup is built for users who have Nvidia RTX Video Super Resolution (VSR) enabled in the Nvidia Control Panel. It includes:

- A streamlined `mpv.conf` optimized for modern GPUs
- A custom Lua script that triggers VSR after 3 seconds of playback and upscales to native resolution
- Font and UI tweaks for a clean, modern look via ModernZ v0.3.0
- Fully portable structure with optional system integration
- Built-in `select.lua` UI for interactive playlist, audio, subtitle, and chapter selection

---

## ⚙️ Installation & Usage

### ✅ To install:

1. **Run `1_Full_Latest_MPV_Installer.ps1`**
   - Installs the latest versions of MPV, FFmpeg, and yt-dlp
   - Fully portable, no admin required

2. **Run `2_Add_Supported_Filetypes_To_Open_With.ps1`** *(optional)*
   - Adds MPV to system PATH
   - Registers MPV for "Open With" with common media formats
   - Requires admin, will auto-detect and prompt

### 🔄 To uninstall:

- **Run `X2_Remove_Supported_File_types_From_Open_With.ps1`**
  - Removes PATH entry, Open With registration, and filetype associations

### 🔁 To update:

- Simply run `1_Full_Latest_MPV_Installer.ps1`
- Updates MPV, FFmpeg, and yt-dlp
- No need to re-run registration scripts unless you've uninstalled

> **Note:** Scripts 2 and X1 are legacy versions superseded by 3 and X2 respectively. Use 3 and X2.

---

## 📁 Folder Structure

```
MPV/
├── 1_Full_Latest_MPV_Installer.ps1
├── 2_Register_MPV_SANELY_Add_PATH.ps1          ← legacy, use 3 instead
├── 3_Add_Supported_Filetypes_To_Open_With.ps1  ← use this for registration
├── X1_Unregister_MPV_SANELY_REMOVE_PATH.ps1    ← legacy, use X2 instead
├── X2_Remove_Supported_File_types_From_Open_With.ps1  ← use this to uninstall
├── doc/
│   ├── manual.pdf
│   └── mpbindings.png
├── mpv/
│   └── fonts.conf
└── portable_config/
    ├── mpv.conf
    ├── input.conf
    ├── fonts/               ← Netflix Sans + ModernZ icon fonts
    ├── scripts/
    │   ├── modernz.lua                   ← OSC UI
    │   ├── auto_nvidia_vsr.lua           ← RTX VSR upscaler (Echostorm)
    │   ├── screenshotfolder_echostorm.lua← organized screenshots (Echostorm)
    │   ├── thumbfast.lua                 ← seekbar thumbnails
    │   ├── pause_indicator_lite.lua      ← pause overlay
    │   └── playlistmanager.lua           ← playlist OSD
    ├── script-opts/
    │   ├── modernz.conf
    │   ├── thumbfast.conf
    │   ├── pause_indicator_lite.conf
    │   └── playlistmanager.conf
    └── shaders/
        └── cache/
```

---

## 🎯 Features

- **Base UI:** ModernZ v0.3.0 with fluent icon theme
- **Fonts:** Netflix Sans Medium (default), with Light and Bold variants
- **Upscaling:** RTX VSR script activates after 3 seconds, auto-upscales to native resolution — only applies when video is below display resolution and hardware decoded
- **Interactive menus:** Built-in `select.lua` (mpv 0.40+) wired to playlist, audio track, subtitle, chapter, and audio device buttons
- **Thumbnails:** thumbfast enabled including network/stream sources
- **Screenshots:** Auto-organized into `Desktop/mpv/screenshots/{title}/`, timestamped, JPG
- **Audio normalization:** Dynamic loudness normalization active for Season 5 (temporary — see changelog)
- **Network buffering:** Cache and readahead configured for HLS/live stream stability
- **UI:** Borders enabled, windowed by default, taskbar progress enabled

---

## 📌 Notes

- All scripts are silent, reversible, and require no user input except to exit
- Designed for Windows 10/11 with PowerShell 3+ (written for 7)
- No registry bloat, no filetype hijacking, no start menu shortcuts
- Requires mpv 0.40+ for `select.lua` interactive menus (`load-select-ui=yes`)
- RTX VSR requires `gpu-api=d3d11` and an Nvidia RTX card with VSR enabled in the Nvidia Control Panel

---

## 📋 Changelog

### 2026-03-17 — Audit & Modernz 0.3.0 Update

**mpv.conf:**
- Added `load-select-ui=yes` — enables built-in interactive select menus
- Added `cache=yes`, `demuxer-max-bytes=50MiB`, `demuxer-readahead-secs=20`, `stream-buffer-size=512KiB` — HLS/live stream stability
- Added `audio-stream-silence=yes` — prevents silent audio on playlist-next for demuxed HLS streams
- Changed `alang=ja,jp,jpn,en,eng` → `alang=en,eng,und,auto` — removed Japanese priority, added fallback for untagged streams
- Changed `af=` from `loudnorm` (two-pass, kills audio on live streams) → `dynaudnorm` (single-pass, live-safe, better dynamic response)
- Removed `console=yes` and `msg-level=all=info` — debug settings that don't belong in production config
- Changed `screenshot-directory` from `~/Pictures/mpv-screenshots` to `~~desktop/mpv/screenshots` — now matches what `screenshotfolder_echostorm.lua` actually uses and is portable-path safe
- Added note that audio normalization (`af=`) is temporary for Fishtank Season 5 (~29 days)

**input.conf:**
- Removed 7 orphaned key bindings referencing scripts that aren't installed: `audio-visualizer.lua`, `mpv-gif.lua`, `copy-time.lua`, `seek-to.lua`, `sponsorblock-minimal.lua`
- Removed broken HDR profile binding (profile not defined in mpv.conf)

**modernz.conf — v0.3.0 upgrade:**
- New option: `layout=modern` (also accepts `modern-compact`)
- New option: `subtitles_button=yes` — dedicated subtitle track button
- New option: `audio_tracks_button=yes` — dedicated audio track button
- New option: `slider_rounded_corners=yes` (replaces old `slider_radius`)
- New options: `nibble_color` / `nibble_current_color` — chapter marker colors
- All `select/` bindings restored to original now that `load-select-ui=yes` activates the script
- Playlist button left/right click updated to match new v0.3.0 default behavior

**thumbfast.conf:**
- `network=yes` — enables thumbnail generation on network/stream URLs

**auto_nvidia_vsr.lua:**
- Added `applying` guard flag — prevents script from re-triggering itself via its own `vf` changes
- Added `pending_timer` with cancellation — rapid file/track switches no longer stack timers
- Added `hw-pixelformat` as a separate observer alongside `pixelformat` — more reliable hwdec detection
- Fixed scale rounding from `scale % 0.1` (float drift) to `math.floor(scale * 10) / 10`
- Added OSD message on successful VSR apply showing scale factor
- `vf` observer now only reschedules if VSR was externally removed, not on every filter change
