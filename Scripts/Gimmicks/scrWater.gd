@tool
extends Polygon2D

@export_enum("Regular:1", "Refresh:2", "Catharsis:3") var water_type: int = 1
@onready var water_polygon: Polygon2D = $"."
@onready var water_collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D


# Gets points from the drawn polygon and sets them for the collider
func _ready() -> void:
	water_collision_polygon.polygon = water_polygon.get_polygon()


# Updates water color
func _physics_process(_delta) -> void:
	if Engine.is_editor_hint():
		water_color()



# Changes water color according to its type
func water_color():
	
	# Regular, refresh and catharsis
	match water_type:
		1:
			water_polygon.color = Color("#4040ff7d")
		2:
			water_polygon.color = Color("#3fdfff7f")
		3:
			water_polygon.color = Color("#9999997f")
