@tool
extends Polygon2D

@export var wind_force: int = 400
@export var enable_fans: bool = true
@onready var fan_sprites: Node2D = $Fans
@onready var wind_polygon: Polygon2D = $"."
@onready var wind_collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D



# Gets points from the drawn polygon and sets them for the collider. Also
# duplicates the shader material, so when editing we don't share the shader
# if we have multiple fans
func _ready() -> void:
	wind_collision_polygon.polygon = wind_polygon.get_polygon()
	material = material.duplicate()
	
	# Enable/disable the fan sprites and collision mask
	$Fans.set_visible(enable_fans)



func _physics_process(_delta: float) -> void:
	
	if Engine.is_editor_hint():
		wind_collision_polygon.polygon = wind_polygon.get_polygon()
		@warning_ignore("integer_division")
		material.set_shader_parameter("motion", Vector2.DOWN.rotated(deg_to_rad(get_rotation())) * (wind_force / 2))
		
		# Enable/disable the fan sprites and collision mask
		$Fans.set_visible(enable_fans)
	
	# If not in the editor, detects collisions with the player and moves it
	# according to the wind direction
	else:
		
		var overlapping_bodies = $Area2D.get_overlapping_bodies()
		for body in overlapping_bodies:
			var rotation_radians = global_rotation
			var forward_vector = Vector2(sin(rotation_radians), -cos(rotation_radians))
			
			body.stored_wind_velocity = forward_vector * wind_force



# Kills the player if it collides with the fans, only if they're enabled
func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if enable_fans:
		body.on_death()
