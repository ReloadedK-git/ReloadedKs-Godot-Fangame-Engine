extends AnimatableBody2D

@export var move_speed: Vector2 = Vector2.ZERO

func _ready():
	if (move_speed == Vector2.ZERO):
		$platformBlockDetector.queue_free()


func _physics_process(_delta):
	if (move_speed != Vector2.ZERO):
		$platformBlockDetector.set_target_position(Vector2(move_speed))
	
		if $platformBlockDetector.is_colliding():
			move_speed = -move_speed
		
		position += move_speed
	
		# The shapecast node is disabled by default until the platform moves for
		# at least a single frame. Once it does, it gets re-enabled and ready
		# to detect collisions and bounce
		if $platformBlockDetector.collide_with_bodies == false:
			$platformBlockDetector.collide_with_bodies = true
	

