extends Polygon2D

@onready var wrapper_polygon: Polygon2D = $"."
@onready var wrapper_collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@export var room_size: Vector2i = Vector2i(800, 608)


# Hides the visible polygon2d and uses its points for the polygon collider
func _ready():
	hide()
	wrapper_collision_polygon.polygon = wrapper_polygon.get_polygon()



# "Wraps" player position on exit collision. Set room_size on the editor if you
# have rooms bigger than 800x608
func _on_area_2d_body_exited(body: Node2D) -> void:
	body.position.x = wrapf(body.position.x, 0, room_size.x)
	body.position.y = wrapf(body.position.y, 0, room_size.y)
