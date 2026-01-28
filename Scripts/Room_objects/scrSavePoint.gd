extends Node2D

var is_touching_save = false
var can_save = true



# For saving when the player is touching the save and presses "button_shoot"
func _unhandled_input(event: InputEvent) -> void:
	if is_touching_save and event.is_action_pressed("button_shoot"):
		$Sprite2D.frame = 1
		$Timer.start()



# Uses the sprite's frame to check if it should save or not
func _physics_process(_delta):
	match $Sprite2D.frame:
		
		# Save turns green. It should save
		1:
			if can_save:
				GLOBAL_SOUNDS.play_sound("sndSave")
				GLOBAL_SAVELOAD.save_game(true)
				can_save = false
		
		# Save turns red. It shouldn't save, but it should allow it for later
		0:
			can_save = true



# Bullet collision
func _on_bullet_body_entered(_body: Node2D) -> void:
	$Sprite2D.frame = 1
	$Timer.start()


# Player collision
func _on_player_body_entered(_body: Node2D) -> void:
	is_touching_save = true
func _on_player_body_exited(_body: Node2D) -> void:
	is_touching_save = false


# Timer for turning the save red after saving
func _on_timer_timeout():
	$Sprite2D.frame = 0
