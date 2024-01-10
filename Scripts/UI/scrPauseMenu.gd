extends Control

@export_file("*.tscn") var main_menu: String
@onready var music_bus: int = AudioServer.get_bus_index("Music")
@onready var sounds_bus: int = AudioServer.get_bus_index("Sounds")

var button_color_unfocused: Color = Color(0, 0, 0)
var music_volume: float = 1.0
var sound_volume: float = 1.0
var volume_step: float = 0.1


# Loads and sets values, gives focus, sets button labels and colors
func _ready():
	
	# Load and set volume and music by reading GLOBAL_SETTINGS
	GLOBAL_SETTINGS.load_settings()
	
	music_volume = GLOBAL_SETTINGS.MUSIC_VOLUME
	sound_volume = GLOBAL_SETTINGS.SOUND_VOLUME
	
	# Sets focus to the first option (music volume)
	$CanvasLayer/VBoxContainer/MusicVolume.grab_focus()
	
	# Sets text and color for the button labels
	set_labels_text()
	set_button_colors()


# Goes back to the main menu room if "button_shoot" is pressed
func _physics_process(_delta):
	
	# Sets and updates the text from each one of the button's labels
	set_labels_text()



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


# Sound volume
func _on_sound_volume_gui_input(_event):
	if Input.is_action_just_pressed("ui_right"):
		if (sound_volume) < 0.99:
			sound_volume += volume_step
			AudioServer.set_bus_volume_db(sounds_bus, linear_to_db(sound_volume))
	
	if Input.is_action_just_pressed("ui_left"):
		if (sound_volume - volume_step) > 0.0:
			sound_volume -= volume_step
			AudioServer.set_bus_volume_db(sounds_bus, linear_to_db(sound_volume))


# Quit to menu
func _on_quit_to_menu_pressed():
	GLOBAL_GAME.game_paused = !GLOBAL_GAME.game_paused
	GLOBAL_GAME.triggered_events.clear()
	GLOBAL_GAME.dialog_events.clear()
	get_tree().change_scene_to_file(main_menu)
	queue_free()


# Resume game
func _on_resume_game_pressed():
	GLOBAL_GAME.pause_game()
#	GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# Just before destroying itself and with the room now changed to the main
# menu, it sets the pause to false. This prevents objPlayer from shooting
# at the very last frame, making the bullet fired sound
func _on_tree_exiting():
	get_tree().set_pause(false)



# Updates text labels to show the proper key ids
func set_labels_text():
	$CanvasLayer/VBoxContainer/MusicVolume/Label.text = "Music Volume: " + str(round(music_volume * 100)) + "%"
	$CanvasLayer/VBoxContainer/SoundVolume/Label.text = "Sound Volume: " + str(round(sound_volume * 100)) + "%"
	$CanvasLayer/VBoxContainer/QuitToMenu/Label.text = "Quit to Main Menu"
	$CanvasLayer/VBoxContainer/ResumeGame/Label.text = "Resume"


# Sets the color of the button outlines when unfocused.
# Just a personal preference, and lazily made
func set_button_colors():
	$CanvasLayer/VBoxContainer/SoundVolume/Label.set("theme_override_colors/font_outline_color", button_color_unfocused)
	$CanvasLayer/VBoxContainer/QuitToMenu/Label.set("theme_override_colors/font_outline_color", button_color_unfocused)
	$CanvasLayer/VBoxContainer/ResumeGame/Label.set("theme_override_colors/font_outline_color", button_color_unfocused)
	
	$CanvasLayer/VBoxContainer/MusicVolume.color_unfocused = button_color_unfocused
	$CanvasLayer/VBoxContainer/SoundVolume.color_unfocused = button_color_unfocused
	$CanvasLayer/VBoxContainer/QuitToMenu.color_unfocused = button_color_unfocused
	$CanvasLayer/VBoxContainer/ResumeGame.color_unfocused = button_color_unfocused
