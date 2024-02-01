extends Control

@onready var scroll_container = get_node("CanvasLayer/ScrollContainer")
@onready var margin_container = get_node("CanvasLayer/ScrollContainer/MarginContainer")
@onready var visible_scrollbar = get_node("CanvasLayer/Visuals/VScrollBar")

var scroll_current: int = 0
var scroll_amount: int = 8
var scroll_end: int = 0
var margin_container_amount: int = 64
var pause_menu := preload("res://Objects/UI/objPauseMenuMain.tscn")



func _ready():
	
	# Sets vertical margins for MarginContainer
	margin_container.add_theme_constant_override("margin_top", margin_container_amount)
	margin_container.add_theme_constant_override("margin_bottom", margin_container_amount)
	
	# Calculates scroll_end
	scroll_end = margin_container.get_size().y - scroll_container.get_size().y
	
	# Matches the invisible ScrollContainer scrollbar with the visible
	# scrollbar
	match_scrollbars()
	
	# Updates bottom label
	bottom_text_labels_update()


func _physics_process(_delta):
	
	# Updates bottom label
	bottom_text_labels_update()
	
	# Returns to the main pause menu by pressing "shoot"
	if Input.is_action_just_pressed("ui_select"):
		if pause_menu != null:
			var pause_menu_instance = pause_menu.instantiate()
			add_sibling(pause_menu_instance)
			
			# Play sound and destroy itself
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndPause)
			queue_free()
	
	# Unsets pause and quits this menu by pressing "pause"
	if Input.is_action_just_pressed("button_pause"):
		
		# Unset pause, unpause game
		GLOBAL_GAME.game_paused = false
		get_tree().set_pause(false)
		
		# Destroy itself
		queue_free()
	
	# Scrolls down
	if Input.is_action_pressed("ui_down"):
		if scroll_current < scroll_end:
			scroll_current += scroll_amount
	
	# Scrolls up
	if Input.is_action_pressed("ui_up"):
		if scroll_current > 0:
			scroll_current -= scroll_amount
	
	# Scrolls down twice as fast
	if Input.is_action_pressed("ui_right"):
		if scroll_current < scroll_end - scroll_amount:
			scroll_current += scroll_amount * 2
		else:
			scroll_current = scroll_end
	
	# Scrolls up twice as fast
	if Input.is_action_pressed("ui_left"):
		if scroll_current > 0 + scroll_amount:
			scroll_current -= scroll_amount * 2
		else:
			scroll_current = 0
	
	# Sets vertical scrolling for the scroll_container
	scroll_container.set_v_scroll(scroll_current)
	
	# Matches the invisible ScrollContainer scrollbar with the visible
	# scrollbar
	match_scrollbars()



# Matches the invisible ScrollContainer scrollbar with the visible
# scrollbar. This shouldn't have to be neccesary, but somehow setting the mouse
# filter to "ignore" in MarginContainer still registers mouse clicks and drag,
# requiring it to be "never shown" and making an extra visible scrollbar which
# actually works the way it should. Might get patched on future versions of
# Godot
func match_scrollbars():
	
	var scroll_container_bar = scroll_container.get_v_scroll_bar()
	
	visible_scrollbar.min_value = scroll_container_bar.min_value
	visible_scrollbar.max_value = scroll_container_bar.max_value
	visible_scrollbar.step = scroll_container_bar.step
	visible_scrollbar.page = scroll_container_bar.page
	visible_scrollbar.value = scroll_container_bar.value


# Updates the labels to their proper keys. Keys are returned as text from
# the global input map (check scrGlobalGame/get_input_name())
func bottom_text_labels_update():
	var key_back = GLOBAL_GAME.get_input_name("ui_select", GLOBAL_GAME.global_input_device)
	
	$CanvasLayer/Visuals/Label2.text = "[" + key_back + "] Back "
