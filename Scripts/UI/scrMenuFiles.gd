extends Control

@export_file("*.tscn") var starting_room: String
@export_file("*.tscn") var main_menu: String
var last_button_id: int
var confirm_delete_sfx: bool = false



# Prepares some things at startup
func _ready():
	
	# Check if savefiles 1 to 3 exists and updates their file labels
	for file_loop in range(1, 4):
		check_files_change_labels(file_loop)
	
	# Updates text labels to show their proper data
	stats_text_labels_update()
	bottom_text_labels_update()
	
	# Updates the bottom labels to show the proper key ids
	bottom_text_labels_update()
	
	# Gets the focus on saveFileID. Not really necessary but it's a bit of
	# production quality. If we return to the menu screen, it will read the
	# last selected saveFileID and put the focus there
	get_node("ButtonContainer/Files/File" + str(GLOBAL_SAVELOAD.saveFileID)).grab_focus()



# Key press checking (main_menu, quit)
func _physics_process(_delta):
	
	# Updates the bottom labels to show the proper key ids
	bottom_text_labels_update()
	
	# Changes scene if the "main_menu" key is pressed
	if Input.is_action_just_pressed("ui_select"):
		if main_menu != null:
			get_tree().change_scene_to_file(main_menu)
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# FILES
func generic_files(file_id):
	
	# We set our savefile id (1, 2 or 3), which we then read our data from
	GLOBAL_SAVELOAD.saveFileID = file_id
	GLOBAL_SAVELOAD.load_data()
	
	# Sets the time and death counters
	GLOBAL_GAME.time = GLOBAL_SAVELOAD.variableGameData.total_time
	GLOBAL_GAME.deaths = GLOBAL_SAVELOAD.variableGameData.total_deaths
	
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
	
	# Plays different sound effect
	confirm_delete_sfx = true
	
	# Calls delete function from GLOBAL_SAVELOAD
	GLOBAL_SAVELOAD.delete_data()
	
	# Update file labels
	for file_loop in range(1, 4):
		check_files_change_labels(file_loop)
	
	# Update stats labels
	stats_text_labels_update()
	
	# Toggles button visibility and handles focus
	exit_confirm_delete()

func _on_no_pressed():
	
	# Toggles button visibility and handles focus
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
	
	# Plays sound effect after a savefile is deleted, muting the menu button
	# sfx
	if confirm_delete_sfx == true:
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndCherry)
		GLOBAL_SOUNDS.stop_sound(GLOBAL_SOUNDS.sndMenuButton)
		confirm_delete_sfx = false


# BOTTOM TEXT
# Updates the labels to their proper keys. Keys are returned as text from
# the global input map (check scrGlobalGame/get_input_name())
func bottom_text_labels_update():
	var key_accept = GLOBAL_GAME.get_input_name("ui_accept", GLOBAL_GAME.global_input_device)
	var key_back = GLOBAL_GAME.get_input_name("ui_select", GLOBAL_GAME.global_input_device)
	
	$BottomText/Accept/Label7.text = " [" + key_accept + "] Select"
	$BottomText/Back/Label8.text = "[" + key_back + "] Back "


# Checks if a savefile exists using file_id as a parameter, and sets the labels
# for file loading accordingly
func check_files_change_labels(file_id):
	
	# Get label nodes
	var file_label = get_node("ButtonContainer/Files/File" + str(file_id) + "/Label")
	
	# Check user data folder
	if FileAccess.file_exists("user://Data/Save" + str(file_id) + ".save"):
		file_label.text = "Load"
	else:
		file_label.text = "New Game"


# Loads savefiles if they exist, reads their saved values, selects the time and
# death values and updates the stat labels with their contents
func stats_text_labels_update():
	
	var DATA_PATH: = GLOBAL_SAVELOAD.DATA_PATH
	
	# Gets file 1 to 3 using a simple for loop
	for file_loop in range(1, 4):
		if FileAccess.file_exists(DATA_PATH + str(file_loop) + ".save"):
			var file = FileAccess.open_encrypted_with_pass(DATA_PATH + str(file_loop) + ".save", FileAccess.READ, GLOBAL_SAVELOAD.SAVE_PASSWORD_STRING)
			
			# Reads the existing save file and updates stat labels with its
			# values
			var variableGameData = file.get_var()
			
			# Time and deaths from savefiles
			match file_loop:
				1:
					$SavefileStats/File1/Time.text = "Time: " + GLOBAL_GAME.format_time(variableGameData.total_time)
					$SavefileStats/File1/Deaths.text = "Deaths: " + str(variableGameData.total_deaths)
				2:
					$SavefileStats/File2/Time.text = "Time: " + GLOBAL_GAME.format_time(variableGameData.total_time)
					$SavefileStats/File2/Deaths.text = "Deaths: " + str(variableGameData.total_deaths)
				3:
					$SavefileStats/File3/Time.text = "Time: " + GLOBAL_GAME.format_time(variableGameData.total_time)
					$SavefileStats/File3/Deaths.text = "Deaths: " + str(variableGameData.total_deaths)
		
		else:
			# We cheat a little bit here. If we can't find a save file with its
			# savefile ID, we don't have anything to read so we hardcode the
			# labels to show the default values, or whathever we want
			match file_loop:
				1:
					$SavefileStats/File1/Time.text = "Time: 00:00:00"
					$SavefileStats/File1/Deaths.text = "Deaths: 0"
				2:
					$SavefileStats/File2/Time.text = "Time: 00:00:00"
					$SavefileStats/File2/Deaths.text = "Deaths: 0"
				3:
					$SavefileStats/File3/Time.text = "Time: 00:00:00"
					$SavefileStats/File3/Deaths.text = "Deaths: 0"
	
