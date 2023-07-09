extends Control

@export_file("*.tscn") var settings_menu: String

enum {KEYBOARD, CONTROLLER}
var input_device = KEYBOARD

signal change_input_device
signal reset_all_inputs



func _ready():
	$ControlsContainer/Left.grab_focus()
	initial_device_detection()
	GLOBAL_SETTINGS.load_settings()
	



# Detects the input device and changes the InputDevice button's text 
# accordingly. If the device is a controller, it also emits a signal for
# the buttons to update their text
func initial_device_detection():
	input_device = GLOBAL_GAME.global_input_device
	
	if input_device == KEYBOARD:
		$ControlsContainer/InputDevice/Label.text = "Device: Keyboard"
	elif input_device == CONTROLLER:
		emit_signal("change_input_device")
		$ControlsContainer/InputDevice/Label.text = "Device: Controller"


func save_on_exit():
	GLOBAL_SETTINGS.save_settings()



func _on_input_device_pressed():
	emit_signal("change_input_device")
	
	if input_device == KEYBOARD:
		input_device = CONTROLLER
		$ControlsContainer/InputDevice/Label.text = "Device: Controller"
	else:
		input_device = KEYBOARD
		$ControlsContainer/InputDevice/Label.text = "Device: Keyboard"
	
	GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# Reset all input events to their default values. Also emits a signal which
# tells buttons to re-display their input values
func _on_reset_pressed():
	InputMap.load_from_project_settings()
	emit_signal("reset_all_inputs")
	GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)


# Back to settings
func _on_back_pressed():
	if settings_menu != null:
		save_on_exit()
		get_tree().change_scene_to_file(settings_menu)
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)






