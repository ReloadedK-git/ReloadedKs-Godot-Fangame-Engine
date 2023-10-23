extends Control

@export_file("*.tscn") var main_menu: String
@export_file("*.tscn") var controls_menu: String

# Audio related (music, sounds)
@onready var music_bus: int = AudioServer.get_bus_index("Music")
@onready var sounds_bus: int = AudioServer.get_bus_index("Sounds")
var music_volume: float = 1.0
var sound_volume: float = 1.0
var volume_step: float = 0.1

# Toggleable variables (fullscreen, vsync, autoreset)
var fullscreen_on: bool = false
var vsync_on: bool = true
var autoreset_on: bool = false
var extra_keys_on: bool = false



func _ready():
	
	# Sets focus to the first option (music volume)
	$SettingsContainer/MusicVolume.grab_focus()
	
	# Global data settings loading at startup
	load_from_global_settings()
	
	# Sets and updates the text from each one of the button's labels
	set_labels_text()




# Key press checking (settings, quit)
func _physics_process(_delta):
	
	# Sets and updates the text from each one of the button's labels
	set_labels_text()
	
	# Goes back to the main menu if the "settings" key is pressed. Also plays 
	# a sound to indicate we changed rooms
	if Input.is_action_just_pressed("ui_select"):
		if main_menu != null:
			save_on_exit()
			get_tree().change_scene_to_file(main_menu)
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)
	
	# Re-updates fullscreen in case we press "F4" in the middle of the settings
	# menu
	fullscreen_on = GLOBAL_SETTINGS.FULLSCREEN

##################################################################################################################

# Music volume
func _on_music_volume_gui_input(_event):
	if Input.is_action_just_pressed("ui_right"):
		if (music_volume) < 0.99:
			music_volume += volume_step
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	
	if Input.is_action_just_pressed("ui_left"):
		if (music_volume - volume_step) > 0.0:
			music_volume -= volume_step
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))


# Sounds volume
func _on_sfx_volume_gui_input(_event):
	if Input.is_action_just_pressed("ui_right"):
		if (sound_volume) < 0.99:
			sound_volume += volume_step
			AudioServer.set_bus_volume_db(sounds_bus, linear_to_db(sound_volume))
	
	if Input.is_action_just_pressed("ui_left"):
		if (sound_volume - volume_step) > 0.0:
			sound_volume -= volume_step
			AudioServer.set_bus_volume_db(sounds_bus, linear_to_db(sound_volume))


# Fullscreen on/off
func _on_fullscreen_pressed():
	fullscreen_on = !fullscreen_on
	GLOBAL_GAME.toggle_fullscreen()


# Vsync on/off
func _on_vsync_pressed():
	vsync_on = !vsync_on
	GLOBAL_GAME.set_vsync()


# Autoreset on/off
func _on_auto_reset_pressed():
	autoreset_on = !autoreset_on


# Extra keys on/off
func _on_extra_keys_pressed():
	extra_keys_on = !extra_keys_on


# Reset the setting's values back to their default ones. Also plays a
# confirmation sound effect
func _on_defaults_pressed():
	reset_settings_to_default()
	GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# Go to the controls room
func _on_controls_pressed():
	if controls_menu != null:
		save_on_exit()
		get_tree().change_scene_to_file(controls_menu)
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# Return to the main menu
func _on_back_pressed():
	if main_menu != null:
		save_on_exit()
		get_tree().change_scene_to_file(main_menu)
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


##########################################################################################################

# Loads data from the global settings file
func load_from_global_settings():
	
	# Loads the settings data, then assigns it to the respective variables
	# inside of this settings menu
	GLOBAL_SETTINGS.load_settings()
	
	music_volume = GLOBAL_SETTINGS.MUSIC_VOLUME
	sound_volume = GLOBAL_SETTINGS.SOUND_VOLUME
	fullscreen_on = GLOBAL_SETTINGS.FULLSCREEN
	vsync_on = GLOBAL_SETTINGS.VSYNC
	autoreset_on = GLOBAL_SETTINGS.AUTORESET
	extra_keys_on = GLOBAL_SETTINGS.EXTRA_KEYS


# Sets and updates the text from each one of the button's labels
func set_labels_text():
	$SettingsContainer/MusicVolume/Label.text = "Music Volume: " + str(round(music_volume * 100)) + "%"
	$SettingsContainer/SFXVolume/Label.text = "Sound Volume: " + str(round(sound_volume * 100)) + "%"
	$SettingsContainer/Fullscreen/Label.text = "Fullscreen: " + str(bool_to_on_off(fullscreen_on))
	$SettingsContainer/Vsync/Label.text = "Vsync: " + str(bool_to_on_off(vsync_on))
	$SettingsContainer/AutoReset/Label.text = "Reset on Death: " + str(bool_to_on_off(autoreset_on))
	$SettingsContainer/ExtraKeys/Label.text = "Extra keys: " + str(bool_to_on_off(extra_keys_on))
	$SettingsContainer/Reset/Label.text = "Reset"
	$SettingsContainer/Controls/Label.text = "Controls"
	$SettingsContainer/Back/Label.text = "Back"
	

# When leaving the settings menu, saves values to the global settings file
func save_on_exit():
	
	# Updating the global settings file
	GLOBAL_SETTINGS.MUSIC_VOLUME = music_volume
	GLOBAL_SETTINGS.SOUND_VOLUME = sound_volume
	GLOBAL_SETTINGS.AUTORESET = autoreset_on
	GLOBAL_SETTINGS.EXTRA_KEYS = extra_keys_on
	
	# Saving (includes fullscreen and vsync, but we don't need to set them
	# from here again)
	GLOBAL_SETTINGS.save_settings()


# Sets the values back to their default ones (menu settings first, then global
# settings)
func reset_settings_to_default():
	music_volume = 1.0
	sound_volume = 1.0
	fullscreen_on = false
	vsync_on = true
	autoreset_on = false
	extra_keys_on = false
	
	GLOBAL_SETTINGS.default_settings()


# Replaces "true/false" for "on/off". Easier to read and understand
func bool_to_on_off(bool_value):
	if bool_value == true:
		return "On"
	else:
		return "Off"







