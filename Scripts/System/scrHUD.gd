extends Control


func _ready():
	handle_debug_mode()


func _physics_process(_delta):
	handle_debug_mode()



# The debug HUD should only get shown as long as objPlayer exists in the scene,
# regardless of debug_mode being true or false
func handle_debug_mode() -> void:
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		if (GLOBAL_GAME.debug_mode == false):
			$Display.set_visible(false)
			$Sprite2D.set_visible(false)
		else:
			$Display.set_visible(true)
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
		$Display.set_visible(false)
		$Sprite2D.set_visible(false)
