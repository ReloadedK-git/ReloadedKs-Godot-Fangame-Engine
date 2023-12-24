extends Control

var item_sprite: CompressedTexture2D
var item_text: String = ""
@onready var item_container: Node = $Display/MarginContainer2
@onready var container_timer: Node = $Display/MarginContainer2/Timer



func _ready():
	$Display/MarginContainer2.set_visible(false)
	set_HUD_scaling()
	handle_debug_mode()


func _physics_process(_delta):
	handle_debug_mode()



func set_HUD_scaling():
	$Display/MarginContainer.scale = Vector2(GLOBAL_SETTINGS.HUD_SCALING, GLOBAL_SETTINGS.HUD_SCALING)
	item_container.scale = Vector2(GLOBAL_SETTINGS.HUD_SCALING, GLOBAL_SETTINGS.HUD_SCALING)


# The debug HUD should only get shown as long as objPlayer exists in the scene,
# regardless of debug_mode being true or false
func handle_debug_mode() -> void:
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		if (GLOBAL_GAME.debug_mode == false):
			$Display/MarginContainer.set_visible(false)
			$Sprite2D.set_visible(false)
		else:
			$Display/MarginContainer.set_visible(true)
			$Display/MarginContainer/VBoxContainer/textDebug1.text = str(" Player X: ", round(GLOBAL_INSTANCES.objPlayerID.position.x), " ")
			$Display/MarginContainer/VBoxContainer/textDebug2.text = str(" Player Y: ", round(GLOBAL_INSTANCES.objPlayerID.position.y), " ")
			$Display/MarginContainer/VBoxContainer/textDebug3.text = str(" FPS: %d" % Engine.get_frames_per_second(), " ")
			
			# Extra check added for v4.2 compatibility
			if get_tree().get_current_scene() != null:
				$Display/MarginContainer/VBoxContainer/textDebug4.text = str(" Room: ", get_tree().get_current_scene().name, " ")
			
			$Sprite2D.set_visible(true)
			$Sprite2D.position = get_global_mouse_position()
			$Sprite2D.flip_h = !GLOBAL_INSTANCES.objPlayerID.xscale
	else:
		$Display/MarginContainer.set_visible(false)
		$Sprite2D.set_visible(false)


# Sets the item container
func handle_item_notification():
	
	# Shows the item container
	item_container.set_visible(true)
	
	# Sets sprite and texture from collectables
	$Display/MarginContainer2/Panel/Sprite2D.texture = item_sprite
	$Display/MarginContainer2/Panel/Label.text = str(item_text + " found!")
	
	# Starts the timer countdown
	container_timer.start()


# Hides the item container
func _on_timer_timeout():
	item_container.set_visible(false)
