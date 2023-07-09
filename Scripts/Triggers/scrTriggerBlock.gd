@tool
extends AnimatableBody2D

var target_position: Vector2 = Vector2.ZERO
@export var trigger_id: int = 0

var is_snapped: bool = false
var distance_for_snapping: int = 1
var speed: int = 4


# Sets the target_position and a bunch of editor related things
func _ready():
	
	target_position = $Target.global_position
	$Target.texture = $Sprite2D.get_texture()
	
	if not Engine.is_editor_hint():
		$Target.hide()
		$Line2D.hide()



func _physics_process(delta):
	
	# Be careful when using @tool. On the editor, "GLOBAL_GAME" is not loaded,
	# so we tell Godot not to worry about it as long as the game isn't running
	if not Engine.is_editor_hint():
		if (target_position != Vector2.ZERO):
			if GLOBAL_GAME.triggered_events.has(trigger_id):
				
				# Moves as long as it isn't snapped to the global grid
				if !is_snapped:
					move_to_position(delta)
	else:
		
		# More editor related things. Sets the line points for $Line2D, for
		# some visual feedback
		var line_array: PackedVector2Array = [Vector2.ZERO, $Target.position]
		$Line2D.points = line_array



# Moves the object from point A to B, disabling the collision shape while
# moving, and snapping when the distance is small enough.
# After snapping, it enables the collision shape again and stops moving
func move_to_position(delta):
	
	# While moving, before snapping
	if position.distance_to(target_position) > distance_for_snapping:
		global_position = global_position.lerp(target_position, delta * speed)
		$CollisionShape2D.disabled = true
		$Sprite2D.modulate = 'ffffff80'
		
	else:
		
		# After snapping. Stops moving and re-enables the collision shape
		var snap = Vector2(GLOBAL_GAME.SNAPPING_GRID, GLOBAL_GAME.SNAPPING_GRID)
		
		position = position.snapped(snap)
		$CollisionShape2D.disabled = false
		$Sprite2D.modulate = 'ffffff'
		is_snapped = true
