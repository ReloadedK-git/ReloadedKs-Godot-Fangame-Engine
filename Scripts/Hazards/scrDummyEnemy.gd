extends AnimatableBody2D

var total_hp: int = 10


# Looks at the player if it exists, at startup
func _ready():
	look_at_player()


# Looks at the player if it exists
func _physics_process(_delta):
	look_at_player()


# If the player exists, it detects where it is in relation to itself and
# flips its sprite and collision shape accordingly
func look_at_player() -> void:
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		if GLOBAL_INSTANCES.objPlayerID.position.x < position.x:
			$AnimatedSprite2D.flip_h = true
			$CollisionShape2D.position.x = -1
		else:
			$AnimatedSprite2D.flip_h = false
			$CollisionShape2D.position.x = 1


# An important function which defines what happens when hit with an attack
func react_to_hit(attack_type, attack_damage):
	
	# Hit by a bullet. Bullets deal a certain amount of damage, which is
	# defined globally on scrGlobalGame.
	# If your game has damage increasing upgrades, for example, you should
	# define their damage globally and objects which interact with bullets
	# should just read those values
	if (attack_type == 0):
		
		$AnimationPlayer.stop(false)
		$AnimationPlayer.play("hitBlink")
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndHit)
		total_hp -= attack_damage
	
	# If total hp is zero or less, we destroy this object
	if total_hp <= 0:
		on_death()


# The death/destroyed event
func on_death() -> void:
	queue_free()
