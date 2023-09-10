extends StaticBody2D

@onready var sprite_node = get_node("Sprite2D")
var is_visible: bool = false
var is_on_screen: bool = false
var player_id: Node = null


# Gets the player ID, sets it and also makes the block's sprite invisible
func _ready():
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		player_id = GLOBAL_INSTANCES.objPlayerID
	
	sprite_node.visible = false


# Gets collisions by using "duck typing", as long as certain conditions are
# met (for performance reasons), and calls a method to make itself visible
func _physics_process(_delta):
	
	if !is_visible and is_on_screen:
		if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
			if player_id.get_last_slide_collision() != null:
				for i in player_id.get_slide_collision_count():
					var collision = player_id.get_slide_collision(i)
					
					if collision.get_collider().has_method("make_visible"):
						collision.get_collider().make_visible()


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
