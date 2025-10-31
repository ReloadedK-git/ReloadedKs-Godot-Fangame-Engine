extends Node2D

# Load your particle materials inside of this "Particles List" array. They
# will get preloaded when the game first runs.
@export var particles_list : Array[ParticleProcessMaterial]


# Loops through each material resource and "emits" them once when the game
# first loads, avoiding stutters when in-game
func _ready() -> void:
	for particle_effect in particles_list:
		var particle_instance: GPUParticles2D = GPUParticles2D.new()
		particle_instance.process_material = particle_effect
		particle_instance.set_modulate(Color(1,1,1,0))
		particle_instance.one_shot = true
		particle_instance.emitting = true
		add_child(particle_instance)
