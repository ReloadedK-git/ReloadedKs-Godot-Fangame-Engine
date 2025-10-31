extends TextureButton

@export var _text: String
var can_play_menu_sound = false
var color_focused: Color = Color(1, 0, 0, 1)
var color_unfocused: Color = Color(0.22, 0.22, 0.22, 1)


# Sets the text to whathever it needs to be on the "_text" export variable.
# It should be changed from rMainMenu
func _ready():
	$Label.text = _text



# We wait 1 physics frame to allow the buttons to make a sound. Otherwise the
# first thing that happens when entering the menu room is hearing a random beep
# when the player hasn't even pressed a key yet
func _physics_process(_delta):
	can_play_menu_sound = true



# Changes the text outline color via code and also emits a sound if available
func _on_focus_entered():
	$Label.set("theme_override_colors/font_outline_color", color_focused)
	if (can_play_menu_sound == true):
		GLOBAL_SOUNDS.play_sound("sndMenuButton")

# Changes the text outline color via code
func _on_focus_exited():
	$Label.set("theme_override_colors/font_outline_color", color_unfocused)
	
