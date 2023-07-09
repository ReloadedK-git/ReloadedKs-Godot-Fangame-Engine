extends Node2D

# You can give your item any name you want, as long as you don't repeat them
@export var item_name: String

var wave_time: float = 0.0
var wave_amplitude: float = 0.8



# If we collected this item previously, it destroys itself
func _ready():
	
	if GLOBAL_SAVELOAD.variableGameData.has("item_name"):
		queue_free()



# Collectible's "visuals"
func _physics_process(delta):
	
	# Famous "wave effect"
	wave_time += delta * 2
	var wave_constant = sin(wave_time) * wave_amplitude
	
	# Will reduce the values of wave_constant to be more subtle
	var reduced_amplitude: int = 4
	
	# Changes the sprite's scale
	$Sprite2D.scale = Vector2(1 + wave_constant/reduced_amplitude, 1 + wave_constant/reduced_amplitude)



# If this collectible collides with "player", we read GLOBAL_SAVELOAD's.
# variableGameData's dictionary. If it does not have a key equal to 
# "item_name", it creates a temporary dictionary with the new key and
# merges it into the one from GLOBAL_SAVELOAD.
# This allows for an infinite amount of collectables, with any kind of name
# you want
func _on_area_2d_body_entered(_body):
	if !GLOBAL_SAVELOAD.variableGameData.has(item_name):
		
		# Do keep in mind, you still have to save in order to add the key
		# permanently
		var dictionary_value = {"item_name": true}
		GLOBAL_SAVELOAD.variableGameData.merge(dictionary_value)
		
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndItem)
		queue_free()

