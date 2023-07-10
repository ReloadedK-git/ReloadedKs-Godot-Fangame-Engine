extends AnimatableBody2D

@export var move_speed: Vector2 = Vector2.ZERO


func _physics_process(_delta):
	if (move_speed != Vector2.ZERO):
		
		# Godot will complain about physics bodies using move_and_collide() 
		# while sync_to_physics is enabled. A hacky but somehow accurate 
		# solution to this is disabling sync_to_physics, using 
		# move_and_collide(), re-enabling sync_to_physics and using the values 
		# it returned later on.
		set_sync_to_physics(false);
		var collision_check = move_and_collide(move_speed / 2, true);
		
		# Re-enable sync_to_physics
		set_sync_to_physics(true);
		
		# If a collision with a platform block was detected, the movement speed
		# gets reversed
		if collision_check:
			move_speed = -move_speed
		
		# Change local position directly
		position += move_speed
		
