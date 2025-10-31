extends StaticBody2D

@onready var sprite_node = get_node("Sprite2D")
@onready var area_shape_node = get_node("Area2D/CollisionShape2D")
var block_is_visible: bool = false
var block_is_on_screen: bool = false
var area_shape_scaling: float = 1.006


# Makes the object's sprite invisible and changes the detection area scale
func _ready():
	sprite_node.visible = false
	area_shape_node.scale = Vector2(area_shape_scaling, area_shape_scaling)


# Makes the object visible and plays the classic sndBlockChange sound
func make_visible():
	if !block_is_visible:
		sprite_node.visible = true
		GLOBAL_SOUNDS.play_sound("sndBlockChange")
		block_is_visible = true


# Checks if the object is inside or outside of the screen. This helps
# performance since we're not constantly checking for collisions every frame
func _on_visible_on_screen_notifier_2d_screen_entered():
	block_is_on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	block_is_on_screen = false

# Makes the object's sprite visible when touched
func _on_area_2d_body_entered(_body):
	make_visible()
