extends AnimatableBody2D

@export var speed: int = 0
@export var trigger_id: int = 0
var direction: Vector2 = Vector2.ZERO
var triggered: bool = false



func _physics_process(_delta):
	
	# We check if our speed is not 0
	if (speed != 0):
		
		# We check if the global trigger array matches our own trigger ID
		if GLOBAL_GAME.triggered_events.has(trigger_id):
			
			# If this object wasn't triggered before, it checks if objPlayer
			# exists, then checks its direction and sets triggered to true
			if !triggered:
				if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
					direction = position.direction_to(GLOBAL_INSTANCES.objPlayerID.position)
					
				triggered = true
			else:
				
				# Since we want this object to move towards a direction once
				# and not every frame, we use the triggered variable to do it.
				# Otherwise the direction vector would update constantly
				move_and_collide(direction * speed)


# Destroys itself when outside of the view
func _on_visible_on_screen_notifier_2d_screen_exited():
	if triggered:
		queue_free()
