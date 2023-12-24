extends Node2D

# You can give your item any name you want, as long as you don't repeat them
@export var item_name: String
var wave_time: float = 0.0
var wave_amplitude: float = 0.8
var should_save_collectable: bool = false
var picked_collectable: bool = false



# If we collected this item already, it can no longer be picked up
func _ready():
	
	if GLOBAL_SAVELOAD.variableGameData.has(item_name):
		picked_collectable = true
		$Sprite2D.modulate = 'ffffff80'


# Collectible's "visuals"
func _physics_process(delta):
	
	# As long as should_save_collectable is set to true, and GLOBAL_GAME's
	# can_save_collectable is also set to true, the collectable can be saved
	# inside the save file. To do this, we need to save the newly merged values
	# and load them (write and read)
	if (should_save_collectable == true):
		if (GLOBAL_GAME.can_save_collectable == true):
			
			var dictionary_value = {item_name: true}
			GLOBAL_SAVELOAD.variableGameData.merge(dictionary_value)
			GLOBAL_SAVELOAD.save_data()
			GLOBAL_SAVELOAD.load_data()
			GLOBAL_GAME.can_save_collectable = false
	
	# Classic "wave effect"
	wave_time += delta * 2
	var wave_constant = sin(wave_time) * wave_amplitude
	
	# Will reduce the values of wave_constant to be more subtle
	var reduced_amplitude: int = 4
	
	# Changes the sprite's scale
	$Sprite2D.scale = Vector2(1 + wave_constant/reduced_amplitude, 1 + wave_constant/reduced_amplitude)



# Adds this item's sprite and name to the HUD autoload, and calls its 
# notification method to show it
func set_HUD_data():
	if is_instance_valid(objHUD):
		objHUD.item_sprite = $Sprite2D.get_texture()
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
			$Sprite2D.modulate = 'ffffff80'
			
			# Sets the HUD autoload
			set_HUD_data()
			
			# Do keep in mind, you still have to save in order to add the key
			# permanently
			should_save_collectable = true
			picked_collectable = true
