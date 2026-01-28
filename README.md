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
* Added several block-based gimmicks (***objFadingBlock, objBouncyBlock, objSpikeBlock***, ***tilSheepBlocks***).
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

*Special thanks to Gaph and her fork of this engine for the many QOL improvements and observations, some of which became part of this update.*

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

### v1.11 (30-12-2024)

* Engine ported to Godot v4.3.
* Fixed issues with ***scrGlobalSaveload*** after updating to Godot v4.3.
* Fixed issues with ***objJumpSwitchSpike*** and ***objTriggerBlock*** when parent node position changes (credits to *Gaph*).
* Added distance_to_hidden parameter to ***JumpSwitchSpike*** (credits to *Gaph*).
* Changed every *TileMap* node to *TileMapLayer*.
* Fixed a bug with platforms and water, to properly check if the player is or is not colliding with them.
* Added platform snapping (check ***objPlayer***).
* Added a *"snap"* property to ***objMovingPlatform***.
* Minor fixes to ***objMenuControls***.
* Minor fixes to ***scrPauseMenuMain*** and ***scrMenuSettings***.
* Locked several nodes for ease of editing (***objTriggerBlock***, ***objTrigger***, ***objMultiTrigger***, ***objWater***).
* ***objWater*** is now made of polygons, for ease of use when editing.
* Added a *"Water Type"* property for ***objWater***, allowing it to switch between the 3 classic water types (regular, refresh, catharsis).
* Added new functionality to ***objPlayer*** regarding water and platforms.
* ***objTrigger*** and ***objMultiTrigger*** are now made of polygons, for ease of use when editing.
* Minor changes to some testing rooms.
* Added debug activation sounds to ***objPlayer***.
* The cursor will no longer be hidden by default (check ***scrGlobalGame***).

### v1.12 (01-11-2025)

* Reworked ***objPlayer*** from scratch. It makes use of a limited state machine, which makes it more flexible and easier to work with.
* Added "climbing" gimmick to ***objPlayer***.
* Reworked platform snapping.
* Renamed "d_jump_aux" to "inside_platform_jump" for ***objPlayer***.
* Jump height while colliding with a moving platform is now equal to a single jump.
* Reworked player interactions with ***objWater***.
* Minor fixes to ***objBullet***.
* Added ***objParticlesManager***. Replaces ***scrGlobalParticles***. Makes adding and loading particle materials easier.
* Changed ***objSoundManager***. Removed unnecessary preloads and made syntax simpler.
* Multiple objects changed due to the new sound system.
* Deleted ***objPhysicsBox***, ***scrPhysicsBox*** and ***sprPhysicsBox***.
* Added ***objJumpBlock***.
* Minor fixes to ***scrCollisionDialogueSpawner***.
* Minor fixes to ***objLaserDynamic***.
* Minor changes to ***tilSheepBlocks*** and ***objFadingBlock***.
* Added ***objOrbitController***. Works with ***objCherry*** and ***objMovingPlatform***.
* Added ***objPathSaw***.
* Added ***objPathPlatform***.
* Added ***objFan***.
* Added ***tilClimbSurface***.
* Added ***objCoinManager***.
* Changed ***objCoin***.
* Added ***objFakeBlock***.
* Added ***objCameraMover***.
* Added new room (***rTestRoom05***).
* Minor changes to several test rooms.
* Changed ***rTemplate***.
* Minor changes to ***objTitle***.
* Added clamp to window scaling (credits to *Polarb*).
* Added warnings to ***objCameraDynamic*** and ***objCameraFixed***.
* Minor changes to ***objCameraDynamic***.
* Removed "Extra buttons" from the settings menu.
* Removed EXTRA_KEYS from ***scrGlobalSettings***, ***scrGlobalSaveload*** and ***objSign***.
* Removed extra directional keys from project settings. Added new input actions for regular directional keys.
* Fixed input bugs for ***scrPauseMenu***, ***scrMenuSettings***, ***scrMenuMain***, ***scrMenuFiles*** and ***objPlayer***.
* Minor fixes to ***scrMenuSettings*** and ***scrPauseMenu***.
* Added camera related changes to ***scrMenuFiles***.
* Camera border limits are now saved.
* Added global camera limit variable into ***scrGlobalGame***.

### v1.13 (01-01-2026)

* Several changes and fixes to ***objPlayer***.
* ***objPlayer***'s sprite and mask rotation is now handled independently of its velocity values.
* ***objPlayer***'s velocity is now handled by a method which uses separate velocity vectors.
* Added ***tilIce*** and ice physics for ***objPlayer***.
* Reworked wind physics for ***objPlayer***.
* Jumping inside a platform now gives back d_jump to ***objPlayer***.
* Fixed ***objPlayer***'s "on_death" method counting many deaths when dying multiple times on a single frame.
* Fixed bug with ***objPlayer*** in which resetting would always start its sprite as idle.
* Added extra "ON_CREATION" state to ***objPlayer***.
* Changed water falling speed values for ***objPlayer***.
* Changes in ***objPauseMenuMain***.
* Minor changes to ***objInvisibleBlock***.
* Minor changes to ***objBullet***.
* Minor changes to ***objBouncyBlock***.
* Minor changes to ***objJumpSwitchSpike***.
* Minor changes to ***objJumpBlock***.
* Changed ***objFan*** so it works with the new wind physics.
* Changed ***objFan***'s sprite.
* Changes process priority for ***objCameraDynamic*** and ***objCameraFixed***.
* Changes to ***objSignProximity***.
* Small fix to ***objCollisionDialogSpawner***.
* Changed collision shape ordering for some objects.
* Deleted "onScreenNotifier" node from several objects, as it wasn't as necessary for most use cases.
* Deleted ***objPlayerOld*** (no longer supported, but you can still add it back copying it from the previous version).
* Limited "max_fps" to 60 from project settings.
* Disabled vsync by default.
* Added "player_initial_sprite" to ***scrGlobalSaveload***.
* Added ***scrGlobalSignals*** (GLOBAL_SIGNALS autoload).

### v1.14 (28-01-2026)

* Added 4 types of horizontal input modes for the ***objPlayer***.
* Reworked masks for ***objPlayer*** (credits to *RndGuy*).
* Fixed bug with ***objPlayer***'s walljumping (credits to *TheHamester*).
* Fixed bug with ***objPlayer***'s masks not getting oriented on creation.
* Fixed a small bug when d_jump was not recovered if jumping exactly on the same frame as landing.
* Minor changes and additions to ***objPlayer***.
* Fixed bug with ***objCameraFixed*** which didn't scroll correctly if ignore_global_zoom was enabled.
* Added ***objParticlesManager*** as an autoload.
* Minor fix for ***objJumpParticle***.
* Added classic fangame death music, with proper credits.
* Added new death music related settings in ***scrGlobalGame***.
* Removed zoom scaling setting from the options menu.
* Added debug key for zooming to the engine's input map.
* Debug functions now require "Ctrl + function_key" to work.
* Changed setting order for ***objPauseMenuMain***.
* Added ***objRoomWrapper***.
* Added several death music types to ***scrGlobalGame***.
* Removed debug action and setting to pause music.
* Added ***objScreenShake***, ***scrScreenShake*** and ***shScreenShake***.
* Reworked ***objSavePoint***.
