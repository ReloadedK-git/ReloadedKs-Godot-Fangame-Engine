extends GPUParticles2D

# Sets stuff from code. Doing it from the editor is kinda shaky, plus this
# destroys particles exactly when they're not being emitted anymore
func _ready():
	emitting = true
	one_shot = true


func _physics_process(_delta):
	if not emitting:
		queue_free()

