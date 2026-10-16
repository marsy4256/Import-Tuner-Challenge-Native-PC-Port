# ITC PC Port — Progress Log

## STATUS (2026-10-12): *** QUEST MODE PLAYABLE — post-race fix VERIFIED ***
## Boot -> title -> save -> Quest -> New Game -> intro race -> GARAGE (all works) -> highway.
## The 0x8218E4EC loader-threshold patch (Xenia .patch ported to generated code) fixed
## the post-race black screen. Method: guest VA -> owning fn range -> exact line in
## generated .cpp (PPC comment arithmetic) -> 1-line edit -> apply_code_patches.ps1
## pins it across codegen reruns. 57 manifest boundaries.
## Current input gap: headlight-flash (highway rival challenge) unmapped on keyboard.

## STATUS history: title screen -> menus (vtable thunk batches) -> quest mode -> intro race

## HOW TO LAUNCH (working command)
cd D:\ITC-Recomp\out\build\win-amd64-debug
.\itc_recomp.exe --game_data_root "D:\ITC PC Project\Import Tuner Challenge (USA)" --gpu_plugin=xenos
- Plugin arg must be `xenos` (NOT rexgpu-xenos): loader builds rexgpu-<name><postfix>.dll
  -> rexgpu-xenosd.dll. Passing rexgpu-xenos looks for rexgpu-rexgpu-xenosd.dll (fails).
- Logs: D:\ITC-Recomp\out\build\win-amd64-debug\logs\itc_recomp_NNN.log (file only, no console)
- On FATAL, a "Microsoft Visual C++ Runtime Library" abort() dialog pops (modal).

## THE CORE WORKFLOW (one-by-one barrier fixing)
Each boot dies with:
  [FATAL] Call to invalid or unregistered function at guest address 0xXXXXXXXX
Fix:
  1. Add  '"0xXXXXXXXX" = {}'  under [entrypoint.functions] in itc_recomp_manifest.toml
  2. Build: cmake --build out\build\win-amd64-debug --config Debug   (needs vcvars64.bat first)
  3. Relaunch, read new log, repeat.
CRITICAL: the address must be added as a proper line. Do NOT hand-regex it (a stray `"`
  broke the manifest TOML once). Use Add-Content or an editor.

## AUTOMATION
D:\ITC-Recomp\autofix.ps1  — build -> run 75s -> kill -> read newest log for last [FATAL]
  -> add entry -> repeat (max 120 iters). Stops on: no FATAL (progress), build fail, or
  address already registered (needs manual analysis).
Live output: D:\ITC-Recomp\autofix_run.txt
Restart:  Start-Process powershell -ArgumentList '-ExecutionPolicy','Bypass','-File','D:\ITC-Recomp\autofix.ps1' -RedirectStandardOutput 'D:\ITC-Recomp\autofix_run.txt' -WindowStyle Hidden

## RELEASE BUILD (big fps win over Debug's 10-15fps)
Build:   D:\ITC-Recomp\build_release.bat      (vcvars -> configure win-amd64-release -> build Release)
Output:  D:\ITC-Recomp\out\build\win-amd64-release\itc_recomp.exe
Launch:  cd D:\ITC-Recomp\out\build\win-amd64-release
         .\itc_recomp.exe --game_data_root "D:\ITC PC Project\Import Tuner Challenge (USA)" --gpu_plugin=xenos
NOTE: GPU plugin is NOT auto-staged for release. After building, copy if missing:
         copy "D:\Tools\rexglue-sdk\out\install\win-amd64\bin\rexgpu-xenos.dll"  <release dir>
         copy "D:\Tools\rexglue-sdk\out\install\win-amd64\bin\TracyClient.dll"   <release dir>
      (debug dir gets rexgpu-xenosd.dll automatically; release wants rexgpu-xenos.dll, no 'd')
Release logs: D:\ITC-Recomp\out\build\win-amd64-release\logs\

## PATHS (moved C -> D on 2026-10-12 for storage; ALL references updated)
Project: D:\ITC-Recomp            (was C:\ITC-Recomp)
SDK:     D:\Tools\rexglue-sdk     (was C:\Tools\rexglue-sdk)
- Updated: 6 scripts, PROGRESS.md, desktop shortcut, User PATH, AND the CMake user
  package registry HKCU\Software\Kitware\CMake\Packages\rexglue (this is how
  find_package locates the SDK — write via New-ItemProperty if ever needed again).
- SDK's own out\build cache still has stale C:\ paths: future SDK *source* rebuilds
  need `cmake --preset win-amd64 --fresh` first. SDK *install* files are relocatable,
  so ITC builds work as-is.

## LAUNCH (use this, has all args baked in)
D:\ITC-Recomp\launch_itc.bat     <- double-click this
Manual equivalent:
cd D:\ITC-Recomp\out\build\win-amd64-release
.\itc_recomp.exe --game_data_root "D:\ITC PC Project\Import Tuner Challenge (USA)" --gpu_plugin=xenos --mnk_mode=true --keybind_right_trigger=E,O,W --keybind_left_trigger=Q,I,S

## INPUT / TESTING WITHOUT A CONTROLLER
- Keyboard->gamepad emulation flag:  --mnk_mode=true  (add to launch args)
  Defaults: WASD=left stick, Arrows=right stick, Space/;=A, Backspace/'=B,
            Enter/X=Start, Tab/Z=Back, Shift+Arrows=D-pad, Q/E=triggers, 1/3=shoulders
  (rebindable via keybind_* cvars in config, see src/input/mnk/mnk_input_driver.cpp)
- PS5 DualSense: works over plain USB-C cable (NO bluetooth dongle needed); SDL picks
  it up automatically via input_backend=sdl.
- When a crash dialog appears: read address from newest log (or send it to Cline) ->
  add "0xADDR" = {} to manifest -> rebuild -> relaunch.

## BOOT BARRIERS CLEARED (28 boundaries in manifest as of last check)
Phase 1 (early boot): 0x82579CD0, 0x82096340, 0x82090860, 0x8258E5E0, 0x82096350,
  0x820A8860, 0x820AE1B8, 0x820AE808, 0x82090840, 0x82094480, 0x8246D320
Phase 2 (past logo): 0x8223D4B0, 0x8222FC60, 0x8222FC70
Phase 3 (to title screen): 0x82117E10, 0x82117E18, 0x8212CBE0 (attract/replay switch)

## NOTABLE FACTS / TIMING
- Crash timing climbs as we clear barriers: +30s -> +59s -> ... (run window bumped to 75s)
- Codegen runs automatically on manifest change (itc_recomp_codegen cmake target).
- Build is incremental: ~40s (a few partitions + link).
- Debug build only (win-amd64-debug). Release would be much faster than 10-15 fps.
- Manifest: D:\ITC-Recomp\itc_recomp_manifest.toml ; generated register:
  D:\ITC-Recomp\generated\default\itc_recomp_register.cpp (SetFunction lines)

## NEXT STEPS
1. Keep the loop running; each barrier = deeper boot.
2. Watch for: boundaries already registered but still FATAL (script stops -> needs manual
   analysis, e.g. function needs a real body/stub instead of auto-generated one).
3. If a stable boot is reached, try --config Release for fps.
4. If crash points cluster in one region (e.g. 0x8222FCxx), that's a callback/vtable
   table — may be worth registering the whole range at once.


## STATUS (2026-10-12): BOOTS TO UBISOFT LOGO. ~10-15 FPS (Debug build).
## Then: "Debug Error! abort() has been called" (guest called abort/assert).
## Window is 1920x1080. GPU/audio/input all init fine.

## CURRENT BLOCKER
Guest code calls abort() (its own assert/abort) sometime around/after the Ubisoft
logo splash. Need to find WHERE in guest code the abort happens. Next step: run
under debugger OR add trace logging around the abort path to get the guest call
stack / which sub_XXXX is executing when abort() fires.

## APPROACHES TO TRY (in order)
1. Re-run and IMMEDIATELY note any trace/warn log lines right before abort.
2. Build a Release config (much faster, ~full speed) - rexglue preset win-amd64-release.
3. To locate the aborting guest function: attach debugger (F5 via VS) and read the
   call stack when abort fires; or set a breakpoint on the abort import.
4. Common cause: game asserts on an unimplemented/misbehaving emulated API (audio,
   filesystem, network, or a return value it doesn't like). The 'ShaderDumpxe:'
   [no device] VFS warning may also matter if the game asserts on missing FS.

## PERFORMANCE NOTE
10-15 FPS is Debug build only. Release build is typically 5-10x faster and is the
config that will actually be playable. Switch via CMake preset win-amd64-release.

## BARRIERS CLEARED THIS SESSION (added to manifest)
0x82579CD0, 0x82096340, 0x82090860, 0x8258E5E0, 0x82096350, 0x820A8860,
0x820AE1B8, 0x820AE808, 0x82090840, 0x82094480, 0x8246D320

## SOLVED THIS SESSION
- GPU plugin arg: correct value is `--gpu_plugin=xenos` (NOT `rexgpu-xenos`).
  The loader builds `rexgpu-<name><postfix>.dll`, so:
    xenos        -> rexgpu-xenosd.dll   (EXISTS, correct)
    rexgpu-xenos -> rexgpu-rexgpu-xenosd.dll (missing -> "Failed to load GPU plugin")
- Launch command (run from build dir):
    .\itc_recomp.exe --game_data_root "D:\ITC PC Project\Import Tuner Challenge (USA)" --gpu_plugin=xenos
- Logs go to: D:\ITC-Recomp\out\build\win-amd64-debug\logs\<name>_NNN.log (file-only, no console)
- SDK source: D:\Tools\rexglue-sdk  (read src/ui/rex_app.cpp, src/system/gpu_plugin_loader.cpp for internals)

## CURRENT BLOCKER
Boot barriers CLEARED. Game now boots fully (GPU/audio/input/shaders OK) with NO
FATAL, but the process exits/hangs shortly after the audio endpoint line, quietly
(no error in log). No window title captured. Need to find where it stops after audio.

## NEXT DIAGNOSTIC
Run with --log-level=trace to see guest activity right after audio init. Something
after audio setup either returns cleanly from main or blocks. Possible causes:
missing kernel import used later, a VFS device that isn't stubbed (ShaderDumpxe ->
[no device] warning seen), or an unimplemented callback. Trace will pinpoint it.

## BARRIERS CLEARED THIS SESSION (added to manifest)
0x82579CD0, 0x82096340, 0x82090860, 0x8258E5E0, 0x82096350, 0x820A8860,
0x820AE1B8, 0x820AE808, 0x82090840, 0x82094480, 0x8246D320

## AUTOMATION (running now)
D:\ITC-Recomp\autofix.ps1  - loop: build -> run 13s -> read newest log's last
[FATAL] address -> add to manifest -> repeat (max 120 iters). FATAL-first
detection (the FATAL pops a MODAL dialog that keeps process "responding", so we
do NOT trust process-responding). Live output: D:\ITC-Recomp\autofix_run.txt
Run it:  Start-Process powershell -ArgumentList '-ExecutionPolicy','Bypass','-File','D:\ITC-Recomp\autofix.ps1' -RedirectStandardOutput 'D:\ITC-Recomp\autofix_run.txt' -WindowStyle Hidden

## BARRIERS CLEARED SO FAR (added to manifest)
0x82579CD0, 0x82096340, 0x82090860, 0x8258E5E0, 0x82096350, ... (see manifest)

## IMPORTANT FACTS
- Generated sub_XXXX are REAL recompiled PPC bodies (not stubs), incl. tail-calls.
- Build is incremental: only 3 partitions + link recompile (~30-40s/iter).
- Codegen auto-runs on manifest change via itc_recomp_codegen custom target.
- register file: generated/default/itc_recomp_register.cpp  (SetFunction lines)
