extends Node2D

# The path to the level scene. It's an exported path, so simply select it from
# the scene/room editor
# You should NOT use an exported PackedScene. It looks and feels better, but it
# doesn't allow for cyclic referencing, meaning if you warp from a to b and
# then return to a from b, godot will either crash or return an error. 
# Will probably get fixed on future versions of Godot (hopefully)
@export_file("*.tscn") var warp_to: String
@export var warp_transition: bool = false
@export var warp_to_point: Vector2 = Vector2.ZERO


# When colliding with the player, it changes the scene
func _on_area_2d_body_entered(_body):
	
	# This keeps the current direction the player is looking at.
	# I like it this way, but each time you reset after warping, the direction
	# will have changed to the one the player had before warping
	var player_looking_at = GLOBAL_INSTANCES.objPlayerID.xscale
	GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped = player_looking_at
	
	# This variable prevents objPlayerController from teleporting to the last
	# saved position in GLOBAL_SAVELOAD, giving the desired warp interaction.
	# Once the warping is done, this variable gets set to false again, since
	# the player is no longer changing rooms.
	GLOBAL_GAME.is_changing_rooms = true
	
	# Changes warp_to_point inside of GLOBAL_GAME, which is then read by
	# objPlayer
	if warp_to_point != Vector2.ZERO:
		GLOBAL_GAME.warp_to_point = warp_to_point
	
	# Adds a transition effect
	if warp_transition:
		objWarpTransition.fade_from_black()
	
	# Plays a warp sound
	GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndWarp)
	
	# Clear/reset our global trigger array
	GLOBAL_GAME.triggered_events.clear()
	
	get_tree().change_scene_to_file(warp_to)
	
