extends StaticBody2D

@export var bounce_amount: int = 400
@onready var anim_node: Node = get_node("AnimatedSprite2D")
var collision_distance: int = -4


# Gets collision with player, plays sprite animation, sound and adds jump
# velocity to the player
func _physics_process(_delta):
	
	var collision = move_and_collide(Vector2(0, collision_distance), true)
	if collision:
		
		# Plays animation and sound if the animation isn't currently playing
		if !anim_node.is_playing():
			anim_node.play("default")
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndBouncyBlock)
		
		# Adds vertical velocity and gives back djump to the player
		var player_collision = collision.get_collider()
		player_collision.velocity.y = -bounce_amount
		player_collision.d_jump = true


# Resets animation when finished
func _on_animated_sprite_2d_animation_finished():
	anim_node.stop()
