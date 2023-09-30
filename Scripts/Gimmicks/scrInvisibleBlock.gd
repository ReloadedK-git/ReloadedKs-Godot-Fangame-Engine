extends StaticBody2D

@onready var sprite_node = get_node("Sprite2D")
@onready var area_shape_node = get_node("Area2D/CollisionShape2D")
var is_visible: bool = false
var is_on_screen: bool = false
var area_shape_scaling: float = 1.006


# Makes the object's sprite invisible and changes the detection area scale
func _ready():
	sprite_node.visible = false
	area_shape_node.scale = Vector2(area_shape_scaling, area_shape_scaling)


# Makes the object visible and plays the classic sndBlockChange sound
func make_visible():
	if !is_visible:
		sprite_node.visible = true
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndBlockChange)
		is_visible = true


# Checks if the object is inside or outside of the screen. This helps
# performance since we're not constantly checking for collisions every frame
func _on_visible_on_screen_notifier_2d_screen_entered():
	is_on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	is_on_screen = false

# Makes the object's sprite visible when touched
func _on_area_2d_body_entered(_body):
	make_visible()
