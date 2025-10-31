@tool
extends Area2D

@export var sign_text: String = ""
@onready var text_label: Node = $Label
var player_is_colliding: bool = false
var text_alpha: float = 0.0
var alpha_amount: float = 0.1
var on_screen: bool = true



# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		# Sets the text invisible at start
		text_label.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
		text_label.text = sign_text
	else:
		text_label.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if not Engine.is_editor_hint():
		
		# Enables and disables visuals and functions if outside of view
		text_label.set_visible(on_screen)
		
		if on_screen == true:
			text_label.set_visible(true)
			
			if player_is_colliding == true:
				if text_alpha < 1:
					text_alpha += alpha_amount
			else:
				if text_alpha > 0:
					text_alpha -= alpha_amount * 2
			
			text_label.self_modulate = Color(1.0, 1.0, 1.0, text_alpha)
	else:
		text_label.text = sign_text



func _on_body_entered(_body):
	player_is_colliding = true

func _on_body_exited(_body):
	player_is_colliding = false

func _on_visible_on_screen_notifier_2d_screen_entered():
	on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	on_screen = false
