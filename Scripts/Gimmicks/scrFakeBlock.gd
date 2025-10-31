extends Sprite2D



# Deletes itself when detecting a collision with the player
func _on_area_2d_body_entered(_body: Node2D) -> void:
	
	# Stops the block change sound before playing it so it doesn't overlap
	GLOBAL_SOUNDS.stop_sound("sndBlockChange")
	GLOBAL_SOUNDS.play_sound("sndBlockChange")
	queue_free()
