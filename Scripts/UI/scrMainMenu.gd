extends Control

@export_file("*.tscn") var starting_room: String
@export_file("*.tscn") var settings_menu: String
var last_button_id: int



# Prepares some things at startup
func _ready():
	
	# Resets objHUD's notifications, needed due to it being an autoload
	GLOBAL_GAME.reset_HUD()
	
	# Updates the bottom labels to show the proper key ids
	bottom_text_labels_update()
	
	# Gets the focus on saveFileID. Not really necessary but it's a bit of
	# production quality. If we return to the menu screen, it will read the
	# last selected saveFileID and put the focus there
	get_node("ButtonContainer/Files/File" + str(GLOBAL_SAVELOAD.saveFileID)).grab_focus()



# Key press checking (settings, quit)
func _physics_process(_delta):
	
	# Updates the bottom labels to show the proper key ids
	bottom_text_labels_update()
	
	# Changes scene if the "settings" key is pressed
	if Input.is_action_just_pressed("ui_select"):
		if settings_menu != null:
			get_tree().change_scene_to_file(settings_menu)
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)
	
	# Quits the game if the "pause" key is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


# FILES
func generic_files(file_id):
	
	# We set our savefile id (1, 2 or 3), which we then read our data from
	GLOBAL_SAVELOAD.saveFileID = file_id
	GLOBAL_SAVELOAD.load_data()
	
	# After reading our data, we check if we've saved at least one time.
	# If we haven't, it means we're starting a new game, so we go to the
	# starting room. If we have saved before, then we go to the last room
	# we saved previously on GLOBAL_SAVELOAD
	if GLOBAL_SAVELOAD.variableGameData.first_time_saving == true:
		if starting_room != null:
			get_tree().change_scene_to_file(starting_room)
		else:
			print("You forgot to set your starting room!")
	else:
		get_tree().change_scene_to_file(GLOBAL_SAVELOAD.variableGameData.room_name)

func _on_file_1_pressed():
	generic_files(1)

func _on_file_2_pressed():
	generic_files(2)

func _on_file_3_pressed():
	generic_files(3)



# DELETES
func generic_deletes(file_id):
	GLOBAL_SAVELOAD.saveFileID = file_id
	last_button_id = file_id
	enter_confirm_delete()

func _on_delete_1_pressed():
	generic_deletes(1)

func _on_delete_2_pressed():
	generic_deletes(2)

func _on_delete_3_pressed():
	generic_deletes(3)



# CONFIRM DELETE
func _on_yes_pressed():
	GLOBAL_SAVELOAD.delete_data()
	exit_confirm_delete()

func _on_no_pressed():
	exit_confirm_delete()



# SPECIFIC FUNCTIONS
# Switches the visibility of the button containers
func switch_button_visibility(button_visibility: bool):
	$ButtonContainer/Files.visible = button_visibility
	$ButtonContainer/Deletes.visible = button_visibility
	$ButtonContainer/ConfirmDelete.visible = !button_visibility


# After pressing the delete buttons, it asks for confirmation (we "enter" the
# new confirm delete options)
# This function shows the proper label text and also grabs focus to confirm
func enter_confirm_delete():
	switch_button_visibility(false)
	
	var _text = "Deleting File " + str(GLOBAL_SAVELOAD.saveFileID) + ". Confirm?"
	$ButtonContainer/ConfirmDelete/ConfirmText.text = _text
	$ButtonContainer/ConfirmDelete/HBoxContainer/No.grab_focus()


# What should happen after we "exit" the confirm delete options (regardless of
# what we chose before)
func exit_confirm_delete():
	switch_button_visibility(true)
	
	# Returns the focus to our previous "delete" button
	get_node("ButtonContainer/Deletes/Delete" + str(last_button_id)).grab_focus()
	
	# Updates savefile previews
	get_node("SavefilePreviews/objSavefilePreview" + str(last_button_id)).screenshot_loading()



# BOTTOM TEXT
# Updates the labels to their proper keys. Keys are returned as text from
# the global input map (check scrGlobalGame/get_input_name())
func bottom_text_labels_update():
	var key_accept = GLOBAL_GAME.get_input_name("ui_accept", GLOBAL_GAME.global_input_device)
	var key_settings = GLOBAL_GAME.get_input_name("ui_select", GLOBAL_GAME.global_input_device)
	var key_quit = GLOBAL_GAME.get_input_name("ui_cancel", GLOBAL_GAME.global_input_device)
	
	$BottomText/Accept/Label7.text = " [" + key_accept + "] Select"
	$BottomText/Options/Label8.text = "[" + key_settings + "] Settings "
	$BottomText/Quit/Label9.text = "[" + key_quit + "] Quit "
