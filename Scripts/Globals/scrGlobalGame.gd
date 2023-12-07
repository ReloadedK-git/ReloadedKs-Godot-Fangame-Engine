extends Node

"""
Public variables, meant to be accessed and modified outside of this script
"""
var debug_mode: bool = false
var is_changing_rooms: bool = false
var game_paused: bool = false

# This fixes some issues with collision detection on moving platforms
const SNAPPING_GRID: int = 16

# These determine the damage for objPlayer's attacks, like bullets
var player_bullet_damage: int = 1
# var player_sword_damage: int = 4

# The global trigger array
var triggered_events: Array = []

# For moving the player to a specific position after warping to a different room
var warp_to_point: Vector2 = Vector2.ZERO


"""
Public readonly variables, meant to be accessed but not modified outside of this script
"""
var can_reset: bool = false
var music_is_playing: bool = true
enum {KEYBOARD, CONTROLLER}
var global_input_device = KEYBOARD


"""
Private variables, meant to be handled only by this script
"""
# Window related variables. These don't really change, but can't be constants
# since they need to get their values first from a couple functions.
var INITIAL_WINDOW_WIDTH: int = DisplayServer.window_get_size().x
var INITIAL_WINDOW_HEIGHT: int = DisplayServer.window_get_size().y
var INITIAL_WINDOW_XPOSITION: int = DisplayServer.window_get_position().x
var INITIAL_WINDOW_YPOSITION: int = DisplayServer.window_get_position().y

var current_scene_name: String = ""
var pause_menu := preload("res://Objects/UI/objPauseMenu.tscn")
var cur_pause_menu: Node = null


func _ready():
	
	# Sets pause mode to not affect this world script
	process_mode = PROCESS_MODE_ALWAYS
	
	# Hides the mouse. A visual preference, so feel free to delete this if you
	# want
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)



# The global functions we want to handle each frame. They're self contained
# and should only fire once or be toggled on and off
func _physics_process(_delta):
	
	if Input.is_action_just_pressed("button_debug"):
		toggle_debug_mode()
	
	if Input.is_action_just_pressed("button_music"):
		pause_music()
	
	if Input.is_action_just_pressed("button_pause"):
		pause_game()
	
	if Input.is_action_just_pressed("button_fullscreen"):
		toggle_fullscreen()
	
	if Input.is_action_just_pressed("button_fullgame_restart"):
		full_game_restart()
	
	if Input.is_action_just_pressed("button_quitgame"):
		game_quit()
	
	# Resetting is more complex, as it needs to make a few checks before
	# the reset key is even pressed
	handle_resetting()


# We use this to check what type of input device we're using, which in turn
# affects the way things like settings are shown
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if global_input_device != KEYBOARD:
			global_input_device = KEYBOARD
	
	if event is InputEventJoypadButton and event.is_pressed():
		if global_input_device != CONTROLLER:
			global_input_device = CONTROLLER


# A global pause which adds/removes a pause menu instance
func pause_game() -> void:
	
	# If not on menus
	if is_valid_room():
		
		# Pause/unpause scene tree
		get_tree().paused = !get_tree().paused
		game_paused = !game_paused
		
		# If we are paused, spawn the pause menu object
		if (game_paused): 
			cur_pause_menu = pause_menu.instantiate()
			add_child(cur_pause_menu)
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)
		else:
			
			# Saves settings data, since we can change the game's volume from
			# this pause menu as well
			GLOBAL_SETTINGS.MUSIC_VOLUME = cur_pause_menu.music_volume
			GLOBAL_SETTINGS.SOUND_VOLUME = cur_pause_menu.sound_volume
			GLOBAL_SETTINGS.save_settings()
			
			# Then delete the pause menu
			cur_pause_menu.queue_free()


# Toggles fullscreen on/off. When toggled from fullscreen to windowed, it
# remembers the initial width/height and sets its initial position (centered)
func toggle_fullscreen() -> void:
	GLOBAL_SETTINGS.FULLSCREEN = !GLOBAL_SETTINGS.FULLSCREEN
	GLOBAL_SETTINGS.set_window_mode()


# A full game restart. Goes back to the main menu
func full_game_restart() -> void:
	if is_valid_room():
		
		# If the scene we're on is not the initial project's scene, we change
		# our current scene to it, essentially working as a game reset.
		# We get the main scene from our project settings. To compare the name,
		# we get the setting, then the file name and then we trim the ".tscn" suffix
		if (get_tree().get_current_scene().name != ProjectSettings.get_setting("application/run/main_scene").get_file().trim_suffix(".tscn")):
			get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
		
		# This is to restart everything even if the game is currently paused.
		# I like it that way, but maybe a cleaner way is to not allow a full
		# game restart when paused. Still, feel free to press F2 after pausing
		# and it will work the way it should
		if (game_paused):
			cur_pause_menu.queue_free()
			get_tree().set_pause(false)
			game_paused = !game_paused
		
		# Clear/reset our global trigger array
		triggered_events.clear()


# Toggles debug mode on/off. 
# Debug mode affects objPlayer, making it invincible and able to get teleported
# to the mouse with a special key. Also affect objHUD, which will draw some
# debug data and show a sprite on the mouse position, indicating that objPlayer
# can get teleported. Check objPlayer's debug_mouse_teleport() method
func toggle_debug_mode() -> void:
	debug_mode = !debug_mode


# Pauses music using a keyboard shortcut
func pause_music() -> void:
	music_is_playing = !music_is_playing


# The "R" key. Resets the game if certain conditions are met
func handle_resetting() -> void:
	
	# We check what room we're in, to not reset inside of menus
	if is_valid_room():
		
		# We then check if the game isn't in a paused state
		if !game_paused:
			
			# If all conditions are met, we can reset. If they're not, we
			# make sure we can't reset by setting the variable to false
			can_reset = true
		else:
			can_reset = false
	else:
		can_reset = false
	
	# To avoid R spamming, we check for a single-frame press. As long as we're
	# allowed to reset and we press the proper button, we will reset
	if Input.is_action_just_pressed("button_reset") and (can_reset):
		reset()


# Conditionless reset. Call this to reset directly, without any kind of
# previous requirement (other than a savefile to read from)
func reset():
	
	# A reset is essentially taking the main tree scene and then changing
	# it to the one that's saved inside of our saveload dictionary (check
	# scrGlobalSaveload)
	get_tree().change_scene_to_file(GLOBAL_SAVELOAD.variableGameData.room_name)
	
	# Clear/reset our global trigger array
	triggered_events.clear()


# Fully quits the game (alt + F4)
func game_quit() -> void:
	get_tree().quit()


# Sets vsync. Called from the settings menu
func set_vsync():
	GLOBAL_SETTINGS.VSYNC = !GLOBAL_SETTINGS.VSYNC
	GLOBAL_SETTINGS.set_vsync_mode()


# Checks the current scene/room's name. We use this to make sure we're not
# doing things like restarting or pausing on menu related scenes
func is_valid_room():
	
	# We also need to check if our scene tree is not null. Only then it gets
	# its name (needed for godot v4.2 onwards)
	if get_tree().get_current_scene() != null:
		current_scene_name = get_tree().get_current_scene().name
		
		match current_scene_name:
			"rMainMenu":
				return false
			"rSettingsMenu":
				return false
			"rControlsMenu":
				return false
			_:
				return true


# Returns a string of text, according to our input device.
# If we use a keyboard, we remove " (Physical)"
# If we use a controller, we just change the entire thing because it looks
# ugly as hell either way. Rebindable controls be damned.
func get_input_name(button_id, input_device):
	
	# Keyboard
	if input_device == KEYBOARD:
		return str(InputMap.action_get_events(button_id)[input_device].as_text().trim_suffix(" (Physical)"))
	
	# Controller
	if input_device == CONTROLLER:
		return str(InputMap.action_get_events(button_id)[input_device].as_text().trim_prefix("Joypad ").left(9).trim_suffix(" "))
