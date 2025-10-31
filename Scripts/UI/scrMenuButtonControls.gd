extends TextureButton

@export_enum("button_left", "button_right", "button_up", "button_down", "button_jump", "button_shoot", "button_reset", "button_pause") var button_action: String = "button_left"
@export var button_text: String
@export var menu_node: Node = null

enum {KEYBOARD, CONTROLLER}
var input_device = KEYBOARD
var can_play_menu_sound = false


# Connects to signals emitted from the controls menu, and displays the initial
# text for each button
func _ready():
	
	if menu_node != null:
		menu_node.connect("change_input_device", change_input_device)
		menu_node.connect("reset_all_inputs", display_input)
	else:
		print("> Select the Controls menu node")
		print("> Some functions won't work otherwise!")
		
	display_input()


# Just for playing a button sound
func _physics_process(_delta):
	can_play_menu_sound = true


# Listening to inputs
func _input(input_event):
	
	# If the button is toggled and we press a key
	if button_pressed and input_event.is_pressed():
		
		# Keyboard
		if input_device == KEYBOARD:
			if input_event is InputEventKey:
				remap_keyboard_button(input_event)
				
		# Controller
		if input_device == CONTROLLER:
			if input_event is InputEventJoypadButton:
				remap_controller_button(input_event)
		
		# The button no longer needs to be pressed, so we "release" it.
		# There's a special case with the "select" key. We need to check if
		# it was last pressed, and if true, we wait until it gets released in
		# order to quit out of the rebind. The rest of buttons don't need to
		# do this
		if input_event.is_action("ui_accept"):
			if !input_event.is_pressed():
				button_pressed = false
		else:
			button_pressed = false
		


# Updates text from label
func display_input():
	$Label.text = str(button_text + GLOBAL_GAME.get_input_name(button_action, input_device))


"""
Every action has 2 input events, one for the keyboard and one for the
controller. Events are strings, inside of an action array. In this engine,
position [0] is for the keyboard and position [1] is for the controller.
The event order is important!
"""
# Keyboard remapping
func remap_keyboard_button(input_event):
	var previous_event_controller = InputMap.action_get_events(button_action)[1]

	InputMap.action_erase_events(button_action)
	InputMap.action_add_event(button_action, input_event)
	InputMap.action_add_event(button_action, previous_event_controller)
	
#	print("")
#	print("> Keyboard input changed")
#	print(InputMap.action_get_events(button_action))


# Controller remapping
func remap_controller_button(input_event):
	var previous_event_keyboard = InputMap.action_get_events(button_action)[0]
	
	InputMap.action_erase_events(button_action)
	InputMap.action_add_event(button_action, previous_event_keyboard)
	InputMap.action_add_event(button_action, input_event)
	
#	print("")
#	print("> Controller input changed")
#	print(InputMap.action_get_events(button_action))


# Changes the input method (KEYBOARD, CONTROLLER). Also re-displays the input
# event values for each button
func change_input_device():
	if input_device == KEYBOARD:
		input_device = CONTROLLER
	else:
		input_device = KEYBOARD
	
	display_input()
#	print("> Input device changed")




# Changes the text outline color via code and also emits a sound if available
func _on_focus_entered():
	$Label.set("theme_override_colors/font_outline_color", Color(1, 0, 0, 1))
	if (can_play_menu_sound == true):
		GLOBAL_SOUNDS.play_sound("sndMenuButton")


# Changes the text outline color via code
func _on_focus_exited():
	$Label.set("theme_override_colors/font_outline_color", Color(0.22, 0.22, 0.22, 1))


# Changes the text if the button is active (waiting for a rebind) or not
func _on_toggled(button_is_pressed):
	if button_is_pressed:
		$Label.text = str(button_text + "...")
	else:
		display_input()
