# ITC-Recomp - Import Tuner Challenge PC Port

## For Friends - Just Run the Game!

1. **Double-click `launch_game.bat`** to start the game
2. The game data is already bundled in the `game/` folder — no setup needed!

## Folder Structure

```
ITC-Recomp-Dist/
├── launch_game.bat          ← Double-click to play!
├── README.txt               ← This file
├── itc_recomp_manifest.toml ← Function registry (all crash addresses)
├── apply_code_patches.ps1   ← Post-codegen black-screen fix
├── CMakeLists.txt           ← Build configuration
├── PROGRESS.md              ← Development progress log
├── bin/                     ← Executable + DLLs (ready to run)
│   ├── itc_recomp.exe
│   ├── rexgpu-xenos.dll
│   ├── rexruntime.dll
│   ├── TracyClient.dll
│   └── logs/               ← Auto-created at runtime
├── game/                    ← Game data (bundled)
│   ├── default.xex
│   ├── DATA/
│   └── $SystemUpdate/
├── generated/default/       ← Source files (reference only)
│   ├── itc_recomp_init.cpp
│   ├── itc_recomp_register.cpp
│   ├── itc_recomp_recomp.0-91.cpp
│   └── *.h files
└── src/
    ├── main.cpp
    └── itc_recomp_app.h
```

## Controls (Keyboard Mode)

- **W/S** or **Up/Down** - Navigate menus
- **Enter** - Confirm
- **Escape** - Back/Cancel
- **O** - Right trigger (accelerate)
- **Q** - Left trigger (brake)
- **W, I, S** - Trigger modifiers

## Known Fixes Applied

1. **0x822590E8** - Fixed crash when backing out of Time Attacks Records
2. **0x8222FC80** - Fixed crash when entering garage from parking area
3. **0x8218E4EC** - Fixed black screen after race (loading threshold 60→10)
