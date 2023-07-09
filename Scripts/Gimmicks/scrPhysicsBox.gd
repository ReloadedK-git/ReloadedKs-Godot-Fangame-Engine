extends RigidBody2D

var player_id: Node = null
var collider_left: bool = false
var collider_right: bool = false
var impulse_force_amount: int = 100


func _ready():
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		player_id = GLOBAL_INSTANCES.objPlayerID


func _integrate_forces(_delta) -> void:
	
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		if player_id.get_last_slide_collision() != null:
			for i in player_id.get_slide_collision_count():
				var collision = player_id.get_slide_collision(i)
				
				if collision.get_collider().has_method("box_add_impulse"):
					collision.get_collider().box_add_impulse()


func box_add_impulse():
	if linear_velocity == Vector2.ZERO:
		if player_id.is_on_floor():
			if collider_left:
				apply_central_impulse(Vector2(impulse_force_amount, 0))
		
			if collider_right:
				apply_central_impulse(Vector2(-impulse_force_amount, 0))


# Check for player collisions from the left
func _on_collider_left_body_entered(_body):
	collider_left = true
func _on_collider_left_body_exited(_body):
	collider_left = false


# Check for player collisions from the right
func _on_collider_right_body_entered(_body):
	collider_right = true
func _on_collider_right_body_exited(_body):
	collider_right = false
