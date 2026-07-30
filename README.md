# 🎬 MPV Echostorm Edition

## 🧠 Overview

This setup is built for users who have Nvidia RTX Video Super Resolution (VSR) enabled in the Nvidia Control Panel. It includes:

- A streamlined `mpv.conf` optimized for modern GPUs
- A custom Lua script that triggers VSR after 3 seconds of playback, auto-crops black bars, and upscales to native resolution — the two are integrated in one script so crop coordinates and VSR's scale factor never disagree (see Changelog)
- Font and UI tweaks for a clean, modern look via ModernZ v0.3.3
- Fully portable structure with optional system integration
- Built-in `select.lua` UI for interactive playlist, audio, subtitle, and chapter selection

---

## ⚙️ Installation & Usage

### ✅ To install:

1. **Run `1_Full_Latest_MPV_Installer.ps1`**
   - Installs the latest versions of MPV, FFmpeg, yt-dlp, and guessit (used by `autochapters`)
   - Fully portable, no admin required

2. **Run `2_Add_Supported_Filetypes_To_Open_With.ps1`** *(optional)*
   - Adds MPV to system PATH
   - Registers MPV for "Open With" with common media formats
   - Requires admin, will auto-detect and prompt

### 🔄 To uninstall:

- **Run `X1_Remove_Supported_File_types_From_Open_With.ps1`**
  - Removes PATH entry, Open With registration, and filetype associations

### 🔁 To update:

- Simply run `1_Full_Latest_MPV_Installer.ps1`
- Updates MPV, FFmpeg, yt-dlp, and guessit
- No need to re-run registration scripts unless you've uninstalled

---

## 📁 Folder Structure

```
MPV/
├── 1_Full_Latest_MPV_Installer.ps1
├── 2_Add_Supported_Filetypes_To_Open_With.ps1          ← registration (PATH + Open With)
├── X1_Remove_Supported_File_types_From_Open_With.ps1   ← uninstall (reverses script 2)
├── doc/
│   ├── manual.pdf
│   └── mpbindings.png
├── mpv/
│   └── fonts.conf
└── portable_config/
    ├── mpv.conf
    ├── input.conf
    ├── menu.conf            ← right-click context menu (mpv default + Open File/Subtitle/Audio)
    ├── fonts/               ← Netflix Sans + ModernZ icon fonts
    ├── scripts/
    │   ├── modernz.lua                   ← OSC UI
    │   ├── vsr_autocrop.lua              ← RTX VSR upscaler + crop-aware auto-crop, one integrated script (Echostorm)
    │   ├── screenshotfolder_echostorm.lua← organized screenshots (Echostorm)
    │   ├── thumbfast.lua                 ← seekbar thumbnails
    │   ├── pause_indicator_lite.lua      ← pause overlay
    │   ├── playlistmanager.lua           ← playlist OSD
    │   ├── open_file_echostorm.lua       ← native Windows open file/folder/URL/subtitle/audio dialogs (Echostorm: added folder, URL)
    │   ├── ytdlautoformat.lua            ← auto ytdl-format per domain (YouTube, Twitch, Kick)
    │   ├── chapterskip.lua               ← auto-skip OP/ED/preview chapters
    │   ├── reload.lua                    ← auto-reload stalled streams
    │   ├── hdr-mode.lua                  ← SDR/HDR auto-switch
    │   ├── display-info.dll              ← mpv-display-plugin, HDR display info for hdr-mode.lua
    │   ├── prefer_surround_echostorm.lua ← auto-selects the highest-channel-count audio track (Echostorm)
    │   ├── clip_export_echostorm.lua     ← mark in/out points, export via ffmpeg stream copy (Echostorm)
    │   ├── stream_quality_echostorm.lua  ← mid-stream quality up/down for YouTube/Twitch/Kick (Echostorm)
    │   └── autochapters/main.lua         ← auto-detect anime OP/ED chapters (needs guessit.exe, see below)
    ├── script-opts/
    │   ├── modernz.conf
    │   ├── thumbfast.conf
    │   ├── pause_indicator_lite.conf
    │   ├── playlistmanager.conf
    │   ├── ytdlautoformat.conf
    │   ├── ytdl_hook.conf                ← pins ytdl_path to yt-dlp
    │   ├── vsr_autocrop.conf
    │   ├── chapterskip.conf
    │   ├── reload.conf
    │   ├── hdr-mode.conf
    │   ├── prefer_surround_echostorm.conf
    │   ├── clip_export_echostorm.conf
    │   ├── stream_quality_echostorm.conf
    │   └── autochapters.conf
    └── shaders/
        └── cache/
```

---

## 🎯 Features

- **Base UI:** ModernZ v0.3.3 with fluent icon theme
- **Fonts:** Netflix Sans Medium (default), with Light and Bold variants
- **Upscaling:** RTX VSR activates ~4 seconds after playback starts (3s hwdec settle + 1s crop detection), auto-upscales to native resolution — only applies when the *cropped* video content is below display resolution and hardware decoded (`vsr_autocrop.lua`)
- **Interactive menus:** Built-in `select.lua` (mpv 0.40+) wired to playlist, audio track, subtitle, chapter, and audio device buttons
- **Thumbnails:** thumbfast enabled including network/stream sources
- **Screenshots:** Auto-organized into `Desktop/mpv/screenshots/{title}/`, timestamped, JPG
- **Audio normalization:** `dynaudnorm` available via `af=` in `mpv.conf` (commented out by default — uncomment to enable)
- **Network buffering:** Cache and readahead configured for HLS/live stream stability
- **UI:** Borders enabled, windowed by default, taskbar progress enabled
- **File dialogs:** `Ctrl+O` opens files, `Ctrl+Shift+O` opens a folder, `Ctrl+U` opens a URL, `Ctrl+Shift+S` adds a subtitle, `Ctrl+Shift+A` adds an audio track — all via native Windows dialogs, also reachable from the right-click menu
- **Right-click menu:** mpv's full default context menu (`menu.conf`) — playback, tracks, video/audio/subtitle controls, window, tools, etc. — plus Open File/Folder/Subtitle/Audio at the top of the Open submenu, and runtime toggles for crop, auto-crop mode, chapter-skip, and HDR mode (see below)
- **Stream quality:** `ytdl-format` auto-adjusts for YouTube, Twitch, and Kick (720p cap by default), leaving other sites on `mpv.conf`'s default — pairs well with RTX VSR upscaling lower-res source. Bump it up/down mid-stream from the right-click Playback menu (`stream_quality_echostorm.lua`) — reloads at the current position with the new cap, since yt-dlp only reads `ytdl-format` at load time
- **Auto-crop:** black bars auto-detected and cropped as part of the same evaluation that decides VSR's scale factor (`vsr_autocrop.lua`, see Changelog for why these can't be separate scripts). `c` toggles/undoes the current crop+VSR state manually (`C`, uppercase, is taken by the aspect-ratio cycle); auto-crop mode itself can be toggled from the right-click `&Video` menu
- **Motion interpolation:** off by default (`interpolation=no`), toggle from the right-click `&Video` menu — smooths judder on lower-framerate content at the cost of some GPU overhead
- **Chapter skip:** opening, ending, and next-episode preview chapters auto-skipped when present — toggle from the right-click `&Chapters` menu
- **Auto chapters:** missing OP/ED chapters looked up automatically for anime files (requires `guessit.exe`, installed automatically by script 1 — or downloaded manually from [guessit-io/guessit releases](https://github.com/guessit-io/guessit/releases) and dropped in the install root; and `curl`, built into Windows 10/11) — manual search/database-update also in the right-click `&Chapters` menu
- **Stream auto-reload:** a stalled/dead network stream automatically reloads from its last position (`Ctrl+R` to trigger manually, also in the right-click Playback menu)
- **HDR:** [mpv-display-plugin](https://github.com/dyphire/mpv-display-plugin) (`scripts/display-info.dll`) provides display HDR capability info to `hdr-mode.lua`. Defaults to `hdr_mode=pass` (passes HDR through when the display is already in HDR mode; no automatic OS-level HDR switching, no flicker risk). Cycle `noth`/`switch`/`pass` from the right-click `&Window` menu
- **NVIDIA RTX Video HDR:** optional SDR→HDR enhancement, off by default (`nvidia_true_hdr=no` in `vsr_autocrop.conf`) — toggle from the right-click `&Window` menu. Only ever applies when the display is confirmed already in HDR mode (via the same `mpv-display-plugin` info `hdr-mode.lua` uses), so it can't misfire on an SDR display the way mpv's own filter can on its own (see Troubleshooting). Requires mpv 0.40+ and RTX Video HDR enabled in the NVIDIA app
- **Surround audio preferred automatically:** on file load, auto-selects whichever audio track reports the highest channel count, but only among tracks matching whatever language `alang` already resolved to — never overrides a language preference just for more channels (`prefer_surround_echostorm.lua`) — mpv's own `--aid=auto` has no channel-count preference and can land on a lesser stereo/mono track when multiple tracks are ambiguously flagged "default" in the container
- **Clip export:** mark an in/out point during playback and export that range via bundled `ffmpeg.exe` as a lossless stream-copy clip (`clip_export_echostorm.lua`), saved to `Desktop/mpv/clips/` — reachable from the right-click `Tools` → `Clip export` submenu. Cut points snap to the nearest keyframe (a stream-copy limitation, not a bug) — re-encode afterwards in a real editor if frame-accurate cuts are needed

---

## 📌 Notes

- All scripts are silent, reversible, and require no user input except to exit
- Designed for Windows 10/11 with PowerShell 3+ (written for 7)
- No registry bloat, no filetype hijacking, no start menu shortcuts
- Requires mpv 0.40+ for `select.lua` interactive menus (`load-select=yes`, mpv's actual default — `load-select-ui` was never a real option, see v1.0.3 changelog)
- RTX VSR requires `gpu-api=d3d11` and an Nvidia RTX card with VSR enabled in the Nvidia Control Panel

---

## 🔧 Troubleshooting

- **Audio cuts out, drops, or goes silent for a moment right after seeking, unpausing, or skipping to the next track/file.** Known issue with older or budget HDMI A/V receivers (AVRs) / soundbars that ignore or drop the first bit of audio every time HDMI audio output stops and restarts. Fix: uncomment `audio-stream-silence=yes` in `mpv.conf` (commented out by default since v1.0.12 — mpv's own manual calls it "strongly discouraged" since it changes A/V-sync and underrun handling for every file, so it's opt-in rather than on by default now).
- **Audio is too loud/quiet, or inconsistent between quiet and loud scenes/streams.** Uncomment `af=lavfi=[dynaudnorm=f=150:g=15:p=0.95]` in `mpv.conf` (commented out by default) — a single-pass, live-stream-safe loudness normalizer. Unlike `loudnorm`, it doesn't need to buffer the whole file first, so it's safe for live/HLS streams too.
- **Kick.com videos won't load / fail to fetch metadata.** Confirmed to be [yt-dlp#17284](https://github.com/yt-dlp/yt-dlp/issues/17284), an open upstream bug — Kick changed something site-side that broke yt-dlp's extractor (VODs, Live, and Clips all affected). Not a config issue here; should resolve itself once yt-dlp ships a fix. Re-run `1_Full_Latest_MPV_Installer.ps1` periodically to pick up new yt-dlp versions.
- **`autochapters` warns "couldn't parse media filename, is guessit installed?"** Needs `guessit.exe` in the install root — `1_Full_Latest_MPV_Installer.ps1` downloads this automatically; if you installed before that was added, just re-run the installer.
- **HDR isn't switching/passing through.** `hdr-mode.lua` needs the companion [mpv-display-plugin](https://github.com/dyphire/mpv-display-plugin) (`scripts/display-info.dll`) for display capability info — without it, `hdr_mode` has nothing to act on.
- **Enabled `nvidia_true_hdr` but nothing changes.** Needs mpv 0.40+, RTX Video HDR enabled in the NVIDIA app, an SDR (8-bit) source, and the display already in HDR mode — `vsr_autocrop.lua` checks that last part itself via `mpv-display-plugin` before applying anything, since mpv's own filter has no such check and can visibly misbehave on an SDR display ([mpv#17800](https://github.com/mpv-player/mpv/issues/17800)). If the plugin isn't installed, this option is silently a permanent no-op.
- **The Open Folder / Open URL dialogs look light-mode even in a dark theme.** Expected — both use legacy pre-Vista Windows APIs (`Shell.Application.BrowseForFolder`, VB.NET's `InputBox`) that predate dark mode and were never retrofitted for it. Open File/Add Subtitle/Add Audio use the modern dialog, which does follow system theme automatically.

---

## 📋 Changelog

Full version history moved to [CHANGELOG.md](CHANGELOG.md).

### 2026-07-30 — v1.0.14: NVIDIA RTX Video HDR, Hardening Pass, CHANGELOG Split

- **New — NVIDIA RTX Video HDR support in `vsr_autocrop.lua`**: optional SDR→HDR enhancement via d3d11vpp's `nvidia-true-hdr` suboption (mpv 0.40+), off by default (`nvidia_true_hdr=no` in `vsr_autocrop.conf`), toggle added to the right-click `&Window` menu. Only ever applies when the display is confirmed already in HDR mode (via the same `mpv-display-plugin` info `hdr-mode.lua` already reads) and the source is SDR (8-bit) — mpv's own filter has no such check built in and visibly misbehaves on an SDR display ([mpv#17800](https://github.com/mpv-player/mpv/issues/17800)), so this script gates it itself. Can apply with or without VSR upscaling itself (`scale=1` is valid when content is already at display resolution), unlike VSR which only ever engages when upscaling is warranted.
- **Hardening pass** on `chapterskip.lua` and `screenshotfolder_echostorm.lua` (the same fresh-eyes review that caught real bugs in `vsr_autocrop.lua` earlier, now applied to the rest of the custom scripts): `chapterskip.lua` could throw a nil-arithmetic error inside its `chapter`-property callback if the property briefly reported `nil` (e.g. mid-seek); `screenshotfolder_echostorm.lua`'s verbose "Saved to: ..." message (only shown when `short_saved_message=no`) was double-prefixing `~~`, producing a broken path. `prefer_surround_echostorm.lua` was already solid from its earlier language-aware fix — no changes needed there.
- **Bug fix — `[WEB-DL]` auto-profile's `profile-cond` could throw a Lua error.** Found in `mpv.log`: `string.match(p.filename, ...)` was called with no nil-check, and `p.filename` is nil whenever the condition gets evaluated with nothing loaded (e.g. idle at startup) — `bad argument #1 to 'match' (string expected, got nil)`, three times in one session's log. Guarded with `p.filename ~= nil and (...)` so the match calls only run once a file is actually loaded.
- **New — optional motion interpolation**: `interpolation=no` + `tscale=oversample` added explicitly to `mpv.conf` (off by default), toggle added to the right-click `&Video` menu (`cycle interpolation`) next to Deband/Deinterlace.
- **New — `clip_export_echostorm.lua`**: mark an in/out point during playback and export that range via bundled `ffmpeg.exe` as a lossless stream-copy clip (`-c copy`, no re-encoding), saved to `Desktop/mpv/clips/`. `-ss` before `-i` (fast input seek) + `-to` after `-i` (output option, absolute position in the original timeline — ffmpeg's own documented pattern, confirmed against the ffmpeg wiki's Seeking page since `-to`'s behavior here is a well-known gotcha). Directory auto-created via a quick blocking `mkdir` subprocess before the async ffmpeg export starts, since ffmpeg won't create missing output directories itself. Reachable from the right-click `Tools` → `Clip export` submenu (mark start, mark end, export, clear marks) — no default keybindings, menu-only, matching most of this repo's secondary functions.
- **New — `stream_quality_echostorm.lua`**: bump `ytdl-format`'s quality cap up/down mid-stream (right-click Playback menu), for the same domains `ytdlautoformat.lua` already handles. `ytdl-format` is only read by yt-dlp at file-load time, so there's no way to change it live on an already-open stream — this sets `file-local-options/ytdl-format` to the new cap and reloads at the current position (`file-local-options/start` + `playlist-play-index`), the same mechanism the existing "Reload stream (on stall)" entry already uses. Relies on `ytdlautoformat.lua`'s own `respect_manual_changes`/`external_override` tracking (already in that script, previously unused by anything) to recognize this as a manual override and not immediately stomp it back to its own static cap on the reload. Defaults to the top of its quality ladder as the starting point when the current cap isn't recognized (e.g. no cap set, or a site `ytdlautoformat` doesn't cover), and skips the reload entirely if a bump wouldn't actually change anything (already at that rung).
- **Changelog split out of README** into a standalone [CHANGELOG.md](CHANGELOG.md) — the README's version history had grown large enough to bury the actual project description above it.
