extends Control

@export var item_sprite: CompressedTexture2D
@export var item_name: String
@export_multiline var item_description: String



func _ready():
	
	# Sets item sprite
	$Sprite2D.texture = item_sprite
	
	# Item name and description
	if GLOBAL_SAVELOAD.variableGameData.has(item_name) or GLOBAL_SAVELOAD.itemsGameData.has(item_name):
		$Label.text = item_name
		$Label2.text = item_description
	else:
		$Label.text = "???"
		$Label2.text = "???"
		$Sprite2D.set_self_modulate(Color.BLACK)
	
