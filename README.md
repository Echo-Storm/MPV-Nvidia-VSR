# 🎬 MPV Echostorm Edition

## 🧠 Overview

This setup is built for users who have Nvidia RTX Video Super Resolution (VSR) enabled in the Nvidia Control Panel. It includes:

- A streamlined `mpv.conf` optimized for modern GPUs
- A custom Lua script that triggers VSR after 3 seconds of playback and upscales to native resolution
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
    │   ├── auto_nvidia_vsr.lua           ← RTX VSR upscaler (Echostorm)
    │   ├── screenshotfolder_echostorm.lua← organized screenshots (Echostorm)
    │   ├── thumbfast.lua                 ← seekbar thumbnails
    │   ├── pause_indicator_lite.lua      ← pause overlay
    │   ├── playlistmanager.lua           ← playlist OSD
    │   ├── open_file.lua                 ← native Windows open file/folder/subtitle/audio dialog (Echostorm: added open folder)
    │   ├── ytdlautoformat.lua            ← auto ytdl-format per domain (YouTube, Twitch, Kick)
    │   ├── autocrop.lua                  ← auto-crop black bars (mpv core script)
    │   ├── chapterskip.lua               ← auto-skip OP/ED/preview chapters
    │   ├── reload.lua                    ← auto-reload stalled streams
    │   ├── hdr-mode.lua                  ← SDR/HDR auto-switch (inert until mpv-display-plugin is installed)
    │   └── autochapters/main.lua         ← auto-detect anime OP/ED chapters (needs guessit.exe, see below)
    ├── script-opts/
    │   ├── modernz.conf
    │   ├── thumbfast.conf
    │   ├── pause_indicator_lite.conf
    │   ├── playlistmanager.conf
    │   ├── ytdlautoformat.conf
    │   ├── ytdl_hook.conf                ← pins ytdl_path to yt-dlp
    │   ├── autocrop.conf
    │   ├── chapterskip.conf
    │   ├── reload.conf
    │   ├── hdr-mode.conf
    │   └── autochapters.conf
    └── shaders/
        └── cache/
```

---

## 🎯 Features

- **Base UI:** ModernZ v0.3.3 with fluent icon theme
- **Fonts:** Netflix Sans Medium (default), with Light and Bold variants
- **Upscaling:** RTX VSR script activates after 3 seconds, auto-upscales to native resolution — only applies when video is below display resolution and hardware decoded
- **Interactive menus:** Built-in `select.lua` (mpv 0.40+) wired to playlist, audio track, subtitle, chapter, and audio device buttons
- **Thumbnails:** thumbfast enabled including network/stream sources
- **Screenshots:** Auto-organized into `Desktop/mpv/screenshots/{title}/`, timestamped, JPG
- **Audio normalization:** `dynaudnorm` available via `af=` in `mpv.conf` (commented out by default — uncomment to enable)
- **Network buffering:** Cache and readahead configured for HLS/live stream stability
- **UI:** Borders enabled, windowed by default, taskbar progress enabled
- **File dialogs:** `Ctrl+O` opens files, `Ctrl+Shift+O` opens a folder, `Ctrl+Shift+S` adds a subtitle, `Ctrl+Shift+A` adds an audio track — all via native Windows dialogs, also reachable from the right-click menu
- **Right-click menu:** mpv's full default context menu (`menu.conf`) — playback, tracks, video/audio/subtitle controls, window, tools, etc. — plus Open File/Folder/Subtitle/Audio at the top of the Open submenu
- **Stream quality:** `ytdl-format` auto-adjusts for YouTube, Twitch, and Kick (720p cap by default), leaving other sites on `mpv.conf`'s default — pairs well with RTX VSR upscaling lower-res source
- **Auto-crop:** black bars auto-detected and cropped 4 seconds into playback (`c` to toggle/undo manually — `C`, uppercase, is taken by the aspect-ratio cycle)
- **Chapter skip:** opening, ending, and next-episode preview chapters auto-skipped when present
- **Auto chapters:** missing OP/ED chapters looked up automatically for anime files (requires `guessit.exe`, installed automatically by script 1; and `curl`, built into Windows 10/11)
- **Stream auto-reload:** a stalled/dead network stream automatically reloads from its last position (`Ctrl+R` to trigger manually)
- **HDR auto-switch:** wired in but inert by default — needs [mpv-display-plugin](https://github.com/dyphire/mpv-display-plugin) installed separately, then set `hdr_mode=switch` or `pass` in `hdr-mode.conf`

---

## 📌 Notes

- All scripts are silent, reversible, and require no user input except to exit
- Designed for Windows 10/11 with PowerShell 3+ (written for 7)
- No registry bloat, no filetype hijacking, no start menu shortcuts
- Requires mpv 0.40+ for `select.lua` interactive menus (`load-select=yes`, mpv's actual default — `load-select-ui` was never a real option, see v1.0.3 changelog)
- RTX VSR requires `gpu-api=d3d11` and an Nvidia RTX card with VSR enabled in the Nvidia Control Panel

---

## 📋 Changelog

### 2026-07-29 — v1.0.4: Open Folder, Crop/Chapter/Reload/HDR Scripts

**open_file.lua:**
- Added `open_folder()` — opens a folder via the `Shell.Application` `BrowseForFolder` COM dialog (WPF has no native folder picker, so this is the classic tree-view Windows dialog rather than the modern Explorer-style one used by the file/subtitle/audio pickers). Bound to `Ctrl+Shift+O` and added to the right-click menu.

**modernz.conf:**
- `hidetimeout` 1500 → 3000 — OSC now stays visible 3 seconds after the last mouse movement instead of 1.5

**New — autocrop.lua (mpv core, `TOOLS/lua/autocrop.lua`):**
- Auto-detects and crops black bars ~2 seconds into playback (`auto_delay=1` + `detect_seconds=1`, tuned to land before `auto_nvidia_vsr.lua`'s 3s trigger — see below), using the `video-crop` property (not the `vf` chain), so it doesn't collide with `auto_nvidia_vsr.lua`'s `@vsr` filter
- Default manual toggle key is uppercase `C`, already taken by the aspect-ratio cycle in `input.conf` — remapped to lowercase `c`, also added to the right-click `&Video` menu

**Fix — auto_nvidia_vsr.lua, crop-aware upscaling:**
- `video-crop` is applied by the VO *after* the entire `vf` chain runs (confirmed against mpv's own source, `player/video.c`'s `apply_video_crop()`) — so `@vsr` was upscaling the raw, uncropped frame and computing its scale factor against the full frame size (bars included), meaning genuinely letterboxed/pillarboxed content that would benefit from upscaling once cropped was being silently skipped or under-scaled
- Now reads the active `video-crop` rectangle and uses its dimensions for the scale calculation instead of raw `width`/`height`, falling back to raw dimensions when nothing is cropped
- Also fixed a timing race: autocrop's total crop delay is `auto_delay + detect_seconds` (5s at upstream defaults), which lands after `auto_nvidia_vsr`'s own 3s trigger already fired once with the uncropped size — added a `video-crop` property observer so VSR re-evaluates immediately whenever the crop rectangle appears, changes, or clears, without adding extra delay
- `autocrop.conf`'s `auto_delay` also tuned from the upstream default of 4 down to 1 (total ~2s) so crop lands a full second *before* VSR's 3s check fires at all, avoiding a one-time visible rescale "pop" mid-intro — trade-off is slightly higher risk of a long fade-in/logo card being mis-detected as letterboxing on specific releases; raise it back if that happens
- An actual `vf crop`/`lavfi-crop` filter would let VSR see the cropped frame directly and avoid upscaling the bars at all, but the mpv manual explicitly notes `video-crop` "works with hwdec, unlike the equivalent lavfi-crop" — so that approach was ruled out to keep hardware decoding intact

**New — chapterskip.lua (po5/chapterskip):**
- Auto-skips opening/ending/preview chapters when present. `chapterskip.conf` defaults to `skip=opening;ending;preview`

**New — autochapters (po5/mpv-auto-chapters, `scripts/autochapters/main.lua`):**
- Looks up missing OP/ED chapters for anime files via a local offline anime database + the Aniskip API, pairs with `chapterskip.lua`
- Requires `curl` (built into Windows 10/11 at `System32\curl.exe`) and `guessit.exe`. Wired in portably: `1_Full_Latest_MPV_Installer.ps1` now downloads the latest `guessit-windows.exe` from guessit-io/guessit into the install root as `guessit.exe`, right next to `mpv.exe`/`yt-dlp.exe` — mpv's subprocess call finds it there automatically (same resolution order as the existing yt-dlp bundling), no PATH registration needed

**New — reload.lua (4e6/mpv-reload):**
- Auto-reloads a stalled/dead network stream from its last position. Complements the HLS/live-stream buffering tuning already in `mpv.conf`. `Ctrl+R` to trigger manually, also in the right-click Playback menu

**New — hdr-mode.lua (dyphire/mpv-scripts):**
- Auto-switches display SDR/HDR based on content. Installed but left inert (`hdr_mode=noth`) — `switch`/`pass` modes require the separate [mpv-display-plugin](https://github.com/dyphire/mpv-display-plugin) (a compiled C plugin) for display capability info, which isn't installed

### 2026-07-29 — v1.0.3: Fix load-select, Add Right-Click Menu

**Bug fix — mpv.conf:**
- `load-select-ui` was never a real mpv option. It doesn't exist anywhere in mpv's source or history — mpv silently ignores unknown `mpv.conf` keys with a log warning rather than failing to start, so this line has done nothing since it was added (2026-03-17). The real option is `load-select` (bool, default `yes`), which is what actually controls whether `select.lua` loads. Since it already defaults to `yes`, the interactive select menus were never actually affected by this typo either way — but it's now set explicitly and correctly.

**New — menu.conf:**
- Added mpv's full default right-click context menu (previously this repo had none, so mpv fell back to nothing configured beyond the built-in minimal set)
- Added `&File...`, `Add &subtitle...`, `Add &audio track...` at the top of the `Ope&n` submenu, wired to `open_file.lua`'s Windows file dialog bindings

### 2026-07-29 — v1.0.2: File Dialogs & Auto Stream Quality

**New — open_file.lua (from ModernZ extras):**
- Native Windows file dialog for opening files (`Ctrl+O`), adding a subtitle (`Ctrl+Shift+S`), or adding an audio track (`Ctrl+Shift+A`)
- Keybinds added to `input.conf`

**New — ytdlautoformat.lua (Samillion/mpv-ytdlautoformat):**
- Auto-adjusts `ytdl-format` per domain instead of a single fixed setting in `mpv.conf`
- `ytdlautoformat.conf` domains: `youtu.be, youtube.com, twitch.tv, kick.com` (Kick added), quality capped at 720p by default, fallback enabled
- Other domains are untouched and fall back to whatever `ytdl-format` (if any) is set in `mpv.conf`

**New — ytdl_hook.conf:**
- Pins `ytdl_path=yt-dlp` explicitly, since the installer bundles `yt-dlp.exe` (not `youtube-dl`)

### 2026-07-29 — v1.0.1: VSR Filter Fix

- See commit history — fixed a stale `@vsr` filter lingering across file switches and a missed re-evaluation when consecutive files share a pixel format but differ in resolution. 3-second hwdec settle delay unchanged.

### 2026-07-29 — v1.0.0: Full Script Sync & Bug Fix

**Bug fix — 1_Full_Latest_MPV_Installer.ps1:**
- Removed unconditional admin elevation. The script only downloads/extracts into its own portable folder and writes marker files — never needs admin — but was always triggering a UAC prompt anyway, contradicting the README's "no admin required" claim.

**Bug fix — screenshotfolder_echostorm.lua:**
- Fixed `include_YouTube_ID` never triggering. The code checked whether the *resolved* `media-title` looked like a URL, but `media-title` is already resolved to the human-readable video title (via `ytdl_hook`) by the time `file-loaded` fires, so it never matches a URL pattern. Now checks the actual source `filename` instead, so the video ID is correctly appended to the screenshot folder name for YouTube playback.

**modernz.lua / modernz.conf — updated to v0.3.3 (from v0.3.2):**
- Replaced `modernz.lua` wholesale with upstream v0.3.3
- Changed `layout=modern` → `layout=default` (layout values renamed: `modern`/`modern-compact` → `default`/`compact`/`mini`/`seekbar`; new `mini` and `seekbar` layouts also available)
- Removed `chapter_softrepeat` — option no longer exists upstream
- New option: `truncate_title=no` — ellipsis for overflowing titles
- New option: `ab_loop_color=#2596be` — color of the new A/B loop seekbar indicator
- New option: `thumbnail_box_outline_size=1` — thumbnail box border thickness
- New options: `seekbar_wheel_up_command=seek 10` / `seekbar_wheel_down_command=seek -10` — new seekbar wheel actions
- All existing customized values (colors, button toggles, sizes, mouse bindings, `seekbarkeyframes=no`, `hover_effect=size,glow,color`) preserved as-is

**pause_indicator_lite.lua / pause_indicator_lite.conf — synced with upstream ModernZ extras:**
- Replaced `pause_indicator_lite.lua` wholesale with latest upstream version (rewritten internals: per-file observer lifecycle, indicator position support, themed icon names keyed off `modernz-icons.ttf`)
- New option: `indicator_pos=middle_center` — indicator position (previously hardcoded to center)
- New option: `theme_style=outline` — themed icon style (`outline` or `filled`)
- New option: `mute_icon_size=35` — mute icon size, now vector-drawn instead of font-glyph only
- All existing customized values (`keybind_allow=yes`, `keybind_set=mbtn_left`, icon sizes/colors) preserved as-is

**thumbfast.lua:** updated wholesale to latest upstream (po5/thumbfast) — no local customizations, config values in `thumbfast.conf` unaffected

**playlistmanager.lua:** updated wholesale to latest upstream (jonniek/mpv-playlistmanager) — no local customizations, config values in `playlistmanager.conf` unaffected

**README:**
- Corrected stale claim that Season 5 audio normalization was "active" — the `af=` line in `mpv.conf` is commented out by default
- Fixed uninstall instructions pointing to `X2_Remove_Supported_File_types_From_Open_With.ps1`, a file that doesn't exist in this repo — corrected to the actual `X1_Remove_Supported_File_types_From_Open_With.ps1`
- Removed stale Folder Structure entries and a "Note" referencing phantom renamed scripts (`3_Add_Supported...`, `X1_Unregister_MPV_SANELY...`) that were never added to the repo

### 2026-03-17 — Audit & Modernz 0.3.0 Update

**mpv.conf:**
- Added `load-select-ui=yes` — enables built-in interactive select menus (**correction, see v1.0.3**: `load-select-ui` was never a real mpv option — it silently no-op'd this whole time. The select menus were on regardless, since mpv's real `load-select` option defaults to `yes`.)
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
