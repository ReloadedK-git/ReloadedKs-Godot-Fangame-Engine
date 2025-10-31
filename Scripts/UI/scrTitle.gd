extends Control

@export_file("*.tscn") var main_menu: String
@onready var screen_fade_animation = get_node("Environment/ColorRect/AnimationPlayer")
@onready var tilemap = get_node("Visuals/til32x32")
@onready var apple_1 = get_node("Visuals/AnimatedSprite2D2")
@onready var apple_2 = get_node("Visuals/AnimatedSprite2D3")
@onready var savepoint = get_node("Visuals/Sprite2D")

var object_offscreen: int = -16
var object_return: int = 816



# Screen fade animation
func _ready():
	screen_fade_animation.play("screen_fade")


# Visuals
func _physics_process(_delta):
	
	# Lambda function for scrolling
	var object_scrolling = func(object_id, object_scrolling_amount):
		if object_id.position.x > object_offscreen:
			object_id.position.x -= object_scrolling_amount
		else:
			object_id.position.x = object_return
	
	# Scrolling objects
	object_scrolling.call(tilemap, 1)
	object_scrolling.call(apple_1, 2)
	object_scrolling.call(apple_2, 3)
	object_scrolling.call(savepoint, 1)


# Input handling ("Press any key". Includes controller input)
func _input(event):
	if (event is InputEventKey) or (event is InputEventJoypadButton):
		if event.pressed:
			if main_menu != null:
				get_tree().change_scene_to_file(main_menu)
				GLOBAL_SOUNDS.play_sound("sndPause")
	
