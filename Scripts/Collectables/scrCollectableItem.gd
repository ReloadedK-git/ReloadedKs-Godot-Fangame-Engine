extends Node2D

# You can give your item any name you want, as long as you don't repeat them
@export var item_name: String
var wave_time: float = 0.0
var wave_amplitude: float = 0.8
var should_save_collectable: bool = false
var picked_collectable: bool = false
@onready var item_sprite = get_node("Sprite2D")



# If we collected this item already, it can no longer be picked up
func _ready():
	
	if GLOBAL_SAVELOAD.variableGameData.has(item_name) or GLOBAL_SAVELOAD.itemsGameData.has(item_name):
		picked_collectable = true
		item_sprite.modulate = 'ffffff80'


# Collectable's "visuals"
func _physics_process(delta):
	
	# Classic "wave effect"
	wave_time += delta * 2
	var wave_constant = sin(wave_time) * wave_amplitude
	
	# Will reduce the values of wave_constant to be more subtle
	var reduced_amplitude: int = 4
	
	# Changes the sprite's scale
	item_sprite.scale = Vector2(1 + wave_constant/reduced_amplitude, 1 + wave_constant/reduced_amplitude)



# Adds this item's sprite and name to the HUD autoload, and calls its 
# notification method to show it
func set_HUD_data():
	if is_instance_valid(objHUD):
		objHUD.item_sprite = item_sprite.get_texture()
		objHUD.item_text = item_name
		objHUD.handle_item_notification()



# If this collectible collides with "player", we read GLOBAL_SAVELOAD's.
# variableGameData's dictionary. If it does not have a key equal to 
# "item_name", it creates a temporary dictionary with the new key and
# merges it into the one from GLOBAL_SAVELOAD.
# This allows for an infinite amount of collectables, with any kind of name
# you want
func _on_area_2d_body_entered(_body):
	
	# The collectable can only be picked up if it wasn't saved yet
	if !GLOBAL_SAVELOAD.variableGameData.has(item_name):
		if (picked_collectable == false):
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndItem)
			item_sprite.modulate = 'ffffff80'
			
			# Sets the HUD autoload
			set_HUD_data()
			
			# Saving into itemsGameData. We save items temporarily until we
			# make an actual save, merging data dictionaries
			if !GLOBAL_SAVELOAD.itemsGameData.has(item_name):
				
				var dictionary_value = {item_name: true}
				GLOBAL_SAVELOAD.itemsGameData.merge(dictionary_value)
			
			# Do keep in mind, you still have to save in order to add the key
			# permanently
			picked_collectable = true
