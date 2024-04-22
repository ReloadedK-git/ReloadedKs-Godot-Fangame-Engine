@tool
extends AnimatableBody2D

## If [code]true[/code], the spike begins in its hidden position.
@export var spike_hidden: bool = false

## The direction the spike is pointing towards.
@export var spike_direction: Dir = Dir.UP:
	set(value):
		spike_direction = value
		set_angle()
		set_initial_positions()

var position_shown: Vector2 = Vector2.ZERO
var position_hidden: Vector2 = Vector2.ZERO
var snap_range = Vector2(2, 2)
var spike_speed: int = 16
var distance_for_snapping: int = 1
var changing_positions: bool = false
var is_on_screen: bool = false

# Direction enum
enum Dir {
	UP, RIGHT, DOWN, LEFT
}



func _ready():
	
	# Change angle based on direction
	set_angle()
	
	if not Engine.is_editor_hint():
		set_initial_positions()
		
		# Sets the initial spike position, without lerp
		if spike_hidden:
			position = position_hidden
			
			# If hidden, disabled collisions for one frame
			$CollisionPolygon2D.disabled = true
		else:
			position = position_shown
		
		# For switch_positions() to work
		spike_hidden = !spike_hidden
		
		# Set sprite transparency to normal on runtime
		modulate = 'ffffff'
		
		# Re-enables collisions quickly if previously disabled
		await get_tree().create_timer(0.001).timeout
		$CollisionPolygon2D.disabled = false

		# Set a listener to the player's jump signals
		GLOBAL_INSTANCES.objPlayerID.connect("player_jumped", begin_switch)
		GLOBAL_INSTANCES.objPlayerID.connect("player_djumped", begin_switch)


func _physics_process(delta):
	if not Engine.is_editor_hint():
		
		# Position switching
		switch_positions(delta)
		
		# On screen/off screen functionality
		enable_on_screen()
	else:
		if spike_hidden:
			modulate = 'ffffff50'
		else:
			modulate = 'ffffff'



func set_angle():
	
	# Down and left are flipped
	match spike_direction:
		Dir.UP:
			rotation_degrees = 0
			scale = Vector2(1, 1)
		Dir.RIGHT:
			rotation_degrees = 90
			scale = Vector2(1, 1)
		Dir.DOWN: 
			rotation_degrees = 0
			scale = Vector2(1, -1)
		Dir.LEFT:
			rotation_degrees = 90
			scale = Vector2(1, -1)


func set_initial_positions():
	position_shown = global_position
	match spike_direction:
		Dir.UP: position_hidden = Vector2(0, 32)
		Dir.RIGHT: position_hidden = Vector2(-32, 0)
		Dir.DOWN: position_hidden = Vector2(0, -32)
		Dir.LEFT: position_hidden = Vector2(32, 0)
	position_hidden += global_position


func begin_switch():
	spike_hidden = !spike_hidden
	if !changing_positions:
		changing_positions = true


func switch_positions(delta):
	var snap_to_grid = func():
		position = position.snapped(snap_range)
		changing_positions = false
	
	if changing_positions:
		if !spike_hidden:
			if position.distance_to(position_hidden) > distance_for_snapping:
				position = position.lerp(position_hidden, delta * spike_speed)
			else:
				snap_to_grid.call()
			
		elif spike_hidden:
			if position.distance_to(position_shown) > distance_for_snapping:
				position = position.lerp(position_shown, delta * spike_speed)
			else:
				snap_to_grid.call()


# Disables visibility and collisions if offscreen, for optimization purposes
func enable_on_screen():
	if is_on_screen:
		$Sprite2D.visible = true
		$CollisionPolygon2D.disabled = false
	else:
		$Sprite2D.visible = false
		$CollisionPolygon2D.disabled = true


# Signals to enable or disable collisions and visibility
func _on_visible_on_screen_notifier_2d_screen_entered():
	is_on_screen = true
func _on_visible_on_screen_notifier_2d_screen_exited():
	is_on_screen = false
