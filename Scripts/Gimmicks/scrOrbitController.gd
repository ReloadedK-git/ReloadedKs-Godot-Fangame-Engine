@tool
extends Node2D

@export var radius: Vector2i = Vector2i.ONE * 64
@export var rotation_time: float = 4.0
var orbiters: Array = []
var orbit_angle_offset: float = 0.0
var prev_child_count: int = 0


func _ready() -> void:
	
	# Makes the center sprite invisible when ingame
	if not Engine.is_editor_hint():
		$Sprite2D.visible = false


func _physics_process(delta):
	
	# If any child has been removed or added to the controller
	if prev_child_count != get_child_count():
		
		# Update the variable for checking and reset platform references
		prev_child_count = get_child_count()
		_find_orbiters()
	
	# Increment the angle so that it completes one full rotation in the given number of seconds.
	if not Engine.is_editor_hint():
		orbit_angle_offset += 2 * PI * delta / float(rotation_time)
	else:
		orbit_angle_offset = 0
	
	# Wrap the angle to keep it nice and tidy, and to prevent unlikely overflow
	orbit_angle_offset = wrapf(orbit_angle_offset, -PI, PI)
	
	# Update platform positions
	_update_orbiters()


# Updates platform positions by determining how far they should orbit from each other
func _update_orbiters():
	if orbiters.size() != 0:
		
		# Get the spacing by diving a full circle by the number of orbiters in controller
		var spacing = 2 * PI / float(orbiters.size())
		
		# Iterate through all their references
		for i in orbiters.size():
			
			# Create an empty Vector2 since we have to update the orbiters position at once
			# instead of one axis at a time, due to sync_to_physics being enabled.
			var new_position = Vector2()
			
			# Bit of trig to determine where the orbiters should be.
			# `spacing * i` spreads the orbiters out based on their iteration
			# `orbit_angle_offset` is where the first orbiter should be
			# `radius` moves the orbiters away from the controller
			new_position.x = cos(spacing * i + orbit_angle_offset) * radius.x
			new_position.y = sin(spacing * i + orbit_angle_offset) * radius.y
			orbiters[i].position = new_position


# Iterates through the children of this node, finding all orbiters in the `Orbiter` group.
func _find_orbiters():
	
	# Reset the array, otherwise we'll just keep piling on orbiters
	orbiters = []
	for child in get_children():
		if child.is_in_group("Orbiter"):
			orbiters.append(child)
			
			if not Engine.is_editor_hint():
				# Very important for moving platforms
				if child.is_class("AnimatableBody2D"):
					child.set_sync_to_physics(true)
