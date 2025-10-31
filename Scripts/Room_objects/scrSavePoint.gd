extends Node2D

var is_touching_save = false
var can_save = true



func _physics_process(_delta):
	
	# If the player is touching the save, it takes priority and saves as soon
	# as the shooting button is pressed
	if (is_touching_save == true):
		if Input.is_action_just_pressed("button_shoot"):
			$Sprite2D.frame = 1
			$Timer.start()
	
	is_saving_allowed()



# Reads the animation frame from the save sprite. Also uses a variable to only
# save once
func is_saving_allowed() -> void:
	
	# If the save button is green (saving), save once and wait until it's red
	# (not saving) again
	if ($Sprite2D.frame == 1):
		if (can_save == true):
			GLOBAL_SOUNDS.play_sound("sndSave")
			
			# The actual saving is done here
			GLOBAL_SAVELOAD.save_game(true)
		can_save = false
	
	# Save button is red (not saving). Can save as soon as the button turns 
	# green again
	elif ($Sprite2D.frame == 0):
		can_save = true



func _on_hitbox_body_entered(body):
	
	# Check if player is touching the save
	if (body.name == "objPlayer"):
		is_touching_save = true
	
	# Check if we are colliding with a bullet and the player isn't touching 
	# the save at the same time.
	
	# If you don't want bullets to save and you only want the other way to do
	# if (player colliding and pressing shoot), comment this one out or
	# deactivate the collision checking from $Hitbox entirelly.
	if (body.name == "objBullet"):
		if (is_touching_save == false):
			$Sprite2D.frame = 1
			$Timer.start()


# Check if player is not touching the save anymore
func _on_hitbox_body_exited(body):
	if (body.name == "objPlayer"):
		is_touching_save = false


func _on_timer_timeout():
	$Sprite2D.frame = 0
