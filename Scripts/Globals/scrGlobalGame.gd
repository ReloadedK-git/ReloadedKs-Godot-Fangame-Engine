extends Node


"""
Public variables, meant to be accessed and modified outside of this script
"""

# Misc
var is_changing_rooms: bool = false
var game_paused: bool = false
var time: float = 0.0
var deaths: int = 0

# Debug related variables and signals
var debug_mode: bool = false
var debug_godmode: bool = false
var debug_inf_jump: bool = false
var debug_hitbox: bool = false

# This fixes some issues with collision detection on moving platforms
const SNAPPING_GRID: int = 16

# These determine the damage for objPlayer's attacks, like bullets
var player_bullet_damage: int = 1
# var player_sword_damage: int = 4

# Global arrays
var triggered_events: Array = []
var dialog_events: Array = []

# For moving the player to a specific position after warping to a different room
var warp_to_point: Vector2 = Vector2.ZERO

# Global camera limits array
var global_camera_limits: Array = [0, 0, 0, 0]


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
var current_scene_name: String = ""
var cur_pause_menu: Node = null



func _ready():
	
	# Sets pause mode to not affect this world script
	process_mode = PROCESS_MODE_ALWAYS
	
	# Hides the mouse. Feel free to uncomment this if you want
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# The global functions we want to handle each frame
func _physics_process(delta):
	
	# Global time counter
	time_counter(delta)
	
	# Adds the time and deaths to the titlebar
	handle_titlebar()


# We use this to check what type of input device we're using, which in turn
# affects the way things like settings are shown
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if global_input_device != KEYBOARD:
			global_input_device = KEYBOARD
	
	if event is InputEventJoypadButton and event.is_pressed():
		if global_input_device != CONTROLLER:
			global_input_device = CONTROLLER
	
	if event.is_action_pressed("button_pause"):
		pause_game()
	
	if event.is_action_pressed("button_debug"):
		toggle_debug_mode()
	
	if event.is_action_pressed("button_music"):
		pause_music()
	
	if event.is_action_pressed("button_fullscreen"):
		GLOBAL_SETTINGS.FULLSCREEN = !GLOBAL_SETTINGS.FULLSCREEN
		GLOBAL_SETTINGS.set_window_mode()
	
	if event.is_action_pressed("button_fullgame_restart"):
		full_game_restart()
	
	if event.is_action_pressed("button_quitgame"):
		game_quit()
	
	# Resetting is more complex, as it needs to make a few checks before
	# the reset key is even pressed
	handle_resetting(event)


# A global pause which adds/removes a pause menu instance
func pause_game() -> void:
	
	# As long as we're not on menu rooms
	if is_valid_room():
		
		# Gets all "Pause" nodes (the pause menus we need). Loads and
		# instantiates them afterwards
		if get_tree().get_nodes_in_group("Pause").size() < 1:
			var pause_menu := preload("res://Objects/UI/objPauseMenuMain.tscn")
			cur_pause_menu = pause_menu.instantiate()
			add_child(cur_pause_menu)
			GLOBAL_SOUNDS.play_sound("sndPause")


# If [param to_scene] is supplied and ends in `.tscn`, it will attempt to 
# change to this scene instead of the main scene.
func full_game_restart(to_scene: String = "") -> void:
	if is_valid_room():

		# If the scene we're on is not the initial project's scene, we change
		# our current scene to it, essentially working as a game reset.
		if to_scene and to_scene.ends_with(".tscn"):
			
			# At the moment, this is only called from `scrPauseMenuMain`,
			# passing the `main_menu` scene, which differs from the actual main scene.
			if get_tree().get_current_scene().name != to_scene.trim_suffix(".tscn"):
				get_tree().change_scene_to_file(to_scene)
		else:
			# We get the main scene from our project settings. To compare the name,
			# we get the setting, then the file name and then we trim the ".tscn" suffix
			if (get_tree().get_current_scene().name != ProjectSettings.get_setting("application/run/main_scene").get_file().trim_suffix(".tscn")):
				get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
		
		# This is to restart everything even if the game is currently paused.
		# I like it that way, but maybe a cleaner way is to not allow a full
		# game restart when paused. Still, feel free to press F2 after pausing
		# and it will work the way it should
		if (game_paused):
			
			# Frees every "Pause" node (pause menus), unsets the global pause
			# and sets it to false for this autoload as well
			var pause_nodes = get_tree().get_nodes_in_group("Pause")
			for pause_menus in pause_nodes:
				pause_menus.queue_free()
			get_tree().set_pause(false)
			game_paused = false
		
		# Clear/reset our global arrays
		triggered_events.clear()
		dialog_events.clear()
		
		# Clear itemsGameData. We don't save collectables when making a full
		# game restart
		GLOBAL_SAVELOAD.itemsGameData.clear()


# Toggles debug mode on/off. 
# Debug mode affects objPlayer, making it invincible and able to get teleported
# to the mouse with a special key. Also affect objHUD, which will draw some
# debug data and show a sprite on the mouse position, indicating that objPlayer
# can get teleported. Check objPlayer's debug_mouse_teleport() method
func toggle_debug_mode() -> void:
	debug_mode = !debug_mode
	
	# Plays a sound effect to indicate debug mode is on
	if debug_mode:
		GLOBAL_SOUNDS.play_sound("sndWarp") 

# Pauses music using a keyboard shortcut
func pause_music() -> void:
	music_is_playing = !music_is_playing


# The "R" key. Resets the game if certain conditions are met
func handle_resetting(reset_key) -> void:
	
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
	if reset_key.is_action_pressed("button_reset") and (can_reset):
		reset()


# Conditionless reset. Call this to reset directly, without any kind of
# previous requirement (other than a savefile to read from)
func reset():
	
	# Sets global camera limits from the savefile. Handles an edge case with
	# camera movers, warping and resetting
	GLOBAL_GAME.global_camera_limits = GLOBAL_SAVELOAD.variableGameData.global_camera_limits
	
	# A reset is essentially taking the main tree scene and then changing
	# it to the one that's saved inside of our saveload dictionary (check
	# scrGlobalSaveload)
	get_tree().change_scene_to_file(GLOBAL_SAVELOAD.variableGameData.room_name)
	
	# Clear/reset our global trigger array
	triggered_events.clear()
	
	# Saves time and deaths
	GLOBAL_SAVELOAD.save_game(false)
	
	# Resets objHUD's notifications, needed due to it being an autoload
	reset_HUD()
	
	# Clears the item dictionary, avoiding the use of a reset to safely save
	# an item
	GLOBAL_SAVELOAD.itemsGameData.clear()


# Fully quits the game (alt + F4)
func game_quit() -> void:
	get_tree().quit()


# Checks the current scene/room's name. We use this to make sure we're not
# doing things like restarting or pausing on menu related scenes
func is_valid_room():
	
	# We also need to check if our scene tree is not null. Only then it gets
	# its name (needed for godot v4.2 onwards)
	if get_tree().get_current_scene() != null:
		current_scene_name = get_tree().get_current_scene().name
		
		match current_scene_name:
			"rTitle":
				return false
			"rMenuMain":
				return false
			"rMenuFiles":
				return false
			"rMenuSettings":
				return false
			"rMenuControls":
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


# Stops the HUD from showing the item/collectable
func reset_HUD() -> void:
	if is_instance_valid(objHUD):
		objHUD.container_timer.stop()
		objHUD.item_container.set_visible(false)


# Global time counter
func time_counter(delta):
	if !game_paused and is_valid_room():
			time += delta
	


# Takes a time parameter and returns it as a formatted string
func format_time(time_to_format):
	
	var hours   = floor((time_to_format / 60) / 60);
	var minutes = floor(fmod(time_to_format / 60.0, 60));
	var seconds = floor(fmod(time_to_format, 60.0));
	
	return ("%02d" % hours) + ":" + ("%02d" % minutes) + ":"+("%02d" % seconds).right(2)


# Adds death/time to the title.
func handle_titlebar():
	if not is_valid_room():
		get_window().title = ProjectSettings.get_setting("application/config/name")
		return
	
	# Game name
	var title = ProjectSettings.get_setting("application/config/name") + " -"
	
	# Time
	var time_str = " Time: " + format_time(time) + " -"
	title += time_str
	
	# Death counter
	var deaths_str = " Deaths: " + str(deaths)
	title += deaths_str
	
	get_window().title = title
