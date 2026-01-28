extends CanvasLayer

var shake_amount: float = 2.0
var shake_duration: int = 6



# Makes the canvas layer visible (starts invisible for editor handling, in case
# you want to add this scene manually)
func _ready():
	$".".set_visible(true)



# Sets the shader material. Also duplicates it in case we want to have multiple
# screen shakes with different parameters.
# Slowly decreases the shake amount until it becomes 0.0, destroying itself
func _physics_process(delta: float) -> void:
	$ColorRect.material.set_shader_parameter("ShakeStrength", shake_amount)
	$ColorRect.material = $ColorRect.material.duplicate()
	
	shake_amount = move_toward(shake_amount, 0.0, delta * shake_duration)
	if shake_amount <= 0.0:
		queue_free()
