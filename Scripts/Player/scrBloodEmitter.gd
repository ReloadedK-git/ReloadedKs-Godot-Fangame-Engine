extends GPUParticles2D

var side: int = 0
var sprite_blink: bool = true

# Sprite flipping
func _ready():
	
	# Gets the side from objPlayer, to flip the sprite accordingly
	if (side == 1):
		$Sprite2D.flip_h = false
	elif (side == -1):
		$Sprite2D.flip_h = true


# Toggles the alpha value of the entire object. Called via timer (TimerBlink)
func blinking_effect() -> void:
	sprite_blink = !sprite_blink
	
	if sprite_blink:
		modulate.a = 0.5
	else:
		modulate.a = 1.0


# Stops emitting particles
func _on_timer_emitter_stop_timeout():
	$".".emitting = false

# Destroy event
func _on_timer_destroy_timeout():
	
	# Creates the classic GAMEOVER screen if autoreset is not enabled
	if !GLOBAL_SETTINGS.AUTORESET:
		var gameover = load("res://Objects/Player/objGameOver.tscn")
		var gameover_id = gameover.instantiate()
		add_sibling(gameover_id)
	
	# Destroys object
	queue_free()

# Changes the sprite's alpha value
func _on_timer_blink_timeout():
	blinking_effect()

# Resets automatically, if the global setting is set to "true"
func _on_timer_autoreset_timeout():
	if GLOBAL_SETTINGS.AUTORESET:
		GLOBAL_GAME.reset()
