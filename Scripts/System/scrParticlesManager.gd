extends Node2D

# Load your particle materials inside of this "Particles List" array. They
# will get preloaded when the game first runs.
@export var particles_list : Array[ParticleProcessMaterial]
var particle_spawn_position: Vector2i = Vector2i(800, 608)



func _ready() -> void:
	
	# Changes spawn position somewhere far away off-screen
	position = particle_spawn_position * -100
	
	# Loops through each material resource and "emits" them once when the game
	# first loads, avoiding stutters when compiling them in-game
	await Engine.get_main_loop().physics_frame
	for particle_effect in particles_list:
		var particle_instance: GPUParticles2D = GPUParticles2D.new()
		particle_instance.process_material = particle_effect
		particle_instance.one_shot = true
		particle_instance.emitting = true
		add_child(particle_instance)
