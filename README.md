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
- **Stream quality:** `ytdl-format` auto-adjusts for YouTube, Twitch, and Kick (720p cap by default), leaving other sites on `mpv.conf`'s default — pairs well with RTX VSR upscaling lower-res source
- **Auto-crop:** black bars auto-detected and cropped as part of the same evaluation that decides VSR's scale factor (`vsr_autocrop.lua`, see Changelog for why these can't be separate scripts). `c` toggles/undoes the current crop+VSR state manually (`C`, uppercase, is taken by the aspect-ratio cycle); auto-crop mode itself can be toggled from the right-click `&Video` menu
- **Chapter skip:** opening, ending, and next-episode preview chapters auto-skipped when present — toggle from the right-click `&Chapters` menu
- **Auto chapters:** missing OP/ED chapters looked up automatically for anime files (requires `guessit.exe`, installed automatically by script 1 — or downloaded manually from [guessit-io/guessit releases](https://github.com/guessit-io/guessit/releases) and dropped in the install root; and `curl`, built into Windows 10/11) — manual search/database-update also in the right-click `&Chapters` menu
- **Stream auto-reload:** a stalled/dead network stream automatically reloads from its last position (`Ctrl+R` to trigger manually, also in the right-click Playback menu)
- **HDR:** [mpv-display-plugin](https://github.com/dyphire/mpv-display-plugin) (`scripts/display-info.dll`) provides display HDR capability info to `hdr-mode.lua`. Defaults to `hdr_mode=pass` (passes HDR through when the display is already in HDR mode; no automatic OS-level HDR switching, no flicker risk). Cycle `noth`/`switch`/`pass` from the right-click `&Window` menu
- **Surround audio preferred automatically:** on file load, auto-selects whichever audio track reports the highest channel count (`prefer_surround_echostorm.lua`) — mpv's own `--aid=auto` has no channel-count preference and can land on a lesser stereo/mono track when multiple tracks are ambiguously flagged "default" in the container

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
- **The Open Folder / Open URL dialogs look light-mode even in a dark theme.** Expected — both use legacy pre-Vista Windows APIs (`Shell.Application.BrowseForFolder`, VB.NET's `InputBox`) that predate dark mode and were never retrofitted for it. Open File/Add Subtitle/Add Audio use the modern dialog, which does follow system theme automatically.

---

## 📋 Changelog

### 2026-07-30 — v1.0.13: Auto-Prefer Surround Audio, .gitignore, Repo Description

- **New — `prefer_surround_echostorm.lua`**: on file load, auto-selects whichever audio track reports the highest channel count. Found via `mpv.log` while testing: a file (Big Buck Bunny's `bbb_sunflower_2160p_60fps_normal.mp4` test clip) with both an mp3 2ch track and an ac3 6ch track, both flagged `default` in the container, had mpv's own `--aid=auto` land on the 2ch one — confirmed in the log at file-load (`[af] [in] 48000Hz stereo 2ch`). mpv's own manual notes track auto-selection "sometimes expose[s] behavior that may appear strange" and has no channel-count preference; the existing `trackselect` community script wasn't a fit either (it matches by track *title* text, not channel count). Only acts once per file at load; manual track switches mid-playback are left alone.
- **New — `.gitignore`**. Never existed before; runtime binaries (`mpv.exe`, `ffmpeg.exe`, `yt-dlp.exe`, `guessit.exe`), the mpv shader cache, test artifacts (`*.log`, `samplevideo*.mp4`), and the old backup zip pattern had only stayed out of git because of manual care during every sync this whole update effort, not because anything actually prevented them from being committed.
- **GitHub repo description updated** to actually mention the two dozen+ custom/tuned scripts now bundled — the old description only described the original VSR-only script from before this whole update effort.

### 2026-07-30 — v1.0.12: Troubleshooting Section, audio-stream-silence Disabled, Repo Topics

- **`audio-stream-silence=yes` disabled** in `mpv.conf` (now commented out, not deleted). mpv's own manual calls it "strongly discouraged" — it changes A/V-sync and underrun handling globally, for every file, to work around one specific class of problem (older/budget HDMI AVRs that drop audio on stream restart). Was originally added for a different reason (silent audio on playlist-next for demuxed HLS streams) that hasn't actually been a problem in practice. Comment expanded with the actual symptom keywords (receiver, AVR, HDMI, audio drops/cuts out) so it's easy to find and re-enable if anyone actually needs it.
- **New — Troubleshooting section in the README**, so every disabled-but-available fix and known non-issue is documented and searchable in one place: the audio-stream-silence fix above, `dynaudnorm` audio normalization (also disabled by default in `mpv.conf`), the Kick.com/yt-dlp#17284 upstream bug, `autochapters` needing `guessit.exe`, HDR needing the companion display plugin, and the light-mode-only legacy dialogs.
- **GitHub repo topics added** (previously had none at all): `mpv`, `mpv-config`, `nvidia`, `nvidia-rtx`, `rtx`, `vsr`, `video-super-resolution`, `windows`, `video-player`, `yt-dlp`, `hdr`, `autocrop`, `powershell`, `modernz` — should help the repo actually surface in GitHub's topic browsing/search instead of being invisible to it.

### 2026-07-30 — v1.0.11: Open URL, Menu Symmetry, Testing Log

- **`open_file.lua` renamed to `open_file_echostorm.lua`** — it's diverged enough from the upstream ModernZ fork (folder + URL dialogs added) to deserve the same `_echostorm` naming convention as `screenshotfolder_echostorm.lua`. `input.conf`/`menu.conf` bindings updated from `open_file/*` to `open_file_echostorm/*` to match (mpv derives a script's binding-path name from its filename).
- **New — `open_url()`**: a genuine native Windows input box (VB.NET's `InputBox`, reachable from PowerShell via the `Microsoft.VisualBasic` assembly) prompting for a URL to load. `Ctrl+U`, plus `Open URL...` in the right-click `Ope&n` submenu. Matches `open()`/`open_folder()`/`add_*()`'s native-dialog pattern rather than using mpv's own console input, which was the first pass but inconsistent with the others.
- Right-click menu: `&File...` → `Open &File...`, matching `Open &folder...`/`Open &URL...` for consistency (purely cosmetic, no functional change).
- `mpv.conf`: added `log-file=~~/mpv.log`, truncated fresh on every launch (not unbounded growth), forced to at least `-v -v`. Meant for the current active testing/debugging period — flagged with a comment to remove once that's done, not meant to be permanent.
- Confirmed (not a bug here): `Microsoft.VisualBasic`, `PresentationFramework` (WPF), and `Shell.Application` are all standard components of Windows 10/11 itself (.NET Framework + core Shell), and `powershell.exe` (Windows PowerShell 5.1, not the separate optional PowerShell 7) has shipped with every Windows 10/11 install since release — all three dialogs work with zero extra setup on any Windows 10/11 machine.
- Confirmed a Kick.com video failing to load is [yt-dlp#17284](https://github.com/yt-dlp/yt-dlp/issues/17284), an open upstream bug (VODs/Live/Clips all affected by a recent Kick site change) — not a config issue here, should resolve itself once yt-dlp ships a fix.
- **Known, low-priority, "if I get around to it" limitation:** `open_folder()`'s `BrowseForFolder` and `open_url()`'s `InputBox` are both legacy pre-Vista Windows APIs that predate dark mode and were never retrofitted for it, so they render in light mode regardless of system theme — unlike `open()`/`add_subtitle()`/`add_audio()`'s modern `IFileDialog`-based picker, which follows system dark/light mode automatically for free. The only ways to change this are a fragile, undocumented DWM hack that only darkens the title bar (leaving the actual body/controls light — a visually inconsistent half-fix) or a fully custom-built WPF dialog styled dark by hand. Neither is a small change, and it's cosmetic only, so left as-is for now.

### 2026-07-30 — v1.0.10: guessit.exe and mpv-display-plugin Actually Installed

Both `autochapters` and `hdr-mode.lua` were wired in but had their real dependencies missing until now:

- **`guessit.exe`** (v4.1.0) downloaded and placed in the install root alongside `mpv.exe`/`ffmpeg.exe`/`yt-dlp.exe`/`.guessit_last_version.txt`, matching the existing yt-dlp bundling pattern exactly — a runtime binary, not tracked in git. `autochapters` can now actually parse filenames.
- **`display-info.dll`** ([dyphire/mpv-display-plugin](https://github.com/dyphire/mpv-display-plugin) v1.1.0) installed to `scripts/` — this one *is* tracked in git, same as the Lua scripts, since it's a small stable plugin rather than a versioned auto-updated external tool. Confirmed its exposed `user-data/display-info/*` properties (`hdr-supported`, `hdr-status`, `max-luminance`, `min-luminance`) match exactly what `hdr-mode.lua` reads.
- `hdr-mode.conf`: `hdr_mode` changed from `noth` to `pass` — passes HDR through when the display is already in HDR mode, no automatic OS-level HDR switching (and so no flicker risk from that). `switch` (fully automatic, but can cause a brief blank/flicker on some monitors when the OS-level HDR mode toggles) is available via the right-click `&Window` menu if wanted instead.

### 2026-07-30 — v1.0.9: Pre-Existing mpv.conf/Font Bugs

Caught on the console during v1.0.8 testing, unrelated to VSR/crop — pre-existing since before this whole update effort:

- **`osd-color`, `osd-border-color`, `sub-color`, `sub-border-color` were silently never applying.** `#` starts a comment in `mpv.conf` (confirmed in mpv's own manual), so an unquoted `osd-color=#FFFFFF` gets parsed as `osd-color=` (empty) with `#FFFFFF` stripped as a comment — mpv logs `Error parsing option osd-color (option requires parameter)` and moves on with whatever the built-in default is. All four now wrapped in double quotes (`osd-color="#FFFFFF"`), which protects the `#` from comment-parsing.
- **`screenshot-template` had the same issue, plus another one.** `screenshot-template=%f-%wH.%wM.%wS.%wT-#%#00n` starts with `%`, which `mpv.conf`'s parser tries to interpret as its own fixed-length quoting syntax (`%n%text%`) and fails (`fixed-length quoting expected... your option value starts with '%'`) — on top of the same embedded-`#`-as-comment problem as the colors above. Now quoted as a whole: `screenshot-template="%f-%wH.%wM.%wS.%wT-#%#00n"`. (`screenshotfolder_echostorm.lua` overrides this at runtime anyway, so this was a dead fallback value, but worth fixing to kill the console noise and in case the script ever fails to load.)
- **`modernz-icons.ttf` was sitting in `scripts/`, not `fonts/`.** mpv tries to load every file in `scripts/` as a script, so it logged `Can't load unknown script: .../scripts/modernz-icons.ttf` on every startup. It was also *missing* from `fonts/` entirely, where mpv actually needs it to make the font available for ModernZ's themed icon glyphs. Moved (not copied) to `fonts/modernz-icons.ttf`.

### 2026-07-29 — v1.0.8: hwdec=d3d11va-copy, Crop-Confirmation Fix (Crop Actually Works Now)

This entry supersedes most of v1.0.7 below — that merge was the right call (one script owning crop+VSR instead of two independently-timed scripts) but its implementation had two more serious problems that only showed up under real playback, not in review. Both are now fixed and confirmed working end-to-end (letterboxed and pillarboxed test clips crop correctly, VSR upscales correctly, on a plain uncropped file nothing loops or misbehaves).

**Problem 1 — a toggle-driven feedback loop that caused a full Windows BSOD.** v1.0.7's `vsr_autocrop.lua` still toggled `hwdec` off/on around cropdetect (matching upstream `autocrop.lua`, which has to support hwdec setups with no copy-back mode available). It also observed `video-params/pixelformat`/`hw-pixelformat` to re-evaluate on mid-file format changes. Restoring hwdec is a genuine hardware reinit that isn't guaranteed to settle synchronously with the Lua call that triggered it — if the resulting change notification landed after the script had already re-armed its own observer, it re-triggered the whole flow, which toggled hwdec again, indefinitely. Rapid D3D11 device/context churn from that loop was severe enough to bluescreen the test machine, not just freeze mpv.

- **Fix:** `mpv.conf`'s `hwdec` changed from `d3d11va` to `d3d11va-copy`. Copy-back mode means every decoded frame already lands in system RAM, which the plain `cropdetect` filter can read directly — no hwdec toggle needed at all. `@vsr` (`d3d11vpp`) still works fine on a copied-back frame; per mpv's own filter docs, "software frames are automatically uploaded to hardware for processing," so it re-uploads regardless of how the frame arrived. This removes the entire toggle mechanism from `vsr_autocrop.lua` (`hwdec_backup`, `restore_hwdec()`, the `hwdec-current` exclusion check) rather than patching around its timing.
- The pixelformat/hw-pixelformat observers (which only existed to catch mid-file track switches, and were the trigger for the feedback loop) are replaced with observing `vid` (selected track id) instead — never touched by this script's own actions, so it can't feed back into itself.
- A subagent-driven fresh-eyes bug sweep of the resulting script (before the next problem was even found) caught two more real issues, fixed same-day: `finish_detection()` could throw a nil-arithmetic error if the video track changed mid-detection (leaving `applying` stuck `true` for the rest of the file, silently disabling the script), and `vf append @vsr:...`'s success was never checked (a failed insert still marked VSR as applied, causing repeated pointless re-evaluation on every unrelated filter toggle for the rest of the file).

**Problem 2 — crop was silently discarded even once the above was fixed.** With the loop gone, testing showed VSR upscaling correctly but crop never applying. Console log: `Ignoring invalid --video-crop=3840x1600+0+280 for 1920x1080 image`. The math was actually correct (that's the detected crop rectangle correctly scaled by VSR's confirmed 2.0x factor) — the bug was timing: `@vsr`'s filter-graph reconfiguration isn't synchronous with the `vf append` command that inserts it, so the pipeline was still emitting the old, pre-upscale frame size for a beat afterward. Setting the scaled `video-crop` immediately validated it against that stale size, and mpv silently discarded it as invalid.

- **Fix:** after inserting `@vsr`, wait for `video-out-params/w` (dimensions *after* the filter chain runs) to actually change before setting the scaled crop, instead of guessing another delay value. 2-second fallback timeout in case that confirmation never arrives, so it can't hang forever.
- The OSD message ("NVIDIA VSR: Nx upscale (cropped)") now only fires once the crop is actually confirmed applied, not before, so it can't claim success prematurely.
- Caught and fixed before syncing: the wait's observer/timer weren't tracked anywhere, so switching files while the confirmation was still pending would've left a stale observer/timer able to fire later against the *next* file's state. Now tracked alongside the other timers/observers and cleared by `clear_all()`.

### 2026-07-29 — v1.0.7: autocrop.lua Removed, Merged Into vsr_autocrop.lua

**Superseded by v1.0.8 above** — this merge's overall direction (one script owning crop+VSR) was correct, but this specific implementation still had the hwdec-toggle feedback loop described there, and didn't yet have the crop-confirmation fix. Kept below as a historical record of the diagnosis that led there.

Real-world testing on `D:\Applications\MPV` showed VSR's scaling was "all messed up" whenever autocrop was active, regardless of how the timing between the two scripts was tuned (v1.0.4's crop-aware re-evaluation, v1.0.5's `auto_delay` tuning, and reverting to `auto_delay=4` for testing all failed the same way). The root cause turned out to have nothing to do with timing:

**Root cause:** `video-crop` is applied by the VO *after* the entire `vf` chain runs (confirmed against mpv's own source, `player/video.c`'s `apply_video_crop()`). `autocrop.lua`'s cropdetect measures the crop rectangle against the **raw decoded frame**. But once `@vsr` has already upscaled that frame by the time `video-crop` reaches the VO, the crop rectangle is being applied in the wrong coordinate space entirely — not "slightly off", just wrong. No amount of retiming two independently-triggered scripts fixes a coordinate-space mismatch.

**Fix:** `autocrop.lua` and `autocrop.conf` are removed. Crop detection is folded directly into a new `vsr_autocrop.lua` (replacing `auto_nvidia_vsr.lua`), which now owns the whole flow as one coordinated step:

1. Wait `settle_delay` (3s, hwdec settle — unchanged, still load-bearing)
2. Run cropdetect for `detect_seconds` (1s)
3. Compute VSR's scale factor from the **cropped** content size vs. display size
4. Apply `@vsr` at that scale
5. Set `video-crop` using the detected rectangle **scaled by that same VSR factor**, so it lines up with the frame `@vsr` actually outputs — not the raw decoded one

- `settle_delay`/`detect_seconds`/`detect_limit`/`detect_round`/`detect_min_ratio`/`suppress_osd` all carried over as options in the new `vsr_autocrop.conf`; `auto_crop` replaces `autocrop.conf`'s old `auto` option
- Manual toggle key `c` and the `C`-collision comment carried over unchanged (input.conf)
- `menu.conf`, previously pointing at `autocrop/toggle_crop` and `autocrop/toggle_auto`, now points at `vsr_autocrop/toggle_crop` and `vsr_autocrop/toggle_auto_crop`
- Fixed a bug caught during review before release: the pixelformat-change observers (for mid-file track switches) called the evaluation function directly with no delay, bypassing `settle_delay` entirely for that trigger path — same class of "evaluated before hwdec settled" bug this whole rework exists to fix, just via a different trigger. Now routed through the same delayed scheduler as file-loaded.
- `applying` guard now covers the entire detect→apply flow (previously only the final apply step), since the script's own `vf remove`/hwdec-toggle calls during cropdetect could otherwise spuriously re-trigger its own observers mid-flight

### 2026-07-29 — v1.0.6: Context Menu Toggles

None of `autocrop`, `chapterskip`, or `hdr-mode` exposed a way to flip their behavior at runtime beyond editing config files, so added small local toggle functions to each (documented inline as "Echostorm Edition" additions, same pattern as `auto_nvidia_vsr.lua`/`screenshotfolder_echostorm.lua`) and wired them into `menu.conf`:

- **autocrop.lua:** `toggle_auto()` — flips the `auto` option itself (distinct from the existing `toggle_crop`, which only crops/uncrops the current file). Applies immediately to the current file when re-enabled. Menu: `&Video` → `Toggle auto-crop`
- **chapterskip.lua:** `toggle_enabled()` — writes through `change-list script-opts` rather than just the local table, since `chapterskip()` calls `read_options()` on every chapter change and would otherwise immediately clobber an in-memory-only toggle. Menu: `&Chapters` → `Toggle auto-skip OP/ED/preview`
- **hdr-mode.lua:** `cycle_mode()` — cycles `noth` → `switch` → `pass` → `noth`; `o.hdr_mode` is read live throughout the script so this takes effect immediately. Menu: `&Window` → `Cycle HDR mode`
- **autochapters:** already exposed `search`/`update` script-bindings upstream with no default key and no menu entry — added both to the menu: `&Chapters` → `Search for chapters online` / `Update chapter database`
- `&Chapters` restructured from a single `$chapters` token into a proper submenu (`&List` sub-item + the above)
- Left `reload.lua`'s auto-detection timers and `ytdlautoformat.lua` without toggles — the former would need deeper changes to its timer re-init logic to be safe, the latter doesn't have any existing hook to build on; both are reasonably "set and forget" already

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
