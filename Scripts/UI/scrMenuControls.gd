extends Control

@export_file("*.tscn") var settings_menu: String

enum {KEYBOARD, CONTROLLER}
var input_device = KEYBOARD

signal change_input_device
signal reset_all_inputs

# Camera handling
@onready var camera_anchor_node: Node = $Environment/cameraAnchor


func _ready():
	
	# Sets focus to the first option (left)
	$ControlsContainer/Left.grab_focus()
	
	# Detects the input device and changes the InputDevice button's text
	initial_device_detection()
	
	# Loads settings from global autoload
	GLOBAL_SETTINGS.load_settings()
	
	# Set the anchor positions for each button in focus
	set_camera_anchor_positions()


# Updates anchor positions for the camera when an input is detected
func _input(event):
	if (event is InputEventKey) or (event is InputEventJoypadButton):
		set_camera_anchor_positions()



# Detects the input device and changes the InputDevice button's text 
# accordingly. If the device is a controller, it also emits a signal for
# the buttons to update their text
func initial_device_detection():
	input_device = GLOBAL_GAME.global_input_device
	
	if input_device == KEYBOARD:
		$ControlsContainer/InputDevice/Label.text = "Device: Keyboard"
	elif input_device == CONTROLLER:
		change_input_device.emit()
		$ControlsContainer/InputDevice/Label.text = "Device: Controller"


# Saves settings
func save_on_exit():
	GLOBAL_SETTINGS.save_settings()



func _on_input_device_pressed():
	change_input_device.emit()
	
	if input_device == KEYBOARD:
		input_device = CONTROLLER
		$ControlsContainer/InputDevice/Label.text = "Device: Controller"
	else:
		input_device = KEYBOARD
		$ControlsContainer/InputDevice/Label.text = "Device: Keyboard"
	
	GLOBAL_SOUNDS.play_sound("sndPause")


# Reset all input events to their default values. Also emits a signal which
# tells buttons to re-display their input values
func _on_reset_pressed():
	InputMap.load_from_project_settings()
	reset_all_inputs.emit()
	GLOBAL_SOUNDS.play_sound("sndPause")


# Back to settings
func _on_back_pressed():
	if settings_menu != null:
		save_on_exit()
		get_tree().change_scene_to_file(settings_menu)
		GLOBAL_SOUNDS.play_sound("sndPause")


# Set the anchor positions for each button in focus
func set_camera_anchor_positions():
	
	for controls_container_nodes in $ControlsContainer.get_children():
		if controls_container_nodes.has_focus():
			camera_anchor_node.position.y = controls_container_nodes.position.y
