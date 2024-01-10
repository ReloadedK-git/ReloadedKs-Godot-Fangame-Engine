extends StaticBody2D

@export var fading_time: float = 1.0
var reset_seconds: float = 4.0
var is_fading: bool = false
var fading_alpha: float = 0.016

@onready var block_sprite: Node = get_node("Sprite2D")
@onready var timer_node: Node = get_node("Timer")



func _physics_process(_delta):
	if is_fading:
		
		# Reduces alpha from sprite. If entirely transparent, disables its
		# collision shape
		if block_sprite.get_self_modulate().a > 0:
			block_sprite.self_modulate.a -= (fading_alpha / fading_time)
		else:
			$CollisionShape2D.set_disabled(true)
		
		# Resets sprite alpha, re-enables collisions, stops timer and stops
		# fading.
		# Timers aren't very precise so we use a number close to 0 but not
		# quite as small
		if timer_node.get_time_left() < 0.05:
			block_sprite.self_modulate.a = 1
			$CollisionShape2D.set_disabled(false)
			timer_node.stop()
			is_fading = false



func _on_area_2d_body_entered(_body):
	
	# Starts the timer and sets its wait time to the fading seconds plus the
	# default reset time
	if timer_node.is_stopped():
		timer_node.start(fading_time + reset_seconds)
	
	# Starts fading if hasn't already
	if !is_fading:
		is_fading = true
	
