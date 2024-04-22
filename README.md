# ReloadedK's Godot Fangame Engine

A Godot 4.x fangame engine, created by ReloadedK.

Project started with Godot v4.0.2, which can be adquired at https://godotengine.org/

You can check the [engine's documentation](https://github.com/ReloadedK-git/ReloadedKs-Godot-Fangame-Engine-Docs/blob/main/00_start.md).

---

# Change-log

### v1.0 (09-07-2023)

* Initial release.

### v1.1 (10-07-2023)

* Updated to work with Godot 4.1.
* Changed default renderer to ***Compatibility***.
* Changed ***objMovingPlatform*** and ***objMovingBlock***.
* Minor change to ***objHUD***.

### v1.2 (09-09-2023)

* Window position is kept when switching from windowed to fullscreen mode.

### v1.3 (30-09-2023)

* Changed ***objInvisibleBlock***.
* Slightly reduced volume for ***sndBlockChange***.

### v1.4 (23-10-2023)

* Numpad arrows and controller stick can be used to control the player or interact with different objects, if the setting is toggled on.
* Added an "extra keys" option in the settings menu.
* Added extra functionality to the player (movement, walljumping) and dialog sign (interaction).
* Added extra actions in the input map.

### v1.5 (24-10-2023)

* Small fix for the player script. The input for the controller stick doesn't need to go all the way to get detected.

### v1.6 (07-12-2023)

* Engine ported to Godot v4.2 while maintaining compatibility with older versions.
* Modified ***objPlayer***. The xscale variable is now a boolean instead of a float. The function ***set_first_time_saving()*** is called from ***_physics_process()*** due to v4.2's changes.
* Jump particles generated from the player now use a timer to free themselves.
* Save points don't autostart their timers by default.
* Renamed some variables for ***objInvisibleBlock*** so they don't conflict with engine variable names.
* Modified ***objWarp***'s script to be compatible with v4.2.
* ***objHUD***'s debug mode mouse pointer now follows ***objPlayer***'s xscale, and is compatible with v4.2.
* Modified ***scrGlobalGame*** to work with v4.2.
* ***scrSettingsMenu*** now shows "Reset to Defaults" instead of "Reset".
* FileSystem folders are now colored.

### v1.7 (24-12-2023)

* Added multi-trigger system.
* Added a simpler, collision activated text sign.
* Modified ***objHUD*** and added a notification popup when finding items or collectables.
* Cameras and HUD can be scaled now.
* Added raycast-based lasers (static and dynamic).
* Very minor edits to ***objPlayer***
* Fixed a major bug with ***objCollectableItem***, and slightly changed the way it works due to ***objHUD***'s updates.
* ***objBackgroundMenus*** now uses a scroll shader.
* Both ***objCameraDynamic*** and ***objCameraFixed*** have been updated to work with the new camera zoom scaling.
* Changed the font for the triggers and made the text easier to read.
* Added extra settings to the settings menu (Camera Zoom and HUD Scaling).
* Updated the settings and controls menu to allow for infinite options, alongside visual improvements.
* Camera zoom is now 1x by default.
* Added new rooms (***rRoomSelection***, ***rTestRoom03***).
* Minor updates to several objects.

### v1.8 (09-01-2024)

* Added a new main menu room.
* Separated menus based on their individual functions (main menu, file selection menu, options menu, controls menu).
* Added a time and death counter for each file.
* Changed the text displayed on the file menu's options.
* Made visual changes to ***rRoomSelection***.
* Locked background scenes for some rooms, including menus.
* Added a new testing room ***rTestingRoom04***.
* Made small tweaks to ***objPlayer*** to make vertical speeds more accurate to traditional fangame physics (credits to RndGuy).
* ***objSavePoint*** now uses its entire 32x32p sprite as a collision area for bullets.
* Added a new background, shader, sound effect and sprites.
* Optimized several collision checking nodes.
* Added a new collision check for ***objPlayer*** (for sheep blocks).
* Optimized the way ***objWater***, ***objTrigger*** and ***objMultiTrigger*** works.
* Removed ***sprWater*** and ***sprTrigger***, since they were no longer necessary.
* Removed script for ***objWater***.
* Checked the "local to scene" property for ***objWater***, ***objTrigger***, ***objMultiTrigger*** and ***objSignProximity***.
* Added several block-based gimmicks (***objFadingBlock, objBouncyBlock, objSpikeBlock***, ***objSheepBlocks***).
* Added manual zooming to ***objCameraDynamic*** and ***objCameraFixed***.
* Added ***objCollisionDialogSpawner***.
* Added extra dialog scene for ***objCollisionDialogSpawner***.
* Made changes to ***scrGlobalGame*** and ***scrPauseMenu*** due to the new dialog spawner.
* Updated licenses and credits.

### v1.9 (01-02-2024)

* Fixed small visual bug for ***objLaserDynamic***.
* Added sprite for ***objFadingBlock*** which acts as a visual indicator.
* Added a "sound_stop" function to the sound manager.
* Minor changes to ***rMenuFiles*** (mostly sfx related).
* Camera scrolling for ***rMenuSettings*** and ***rMenuControls*** is now handled automatically.
* Changed ***objCollectableItem*** to work with the updated item saving system.
* Older savefiles are now compatible with newer ones.
* Changed the way items/collectables are handled.
* Items/collectables will remain "collected" even when changing rooms, but a save still needs to be performed to store them permanently.
* Changed ***scrGlobalGame*** to accomodate the new items/collectables and pause system.
* Added support for multiple pause menus/screens.
* Updated ***objPauseMenuMain***.
* Added ***objPauseMenuItems*** and ***objPauseItem***.
* Added support for title screens.
* Added new ***rTitle*** room.

### v1.10 (22-04-2024)

*Special thanks to Gaph and his fork of this engine for the many QOL improvements and observations, some of which became part of this update.*

* ***objWarpTransition*** no longer takes focus away from the mouse.
* ***scrGlobalSettings*** does not get reloaded after opening the pause menu.
* Window handling operations no longer use DisplayServer, fixing some window mode related bugs in different OS.
* ***objJumpSwitchSpike*** has been refactored.
* Added new debug-related functionality to ***objPlayer***.
* Added new debug-related visual information to ***objHUD***.
* Added window scaling and window scaling settings to ***rMenuSettings***.
* Added FPS display, time and death counters to the window title bar.
* Removed unnecessary functions in ***scrGlobalGame***.
* Minor changes to ***scrGlobalGame***.
* Minor changes to ***rMenuSettings***.
* Quitting to the main menu from the pause menu now behaves differently.
* Added new sound effect to ***objFadingBlock***.
