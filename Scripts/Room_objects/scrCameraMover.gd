extends Polygon2D

@export var camera_target: Node = null
@export var camera_smooth: bool = false
@export var tween_time: float = 1.0
@export_enum("EASE_IN:0", "EASE_OUT:1", "EASE_IN_OUT:2", "EASE_OUT_IN:3") var ease_type: int = 1
@export_category("Limits")
@export var stop_left_at: int = 0
@export var stop_up_at: int = 0
@export var stop_right_at: int = 0
@export var stop_down_at: int = 0

@onready var camera_polygon: Polygon2D = $"."
@onready var camera_collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D



# Hides the visible polygon2d and uses its points for the polygon collider
func _ready():
	hide()
	camera_collision_polygon.polygon = camera_polygon.get_polygon()



# Sets the camera's limits on player collision
func _on_area_2d_body_entered(_body: Node2D) -> void:
	if camera_target.is_in_group("Camera"):
		
		# Change global camera limits to this scene's
		change_global_limits()
		
		# If camera smooth is enabled, sets and tweens the camera limits
		if camera_smooth:
			var tween = get_tree().create_tween()
			tween = tween.set_parallel(true)
			tween.set_ease(ease_type)
			tween.tween_property(camera_target, "limit_left", stop_left_at, tween_time).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(camera_target, "limit_top", stop_up_at, tween_time).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(camera_target, "limit_right", stop_right_at, tween_time).set_trans(Tween.TRANS_QUAD)
			tween.tween_property(camera_target, "limit_bottom", stop_down_at, tween_time).set_trans(Tween.TRANS_QUAD)
		
		# If camera smooth is disabled, sets the camera limits instantly
		else:
			for limit_array_1 in 4:
				var limit_array_2 = [stop_left_at, stop_up_at, stop_right_at, stop_down_at]
				camera_target.set_limit(limit_array_1, limit_array_2[limit_array_1])



# Change global camera limits to this scene's
func change_global_limits() -> void:
	GLOBAL_GAME.global_camera_limits = [stop_left_at, stop_up_at, stop_right_at, stop_down_at]
