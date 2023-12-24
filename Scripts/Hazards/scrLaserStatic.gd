@tool
extends Node2D

@onready var beam_raycast = $laserComponents/RayCast2D
@onready var beam_sprite = $laserComponents/Sprite2D
@onready var beam_initial_sprite = $laserComponents/Sprite2D2
@onready var beam_target = $beamTarget
var beam_length_offset: int = 8
var beam_animation_speed: int = 30



# Sets the beam
func _ready():
	if not Engine.is_editor_hint():
		
		# Hides the editor sprite
		beam_initial_sprite.visible = false
		
		# Automatic offset for the beam's sprite. Fixes visuals while also
		# keeping the laser outside of walls
		beam_sprite.centered = false
		beam_sprite.offset = Vector2(-beam_length_offset, -beam_sprite.texture.get_height() / 2)
		
		# Initial target position update
		beam_raycast.target_position = beam_target.position
	else:
		beam_initial_sprite.visible = true
		beam_sprite.centered = false
		beam_sprite.offset = Vector2(-beam_length_offset, -beam_sprite.texture.get_height() / 2)



# NOTE: Do not place the laser inside of walls (which includes the sides, floor
# and ceiling). The origin point of the node should always be outside of walls
func _physics_process(delta):
	if not Engine.is_editor_hint():
		
		# Collision checking and behaviour. If no collision is detected, the
		# beam returns to its original target_position
		if beam_raycast.is_colliding():
			if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
				GLOBAL_INSTANCES.objPlayerID.call("on_death")
		
		# Drawing the laser
		beam_sprite.rotation = beam_raycast.target_position.angle()
		beam_sprite.region_rect.size.x = beam_raycast.target_position.length() + beam_length_offset
		
		# Limit to region_rect.position.x
		if beam_sprite.region_rect.position.x > -100:
			beam_sprite.region_rect.position.x -= delta * beam_animation_speed
		else:
			beam_sprite.region_rect.position.x = 0
	
	else:
		# Target_position update (only inside the editor)
		beam_raycast.target_position = beam_target.position
		
		# Drawing the laser
		beam_sprite.rotation = beam_raycast.target_position.angle()
		beam_sprite.region_rect.size.x = beam_raycast.target_position.length() + beam_length_offset
		
		# Limit to region_rect.position.x
		if beam_sprite.region_rect.position.x > -100:
			beam_sprite.region_rect.position.x -= delta * beam_animation_speed
		else:
			beam_sprite.region_rect.position.x = 0
