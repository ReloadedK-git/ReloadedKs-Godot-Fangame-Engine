extends Node

# Saving and loading goes here
var saveFileID: int = 1
const DATA_PATH: = "user://Data/Save"

# These are for saving with a password. SAVE_PASSWORD_STRING will use a string,
# meaning as long as your games have the same string, they can be shared and
# they will work. With SAVE_PASSWORD_UNIQUE, your encryption key will be unique
# to your system, meaning you won't be able to open your savefiles on different
# machines
const SAVE_PASSWORD_STRING := "Change me!"
#const SAVE_PASSWORD_UNIQUE := OS.get_unique_id()

# Meant for taking screenshots
const SCREENSHOT_WIDTH: int = 192
const SCREENSHOT_HEIGHT: int = 160

# This is the default data, for creating new files
const defaultGameData = {
	"first_time_saving" : true,
	"player_x" : 0,
	"player_y" : 0,
	"player_sprite_flipped" : false,
	"room_name" : "",
	"total_time" : 0.0,
	"total_deaths" : 0
}

# This is the data we can read and write. By default, it's just a copy of
# the default game data dictionary, but we will modify this later on, and
# then we'll read from those existing files.
var variableGameData = defaultGameData.duplicate(true)

# Dictionary for items and collectables. Empty by default
var itemsGameData = {}



# Creating directories and settings/config file, if they didn't exist already
func _ready():
	
	# Opens the main directory. Allows for handling later on
	var dir = DirAccess.open("user://")
	
	# Creates Data directory if it doesn't exist.
	# We store our settings, saves and screenshots here
	if not dir.dir_exists("user://Data"):
		dir.make_dir("Data")
	
	# A very specific function which is used to check your savefiles and
	# updating them if needed. It should only be called once per game launch
	check_savefiles_and_update()



# Loads a save file (1, 2 or 3, depends on saveFileID), and if it doesn't
# exist (is "null"), creates a save file with default data
func load_data():
	
	# Reads the save file
	var file = FileAccess.open_encrypted_with_pass(DATA_PATH + str(saveFileID) + ".save", FileAccess.READ, SAVE_PASSWORD_STRING)
	
	# If it doesn't exist, saves one with default data values
	if (file == null):
		save_default_data()
	else:
		
		# If the file does exist, replaces the dictionary with its read data
		# This is the actual "loading"
		variableGameData = file.get_var()
	
	# Closes file, freeing it from memory
	file = null


# Saves data on a file (1, 2 or 3, depends on saveFileID).
# This is the function you use when you want to save in-game data, but the
# contents of variableGameData are set/handled somewhere else
func save_data():
	var file = FileAccess.open_encrypted_with_pass(DATA_PATH + str(saveFileID) + ".save", FileAccess.WRITE, SAVE_PASSWORD_STRING)
	file.store_var(variableGameData)
	
	# Closes file, freeing it from memory
	file = null


# Saves data on a file (1, 2 or 3, depends on saveFileID).
# Only used when creating a new save file
func save_default_data():
	var file = FileAccess.open_encrypted_with_pass(DATA_PATH + str(saveFileID) + ".save", FileAccess.WRITE, SAVE_PASSWORD_STRING)
	file.store_var(defaultGameData)
	
	# This fixes a very specific bug where you select one file, save on it but
	# don't load, go back to the menu and then select another file without a 
	# previous save. It's a way to make sure variableGameData is "empty" by
	# default when starting a new file
	variableGameData = defaultGameData.duplicate(true)
	
	# Closes file, freeing it from memory
	file = null 


# Deletes save data after checking if such files exist (both savefiles and save
# previews/screenshots)
func delete_data():
	var dir = DirAccess.open("user://")
	
	if FileAccess.file_exists(DATA_PATH + str(saveFileID) + ".save"):
		dir.remove(DATA_PATH + str(saveFileID) + ".save")
	
	if FileAccess.file_exists(DATA_PATH + str(saveFileID) + ".png"):
		dir.remove(DATA_PATH + str(saveFileID) + ".png")


# Takes a screenshot and resizes it. Made to be shown on the main menu screen.
# You should tell this autoload to take screenshots when you want it to and
# not automatically, for more control (e.g. on objSavePoint when saving)
func take_screenshot() -> void:
	var img = get_viewport().get_texture().get_image()
	img.resize(SCREENSHOT_WIDTH, SCREENSHOT_HEIGHT, Image.INTERPOLATE_NEAREST)
	img.save_png(DATA_PATH + str(saveFileID) + ".png")
	return ImageTexture.create_from_image(img)


# Saves the player's coordinates, sprite state and room name. Also takes a
# screenshot. This is what you use for saving the game normally
func save_game(save_position = true) -> void:
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID) && save_position:
		variableGameData.player_x = GLOBAL_INSTANCES.objPlayerID.position.x
		variableGameData.player_y = GLOBAL_INSTANCES.objPlayerID.position.y
		variableGameData.player_sprite_flipped = GLOBAL_INSTANCES.objPlayerID.xscale
		variableGameData.room_name = get_tree().get_current_scene().get_scene_file_path()
		merge_items_data()
		take_screenshot()
	variableGameData.total_time = GLOBAL_GAME.time
	variableGameData.total_deaths = GLOBAL_GAME.deaths
	save_data()


# A way to check if a savefile is "up to date".
# It opens a savefile if it exists and reads its dictionary. If any key is
# missing, it takes it from defaultSaveData and saves it on top (without
# messing with other keys).
# This makes older savefiles compatible with newer ones
func check_savefiles_and_update():
	
	# If a savefile exists (Save1, Save2, Save3), we open it and check its
	# dictionary
	for file_loop in range(1, 4):
		if FileAccess.file_exists(DATA_PATH + str(file_loop) + ".save"):
			var file_open = FileAccess.open_encrypted_with_pass(DATA_PATH + str(file_loop) + ".save", FileAccess.READ, SAVE_PASSWORD_STRING)
			var savefileGameData = file_open.get_var()
			
			# If a savefile is missing keys, we copy defaultGameData's keys
			# and add them to the dictionary from the savefile's dictionary
			var should_save = false
			for key in defaultGameData:
				if !savefileGameData.has(key):
					savefileGameData[key] = defaultGameData[key]
					should_save = true
			
			# We save the new dictionary ONLY if we missed any key. No need
			# to write to a file if we have everything we need already
			if should_save:
				var file_save = FileAccess.open_encrypted_with_pass(DATA_PATH + str(file_loop) + ".save", FileAccess.WRITE, SAVE_PASSWORD_STRING)
				file_save.store_var(savefileGameData)
				file_save = null


# Merges the itemsGameData dictionary with variableGameData and clears
# itself afterwards
func merge_items_data():
	
	# Checks if there's something to merge first
	if itemsGameData != {}:
		variableGameData.merge(itemsGameData)
		itemsGameData.clear()
