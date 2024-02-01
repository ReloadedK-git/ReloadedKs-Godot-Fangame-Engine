extends Control

@export_file("*.tscn") var files_menu: String
@export_file("*.tscn") var settings_menu: String



func _ready():
	
	# Updates bottom labels
	bottom_text_labels_update()
	
	# Resets objHUD's notifications, needed due to it being an autoload
	GLOBAL_GAME.reset_HUD()
	
	# Focuses on StartGame
	get_node("ButtonContainer/StartGame").grab_focus()


func _physics_process(_delta):
	
	# Updates bottom labels
	bottom_text_labels_update()
	
	# Exits the game if the "pause" key is pressed inside of the main menu
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()



# BOTTOM TEXT
# Updates the labels to their proper keys. Keys are returned as text from
# the global input map (check scrGlobalGame/get_input_name())
func bottom_text_labels_update():
	var key_accept = GLOBAL_GAME.get_input_name("ui_accept", GLOBAL_GAME.global_input_device)
	var key_exit = GLOBAL_GAME.get_input_name("ui_cancel", GLOBAL_GAME.global_input_device)
	
	$BottomText/Accept/Label.text = " [" + key_accept + "] Select"
	$BottomText/Exit/Label.text = "[" + key_exit + "] Exit Game "



# Start game
func _on_start_game_pressed():
	if files_menu != null:
		get_tree().change_scene_to_file(files_menu)
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# Options
func _on_options_pressed():
	if settings_menu != null:
		get_tree().change_scene_to_file(settings_menu)
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# Exits the game
func _on_exit_game_pressed():
	get_tree().quit()
