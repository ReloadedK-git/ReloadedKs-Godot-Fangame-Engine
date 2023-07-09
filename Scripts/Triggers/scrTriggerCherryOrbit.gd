extends AnimatableBody2D

@export var acceleration: int = 1
@export var trigger_id: int = 0
var direction: Vector2 = Vector2.ZERO
var orbit_velocity: Vector2 = Vector2.ZERO


# This multiplies our acceleration int to make it smaller, which feels better
# to play with. You can get rid of this if you want and make acceleration into
# a float instead of an int, but personally I think this feels a little better,
# since it allows you to use intergers to play with smaller values
var acceleration_multiplier: float = 0.01




func _physics_process(_delta):
	
	# We check if our speed is not 0
	if (acceleration != 0):
		
		# Clamp our speed so it doesn't become ridiculous
#		clamp(speed, 0, speed)
		
		# We check if the global trigger array matches our own trigger ID
		if GLOBAL_GAME.triggered_events.has(trigger_id):
			
			if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
				direction = position.direction_to(GLOBAL_INSTANCES.objPlayerID.position)
				orbit_velocity += (direction * (acceleration * acceleration_multiplier))
				
#				var orbit_velocity_max = orbit_velocity.clamp(Vector2(-max_acceleration, -max_acceleration), Vector2(max_acceleration, max_acceleration))
				# Since we want this object to move towards a direction once
				# and not every frame, we use the triggered variable to do it.
				# Otherwise the direction vector would update constantly
				move_and_collide(orbit_velocity)

