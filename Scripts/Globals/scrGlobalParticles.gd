# Caches every particle at startup so we don't get stutters in game.
extends CanvasLayer

# This is were we preload each and every particle material
var bloodEmitterParticle = preload("res://Resources/Materials/matBloodEmitter.tres")
var jumpParticleParticle = preload("res://Resources/Materials/matJumpParticle.tres")
var jumpRefresherParticle = preload("res://Resources/Materials/matJumpRefresher.tres")

# We then add them to the particle_materials list
var particle_materials = [
	bloodEmitterParticle,
	jumpParticleParticle,
	jumpRefresherParticle
]

# Finally, we "compile" each particle material at startup, caching them
func _ready():
	for particle_material in particle_materials:
		
		# Might wanna change this one if using the OpenGL renderer, to CPUParticles2D
		var particles_instance = GPUParticles2D.new()
		particles_instance.set_process_material(particle_material)
		particles_instance.set_one_shot(true)
		particles_instance.set_modulate(Color(1,1,1,0))
		particles_instance.set_emitting(true)
		self.add_child(particles_instance)
		
