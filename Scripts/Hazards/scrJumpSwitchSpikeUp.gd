@tool
extends AnimatableBody2D

@export var spike_hidden: bool = false

var position_shown: Vector2 = Vector2.ZERO
var position_hidden: Vector2 = Vector2.ZERO
var snap_range = Vector2(2, 2)
var spike_speed: int = 8
var distance_for_snapping: int = 1
var changing_positions: bool = false
var is_on_screen: bool = false


func _ready():
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


func _physics_process(delta):
	
	if not Engine.is_editor_hint():
		if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
			if Input.is_action_just_pressed("button_jump"):
				spike_hidden = !spike_hidden
				
				if !changing_positions:
					changing_positions = true
		
		# Position switching
		switch_positions(delta)
		
		# On screen/off screen functionality
		enable_on_screen()
	else:
		if spike_hidden:
			modulate = 'ffffff50'
		else:
			modulate = 'ffffff'


func set_initial_positions():
	position_shown = global_position
	position_hidden = global_position + Vector2(0, 32)


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


# Disables visibility and collisions if offscreen, for optimization
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
