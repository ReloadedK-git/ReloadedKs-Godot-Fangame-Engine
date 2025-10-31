extends Control

var item_sprite: CompressedTexture2D
var item_text: String = ""
@onready var item_container: Node = $Display/MarginContainer2
@onready var container_timer: Node = $Display/MarginContainer2/Timer

var show_extra_debug: bool = false:
	set(val):
		show_extra_debug = val
		update_extra_label_vis()

@onready var extra_debug_labels: Dictionary = {
	"[1] Godmode": $Display/MarginContainer/VBoxContainer/textDebug6,
	"[2] Inf Jump": $Display/MarginContainer/VBoxContainer/textDebug7,
	"[3] Hitbox": $Display/MarginContainer/VBoxContainer/textDebug8,
	"[4] Save": $Display/MarginContainer/VBoxContainer/textDebug9
}



func _ready():
	$Display/MarginContainer2.set_visible(false)
	set_HUD_scaling()
	handle_debug_mode()


func _physics_process(_delta):
	handle_debug_mode()


# Checks if KEY_BACKSLASH is pressed, which toggles extra debug information
# if debug mode is active
func _unhandled_input(event: InputEvent) -> void:
	if GLOBAL_GAME.debug_mode:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_BACKSLASH:
				show_extra_debug = not show_extra_debug



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
			
			# Debug "cursor indicator"
			$Sprite2D.set_visible(not Input.is_action_pressed("button_debug_teleport"))
			$Sprite2D.position = get_global_mouse_position()
			$Sprite2D.flip_h = !GLOBAL_INSTANCES.objPlayerID.looking_at
			
			# Booleans for extra debug keys
			if show_extra_debug:
				var keys := extra_debug_labels.keys()
				extra_debug_labels[keys[0]].text = keys[0] + ": " + str(GLOBAL_GAME.debug_godmode)
				extra_debug_labels[keys[1]].text = keys[1] + ": " + str(GLOBAL_GAME.debug_inf_jump)
				extra_debug_labels[keys[2]].text = keys[2] + ": " + str(GLOBAL_GAME.debug_hitbox)
			
	else:
		$Display/MarginContainer.set_visible(false)
		$Sprite2D.set_visible(false)


# Updates labels for extra debug information
func update_extra_label_vis():
	$Display/MarginContainer/VBoxContainer/textDebug5.text = (
		"[\\]: Show " + ("Less" if show_extra_debug else "More")
	)
	for label in extra_debug_labels.values():
		label.set_visible(show_extra_debug)


# Handles scaling for the HUD elements
func set_HUD_scaling():
	$Display/MarginContainer.scale = Vector2(GLOBAL_SETTINGS.HUD_SCALING, GLOBAL_SETTINGS.HUD_SCALING)
	item_container.scale = Vector2(GLOBAL_SETTINGS.HUD_SCALING, GLOBAL_SETTINGS.HUD_SCALING)


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
