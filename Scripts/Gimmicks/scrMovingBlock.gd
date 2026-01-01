extends AnimatableBody2D

@export var move_speed: Vector2 = Vector2.ZERO
@export_enum("None:1", "Stop:2", "Bounce:3") var collision_interaction: int = 1
var start_moving: bool = false



func _ready():
	
	# If move_speed is zero, we don't really need to check for collisions, so
	# we queue_free() their nodes saving some memory
	if (move_speed == Vector2.ZERO):
		$playerDetector.queue_free()



func _physics_process(_delta):
	
	# We only check this condition if our move_speed vector is zero. Makes sure
	# we don't get any errors if we don't have any shapecast2d detection
	if (move_speed != Vector2.ZERO):
		
		# We process stuff here if the object isn't moving yet.
		# Then, we check if the raycast returns a collision (check the collision mask)
		# (We then check if the player exists in the world)
		# (Then if the player is floored)
		# Finally, we set start_moving to true and free the rayshape node. We won't
		# be using it again anyways
		if (start_moving == false):
			if ($playerDetector.is_colliding() == true):
				if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
					if GLOBAL_INSTANCES.objPlayerID.is_on_floor():
						start_moving = true
						$playerDetector.queue_free()
		
		
		# If the object is moving, we do stuff related to block collisions
		if (start_moving == true):
			
			# Godot will complain about physics bodies using move_and_collide() 
			# while sync_to_physics is enabled. A hacky but somehow accurate 
			# solution to this is disabling sync_to_physics, using 
			# move_and_collide(), re-enabling sync_to_physics and using the values 
			# it returned later on.
			set_sync_to_physics(false);
			var collision_check = move_and_collide(move_speed / 2, true, 0.04);
			
			# Re-enable sync_to_physics
			set_sync_to_physics(true);
			
			# If a collision with a platform block was detected, the movement speed
			# gets reversed
			if collision_check:
				
				# Stops when colliding with a platform block
				if (collision_interaction == 2):
					move_speed = Vector2.ZERO
				
				# Bounces when colliding with a platform block
				if (collision_interaction == 3):
					move_speed = -move_speed
			
			# Manually adds to the speed. We don't use delta because writting "2"
			# is much easier than writting "120"
			position += move_speed
	else:
		
		# If our interaction is set to stop, it should also snap perfectly
		position = position.snapped(Vector2.ONE * GLOBAL_GAME.SNAPPING_GRID)


# Destroys itself if it doesn't stop or bounce, and is outside of the view
func _on_visible_on_screen_notifier_2d_screen_exited():
	if collision_interaction == 1:
		queue_free()
