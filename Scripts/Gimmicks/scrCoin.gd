extends Node2D

@export var scene_to_destroy: Node
var coin_animation: bool = false


# Plays a short animation (moves up, pauses the sprite animation, fades the 
# sprite). Also disables the collision shape
func _physics_process(_delta):
	if coin_animation:
		$Area2D/CollisionShape2D.disabled = true
		$AnimatedSprite2D.pause()
		position.y -= 0.5
		modulate.a -= 0.05


# When picked by the player, the coin plays a sound, starts the destruction
# timer, checks if it should free the selected node if there are no more coins
# and sets coin_animation to true, which plays a small animation
func _on_area_2d_body_entered(_body):
	if !coin_animation:
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndCoin)
		$Timer.start()
		
		var coins = get_tree().get_nodes_in_group("Coins")
		if coins.size() == 1:
			if is_instance_valid(scene_to_destroy):
				scene_to_destroy.queue_free()
		
		coin_animation = true


# Destroys the object on timeout
func _on_timer_timeout():
	queue_free()
