extends CharacterBody2D

@export var move_speed: Vector2 = Vector2.ZERO

func _physics_process(_delta):
	
	# If the object has no speed, we don't need to process anything else
	if (move_speed != Vector2.ZERO):
	
		# We run move_and_collide each physics frame, also assigning it to the
		# object_collision local variable
		var object_collision = move_and_collide(move_speed)
		
		# If there's a collision, we then bounce move_speed using the collision
		# normal, which means it will bounce horizontally or vertically
		# depending on how it collided. It looks complicated but if you look
		# up some pong tutorials, it's the same thing as how the ball bounces
		# against walls and the paddles
		if (object_collision):
			move_speed = move_speed.bounce(object_collision.get_normal()) 
	

