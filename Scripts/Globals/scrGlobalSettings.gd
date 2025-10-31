extends Node

const DATA_PATH := "user://Data/Settings.cfg"

#const SAVE_PASSWORD_STRING := "Change me!"
var MUSIC_VOLUME: float = 1.0
var SOUND_VOLUME: float = 1.0
var FULLSCREEN: bool = false
var ZOOM_SCALING: float = 1.0
var HUD_SCALING: float = 1.0
var WINDOW_SCALING: float = 1.0
var VSYNC: bool = true
var AUTORESET: bool = false

# Default values, for when you need to reset them from the settings menu
const DEFAULT_MUSIC_VOLUME: float = 1.0
const DEFAULT_SOUND_VOLUME: float = 1.0
const DEFAULT_FULLSCREEN: bool = false
const DEFAULT_ZOOM_SCALING: float = 1.0
const DEFAULT_HUD_SCALING: float = 1.0
const DEFAULT_WINDOW_SCALING: float = 1.0
const DEFAULT_VSYNC: bool = true
const DEFAULT_AUTORESET: bool = false

# Window related variables, for handling window modes
@onready var INITIAL_WINDOW_WIDTH: int = get_window().size.x
@onready var INITIAL_WINDOW_HEIGHT: int = get_window().size.y



func _ready():
	var dir = DirAccess.open("user://")
	
	# If, for any reason, the Data directory doesn't exist, it creates it
	if not dir.dir_exists("user://Data"):
		dir.make_dir("Data")
	
	# If the settings file doesn't exist, it creates it. If it does exist, it
	# loads it
	if not dir.file_exists(DATA_PATH):
		save_settings()
	else:
		load_settings()
	
	# Recenters the window after a timer. Kind of a hack, but needed for
	# window scaling other than 1x
	await get_tree().create_timer(0.025, false, true).timeout
	get_window().move_to_center()



# Saves settings
func save_settings() -> void:
	var configFile := ConfigFile.new()
	
	configFile.set_value("volume", "music_volume", MUSIC_VOLUME)
	configFile.set_value("volume", "sound_volume", SOUND_VOLUME)
	configFile.set_value("settings", "fullscreen", FULLSCREEN)
	configFile.set_value("settings", "zoom_scaling", ZOOM_SCALING)
	configFile.set_value("settings", "hud_scaling", HUD_SCALING)
	configFile.set_value("settings", "window_scaling", WINDOW_SCALING)
	configFile.set_value("settings", "vsync", VSYNC)
	configFile.set_value("settings", "autoreset", AUTORESET)
	
	for action in InputMap.get_actions():
		configFile.set_value("controls", action, InputMap.action_get_events(action))
	
	configFile.save(DATA_PATH)


# Load and set settings
func load_settings() -> void:
	var configFile: = ConfigFile.new()
	configFile.load(DATA_PATH)
	
	MUSIC_VOLUME = configFile.get_value("volume", "music_volume", MUSIC_VOLUME)
	SOUND_VOLUME = configFile.get_value("volume", "sound_volume", SOUND_VOLUME)
	FULLSCREEN = configFile.get_value("settings", "fullscreen", FULLSCREEN)
	ZOOM_SCALING = configFile.get_value("settings", "zoom_scaling", ZOOM_SCALING)
	HUD_SCALING = configFile.get_value("settings", "hud_scaling", HUD_SCALING)
	WINDOW_SCALING = configFile.get_value("settings", "window_scaling", WINDOW_SCALING)
	VSYNC = configFile.get_value("settings", "vsync", VSYNC)
	AUTORESET = configFile.get_value("settings", "autoreset", AUTORESET)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear_to_db(SOUND_VOLUME))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(MUSIC_VOLUME))
	
	# Applies window and vsync mode
	set_window_mode()
	set_vsync_mode()
	
	# Controls
	for action in configFile.get_section_keys("controls"):
		InputMap.action_erase_events(action)
		for event in configFile.get_value("controls", action):
			InputMap.action_add_event(action, event)


# Resets and sets settings to their default values
func default_settings() -> void:
	
	MUSIC_VOLUME = DEFAULT_MUSIC_VOLUME
	SOUND_VOLUME = DEFAULT_SOUND_VOLUME
	FULLSCREEN = DEFAULT_FULLSCREEN
	ZOOM_SCALING = DEFAULT_ZOOM_SCALING
	HUD_SCALING = DEFAULT_HUD_SCALING
	WINDOW_SCALING = DEFAULT_WINDOW_SCALING
	VSYNC = DEFAULT_VSYNC
	AUTORESET = DEFAULT_AUTORESET
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(MUSIC_VOLUME))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear_to_db(SOUND_VOLUME))
	
	# Calls the window and vsync mode functions after setting them to their
	# default states
	set_window_mode()
	set_vsync_mode()
	
	# Sets HUD scaling by calling objHUDs method once
	if is_instance_valid(objHUD):
		objHUD.set_HUD_scaling()


# Sets the game's window mode by checking the FULLSCREEN boolean
func set_window_mode():
	if FULLSCREEN:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
		set_window_scale()


# Sets the game's vsync mode by checking the VSYNC boolean
func set_vsync_mode():
	if VSYNC:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


# Sets the window scaling. Also clamps it to the screen size
func set_window_scale():
	
	# Only updates the scaling in windowed mode. Avoids redrawing and stutters
	# in certain OS
	if get_window().get_mode() == 0:
		var new_size = Vector2(INITIAL_WINDOW_WIDTH * WINDOW_SCALING, INITIAL_WINDOW_HEIGHT * WINDOW_SCALING)
		var SCREEN_SIZE = DisplayServer.screen_get_size(get_window().get_current_screen())
		new_size.x = min(new_size.x, SCREEN_SIZE.x)
		new_size.y = min(new_size.y, SCREEN_SIZE.y)
		get_window().size = new_size
