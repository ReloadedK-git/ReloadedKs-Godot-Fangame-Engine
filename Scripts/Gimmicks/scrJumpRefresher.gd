extends Area2D

var can_interact: bool = true
var wave_time: float = 0.0
var wave_amplitude: float = 5.0


# Sets some of the particle emitter's properties
func _ready():
	$GPUParticles2D.one_shot = true
	$GPUParticles2D.emitting = false


func _physics_process(delta):
	
	# Color and alpha channel
	if (can_interact == true):
		$Sprite2D.modulate = 'ffffff'
	else: 
		$Sprite2D.modulate = 'ffffff80'
	
	# Famous "wave effect"
	wave_time += delta * 2
	var wave_constant = sin(wave_time) * wave_amplitude
	
	# Changes position of several nodes
	$Sprite2D.position.y = wave_constant
	$CollisionShape2D.position.y = wave_constant
	$GPUParticles2D.position.y = wave_constant


# When the player collides with this object, it emits particles, gives d_jump
# back to it, plays a sound and disables further interaction until a timer is
# completed
func _on_body_entered(body):
	if (can_interact == true):
		can_interact = false
		$GPUParticles2D.restart()
		$GPUParticles2D.emitting = true
		$Timer.start()
		body.d_jump = true
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndJumpRefresher)


# Enables interaction with the player again
func _on_timer_timeout():
	if (can_interact == false):
		can_interact = true
		$GPUParticles2D.emitting = false
		
