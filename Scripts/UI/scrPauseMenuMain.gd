extends Control

@export_file("*.tscn") var main_menu: String
@export var items_menu_enabled: bool = false
@onready var music_bus: int = AudioServer.get_bus_index("Music")
@onready var sounds_bus: int = AudioServer.get_bus_index("Sounds")

var items_menu := preload("res://Objects/UI/objPauseMenuItems.tscn")
var button_color_unfocused: Color = Color(0, 0, 0)
var music_volume: float = 1.0
var sound_volume: float = 1.0
var volume_step: float = 0.1



# Loads and sets values, gives focus, sets button labels and colors
func _ready():
	
	# Sets position and visuals of items menu elements
	if items_menu_enabled:
		$CanvasLayer/VBoxContainer.position.y = -32
		
		# Updates bottom label
		bottom_text_labels_update()
	else:
		$CanvasLayer/ViewItems.set_visible(false)
	
	# Pauses the game
	GLOBAL_GAME.game_paused = true
	get_tree().set_pause(true)
	
	music_volume = GLOBAL_SETTINGS.MUSIC_VOLUME
	sound_volume = GLOBAL_SETTINGS.SOUND_VOLUME
	
	# Sets text and color for the button labels
	set_labels_text()
	
	# Changes text and color_unfocused for each button inside the options
	# container. Keep in mind, we get the "node_path + /Label" to change
	# each label's colors on creation. Afterwards, we set color_unfocused
	# to each node, so they change on their own
	for options_container_buttons in $CanvasLayer/VBoxContainer/OptionsContainer.get_children():
		
		set_button_colors(options_container_buttons.get_node("Label"))
		options_container_buttons.color_unfocused = button_color_unfocused
	
	
	
	# Sets focus to the first option (we do this after setting the button's
	# colors. Otherwise, the focus color will get overwritten)
	$CanvasLayer/VBoxContainer/OptionsContainer/ResumeGame.grab_focus()



# Quits pause menu if "button_pause" is pressed
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("button_pause"):
		quit_pause()
	
	# Items menu
	if items_menu_enabled:
		if event.is_action_pressed("button_shoot"):
			if items_menu != null:
				var items_menu_instance = items_menu.instantiate()
				add_sibling(items_menu_instance)
				
				# Play sound and destroy itself
				GLOBAL_SOUNDS.play_sound("sndPause")
				queue_free()



# Goes back to the main menu room if "button_shoot" is pressed
func _physics_process(_delta):
	
	# Sets and updates the text from each one of the button's labels
	set_labels_text()
	
	# Updates bottom label text to show the proper key ids
	if items_menu_enabled:
		bottom_text_labels_update()



# Items menu
func _on_items_menu_pressed():
	if items_menu != null:
		var items_menu_instance = items_menu.instantiate()
		add_sibling(items_menu_instance)
		
		# Play sound and destroy itself
		GLOBAL_SOUNDS.play_sound("sndPause")
		queue_free()


# Resume game
func _on_resume_game_pressed():
	get_viewport().set_input_as_handled()
	quit_pause()


# Music volume
func _on_music_volume_gui_input(event):
	if event.is_action_pressed("ui_right"):
		if (music_volume) < 0.99:
			music_volume += volume_step
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	
	if event.is_action_pressed("ui_left"):
		if (music_volume - volume_step) >= 0.0:
			music_volume -= volume_step
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))


# Sound volume
func _on_sound_volume_gui_input(event):
	if event.is_action_pressed("ui_right"):
		if (sound_volume) < 0.99:
			sound_volume += volume_step
			AudioServer.set_bus_volume_db(sounds_bus, linear_to_db(sound_volume))
	
	if event.is_action_pressed("ui_left"):
		if (sound_volume - volume_step) >= 0.0:
			sound_volume -= volume_step
			AudioServer.set_bus_volume_db(sounds_bus, linear_to_db(sound_volume))


# Quit to menu
func _on_quit_to_menu_pressed():
	quit_pause()
	
	# Performs clean-up through GLOBAL_GAME
	GLOBAL_GAME.full_game_restart(main_menu)



# Updates text labels to show the proper key ids
func set_labels_text():
	$CanvasLayer/VBoxContainer/OptionsContainer/ResumeGame/Label.text = "Resume Game"
	$CanvasLayer/VBoxContainer/OptionsContainer/MusicVolume/Label.text = "Music Volume: " + str(round(music_volume * 100)) + "%"
	$CanvasLayer/VBoxContainer/OptionsContainer/SoundVolume/Label.text = "Sound Volume: " + str(round(sound_volume * 100)) + "%"
	$CanvasLayer/VBoxContainer/OptionsContainer/QuitToMenu/Label.text = "Quit to Main Menu"


# Updates the labels to their proper keys. Keys are returned as text from
# the global input map (check scrGlobalGame/get_input_name())
func bottom_text_labels_update() -> void:
	var key_items = GLOBAL_GAME.get_input_name("ui_select", GLOBAL_GAME.global_input_device)
	
	$CanvasLayer/ViewItems.text = " [" + key_items + "] View Items"


# Sets the color of the button outlines when unfocused.
# Just a personal preference, and lazily made
func set_button_colors(button_id):
	button_id.set("theme_override_colors/font_outline_color", button_color_unfocused)


# Called when quitting the pause menus
func quit_pause():
	
	# Save settings
	GLOBAL_SETTINGS.MUSIC_VOLUME = music_volume
	GLOBAL_SETTINGS.SOUND_VOLUME = sound_volume
	GLOBAL_SETTINGS.save_settings()
	
	# Unset pause, unpause game
	GLOBAL_GAME.game_paused = false
	get_tree().set_pause(false)
	
	# Destroy itself
	queue_free()
