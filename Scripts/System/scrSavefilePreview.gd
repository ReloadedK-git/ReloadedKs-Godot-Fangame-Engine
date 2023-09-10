extends Node2D

# This variable is changed from the object's properties. Check rMainMenu 
@export_enum("1:1", "2:2", "3:3") var fileID: int = 1
var default_sprite = load("res://Graphics/Sprites/System/sprSaveFile.png")


func _ready():
	screenshot_loading()


func screenshot_loading():
	var image_path = "user://Data/Save" + str(fileID) + ".png"
	
	if FileAccess.file_exists(image_path):
		var image = Image.load_from_file(image_path)
		var texture =  ImageTexture.create_from_image(image)
		$Sprite2D.texture = texture
	else:
		$Sprite2D.texture = default_sprite
