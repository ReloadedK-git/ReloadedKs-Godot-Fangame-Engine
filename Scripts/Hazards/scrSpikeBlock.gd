extends StaticBody2D

@onready var spike_block: Node = get_node("Sprite2D")
var activated: bool = false



# Detects initial collision with player. Readies the spikes
func _on_detection_area_body_entered(_body):
	if !activated:
		activated = true


# If the player is no longer colliding (and button_reset wasn't just pressed),
# It starts the spike animation and plays a sound effect
func _on_detection_area_body_exited(_body):
	
	# Starts animation. Checks if the reset button was pressed so it doesn't
	# play the sound effect when restarting after colliding and waiting for
	# the spikes to come out
	if activated and !Input.is_action_just_pressed("button_reset"):
		
		if spike_block.frame == 0:
			spike_block.play("default")
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndSpikeBlock)


# Kills player by calling its death event if the spikes are out
func _on_kill_area_body_entered(body):
	if spike_block.frame == 3:
		body.on_death()
