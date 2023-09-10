extends AnimatableBody2D

var looking_at: int
var bullet_direction: Vector2 = Vector2.ZERO
var bullet_speed: int = 12
var is_moving: bool = true

# Check scrGlobalClass, inside of res://Scripts/Globals
var attack_type: int = GlobalClass.weapon_type.BULLET
var attack_damage: int = GLOBAL_GAME.player_bullet_damage


# The direction the bullet should be moving towards. This is assigned from
# objPlayer, on _handle_shooting(). Once we get the direction we want, we add
# the proper speed to bullet_direction's x
func _ready():
	if (looking_at == 1):
		bullet_direction.x = bullet_speed 
	elif (looking_at == -1):
		bullet_direction.x = -bullet_speed

func _physics_process(_delta):
	
	# We first check if the bullet can move (is not colliding with a wall).
	# If it can, move and check for future collisions
	if (is_moving == true):
		var collision = move_and_collide(bullet_direction)
		
		# If we collided with something, 2 things can happen:
		# 1) The object we collided with has a method called "react_to_hit"
		# 2) The object we collided with doesn't have a method called 
		# "react_to_hit"
		#
		# For option 1), we call "react_to_hit" and inmediately destroy the
		# projectile. For option 2), we stop moving and colliding for 1 frame,
		# which will trigger the _bullet_destroy() method, and has a nice
		# visual effect
		if collision:
			if collision.get_collider().has_method("react_to_hit"):
				collision.get_collider().call("react_to_hit", attack_type, attack_damage)
				queue_free()
				
			is_moving = false
	else:
		_bullet_destroy()


# Controls what should happen once the bullet either hits a wall or finishes
# its timer
func _bullet_destroy() -> void:
	queue_free()


# Timer signal. Destroys the bullet after some wait time (0.4s)
func _on_timer_timeout():
	_bullet_destroy()


# Destroys itself when outside of the view
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
