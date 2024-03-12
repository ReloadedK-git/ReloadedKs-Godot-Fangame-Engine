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
var EXTRA_KEYS: bool = false

# Default values, for when you need to reset them from the settings menu
const DEFAULT_MUSIC_VOLUME: float = 1.0
const DEFAULT_SOUND_VOLUME: float = 1.0
const DEFAULT_FULLSCREEN: bool = false
const DEFAULT_ZOOM_SCALING: float = 1.0
const DEFAULT_HUD_SCALING: float = 1.0
var DEFAULT_WINDOW_SCALING: float = calc_default_window_scale()
const DEFAULT_VSYNC: bool = true
const DEFAULT_AUTORESET: bool = false
const DEFAULT_EXTRA_KEYS: bool = false

# Window related variables, for handling window modes
var INITIAL_WINDOW_WIDTH: int = DisplayServer.window_get_size().x
var INITIAL_WINDOW_HEIGHT: int = DisplayServer.window_get_size().y



func _ready():
	var dir = DirAccess.open("user://")
	
	# If, for any reason, the Data directory doesn't exist, it creates it
	if not dir.dir_exists("user://Data"):
		dir.make_dir("Data")
	
	# If the settings file doesn't exist, it creates it. If it does exist, it
	# loads it
	if not dir.file_exists(DATA_PATH):
		WINDOW_SCALING = calc_default_window_scale() # since one default is calculated
		save_settings()
	else:
		load_settings()



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
	configFile.set_value("settings", "extra_keys", EXTRA_KEYS)
	
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
	EXTRA_KEYS = configFile.get_value("settings", "extra_keys", EXTRA_KEYS)
	
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
	EXTRA_KEYS = DEFAULT_EXTRA_KEYS
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(MUSIC_VOLUME))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear_to_db(SOUND_VOLUME))
	
	# Calls the window and vsync mode functions after setting them to their
	# default states
	set_window_mode()
	set_vsync_mode()
	
	# Sets HUD scaling by calling objHUDs method once
	if is_instance_valid(objHUD):
		objHUD.set_HUD_scaling()

# Calculates the default window scale based on current monitor resolution
func calc_default_window_scale():
	var monitor = DisplayServer.screen_get_size()
	# 1080p: 1.0x
	# 1440p: 1.5x
	# 4k: 2.0x
	if monitor.y < 1440:
		return 1.0
	elif monitor.y < 2160:
		return 1.5
	return 2.0
	

# Sets the game's window mode by checking the FULLSCREEN boolean
func set_window_mode():
	if FULLSCREEN == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# DisplayServer.window_set_size(Vector2(INITIAL_WINDOW_WIDTH, INITIAL_WINDOW_HEIGHT))
		set_window_scale()


# Sets the game's vsync mode by checking the VSYNC boolean
func set_vsync_mode():
	if VSYNC == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# Sets the window scaling
func set_window_scale():
	var newSize = Vector2(INITIAL_WINDOW_WIDTH * WINDOW_SCALING, INITIAL_WINDOW_HEIGHT * WINDOW_SCALING)
	var oldSize = Vector2(DisplayServer.window_get_size())
	# Check to avoid recentering when not changing scale
	if oldSize != newSize:
		DisplayServer.window_set_size(newSize)
		recenter_screen()

# Recenter the screen
func recenter_screen():
	var scr_size = DisplayServer.screen_get_size()
	var win_size = DisplayServer.window_get_size()
	var scr_pos = DisplayServer.screen_get_position() # for multi-monitor
	DisplayServer.window_set_position((scr_size - win_size) / 2 + scr_pos)
