extends CharacterBody2D

"""
---------- VARIABLE DECLARATIONS ---------- 
"""
var gravity: int = 1000
var v_speed: int = 470
var h_speed: int = 150
var max_fall_speed: int = 470
var s_jump_speed: int = 405
var d_jump_speed: int = 350
var jump_release_falloff: float = 0.45
var looking_at: int = 1
var frozen: bool = false
var d_jump: bool = true
var inside_platform_jump: bool = false
var in_water: bool = false
var is_catharsis_water: bool = false
var v_speed_modifier: float = 1.0
var can_climb: bool = false
var create_bullet := preload("res://Objects/Player/objBullet.tscn")
var jump_particle := preload("res://Objects/Player/objJumpParticle.tscn")
@onready var animated_sprite = $playerSprites
@onready var player_mask: CollisionShape2D = $playerMask
@onready var water_collider: Area2D = $extraCollisions/Water

# Signals emitted by the player's actions
signal player_died
signal player_jumped
signal player_djumped
signal player_walljumped
signal player_shot
signal player_climbing

# State machine's states
enum STATE {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	WALLJUMPING,
	CLIMBING
}

# Initial state
var current_state: STATE = STATE.IDLE



"""
---------- CREATION EVENT ----------
"""
func _ready():
	
	# If a savefile exists (we've saved at least once), we move the player to
	# the saved position, and also set its sprite and orientation
	if !GLOBAL_SAVELOAD.variableGameData.first_time_saving:
		set_position_on_load()
		animated_sprite.flip_h = GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped < 0
		looking_at = GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped
	else:
		# If we haven't saved before, it makes a special type of save which sets
		# things up for the rest of the game. 
		await Engine.get_main_loop().physics_frame
		set_first_time_saving()
	
	# Sets a very important global variable. Lets everything know that the
	# player does in fact exist and assigns it with its "id"
	GLOBAL_INSTANCES.objPlayerID = self
	
	# Turns hitbox visible if debug setting is enabled
	if GLOBAL_GAME.debug_hitbox:
		$playerMask/ColorRect.visible = GLOBAL_GAME.debug_hitbox



"""
---------- INPUT EVENTS ----------
"""
func _unhandled_input(event: InputEvent) -> void:
	
	# Disables inputs when frozen (for dialogs events/cutscenes)
	if !frozen:
		match current_state:
			
			# Changes to "running" if there's movement input, grounded
			# Changes to "jumping" if there's jumping input, grounded
			STATE.IDLE:
				if is_on_floor():
					if Input.get_axis("button_left", "button_right"):
						current_state = STATE.RUNNING
					if event.is_action_pressed("button_jump"): 
						handle_jumping()
						current_state = STATE.JUMPING
			
			
			# Changes to "idle" if there's no movement input, grounded
			# Changes to "jumping" if there's jumping input, grounded
			STATE.RUNNING:
				if is_on_floor():
					if !Input.get_axis("button_left", "button_right"):
						current_state = STATE.IDLE
					if event.is_action_pressed("button_jump"):
						handle_jumping()
						current_state = STATE.JUMPING
			
			
			# Adds downwards velocity if jumping input is released
			# Can jump again mid-air
			STATE.JUMPING:
				if event.is_action_released("button_jump") and (velocity.y < 0):
					if velocity.y < 0:
						velocity.y *= jump_release_falloff
				if event.is_action_pressed("button_jump"):
					handle_jumping()
			
			
			# Changes to "jumping" if there's jumping input, on air only
			# Needs d_jump to jump again in the air before setting the "jumping" state
			STATE.FALLING:
				if !is_on_floor():
					if event.is_action_pressed("button_jump"):
						
						# Lots of conditions
						if d_jump or inside_platform_jump or (in_water and !is_catharsis_water) or GLOBAL_GAME.debug_inf_jump:
							handle_jumping()
							current_state = STATE.JUMPING
			
			
			# Changes to "jumping" if there's both jumping and movement input
			# Changes to "falling" if there's movement input opposite to the walljump
			STATE.WALLJUMPING:
				var jump_direction = get_wall_normal()
				var walljumping_action = func():
					velocity.x = jump_direction.x * h_speed
					velocity.y = -s_jump_speed
					GLOBAL_SOUNDS.play_sound("sndJump")
					
					# Emit the "player_walljumped" signal
					player_walljumped.emit()
				
				# Walljumping should only happen if we hold the jump button first
				if Input.is_action_pressed("button_jump"):
				
					# Walljump to the right
					if (Input.get_axis("button_left", "button_right") > 0) and (jump_direction == Vector2.RIGHT):
						walljumping_action.call()
						current_state = STATE.JUMPING
					
					# Walljump to the left
					if (Input.get_axis("button_left", "button_right") < 0) and (jump_direction == Vector2.LEFT):
						walljumping_action.call()
						current_state = STATE.JUMPING
				else:
					# Not holding the jump button, but pressing left or right on the 
					# opposite direction to the vine leaves it and stops the
					# walljumping state.
					# Drop right walljump
					if (Input.get_axis("button_left", "button_right") < 0) and (jump_direction == Vector2.LEFT):
						velocity.y = 0
						current_state = STATE.FALLING
						
					# Drop left walljump
					if (Input.get_axis("button_left", "button_right") > 0) and (jump_direction == Vector2.RIGHT):
						velocity.y = 0
						current_state = STATE.FALLING
			
			
			# Changes to "falling" if there's jumping input
			STATE.CLIMBING:
				if event.is_action_pressed("button_jump"):
					current_state = STATE.FALLING
		
		
		# Extra input actions
		# Shooting
		if event.is_action_pressed("button_shoot"):
			handle_shooting()



"""
---------- DEBUG KEY INPUTS ----------
"""
# Handles all debug key toggles. Keys are hardcoded.
func _unhandled_key_input(event: InputEvent):
	
	# Debug keys are activated only in debug mode
	if GLOBAL_GAME.debug_mode:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			
			# Toggle godmode
			if event.keycode == KEY_1:
				GLOBAL_GAME.debug_godmode = !GLOBAL_GAME.debug_godmode
				
				# Sound for godmode
				if GLOBAL_GAME.debug_godmode:
					GLOBAL_SOUNDS.play_sound("sndBlockChange")
			
			# Toggle infjump
			if event.keycode == KEY_2:
				GLOBAL_GAME.debug_inf_jump = !GLOBAL_GAME.debug_inf_jump
				
				# Sound for infinite jump
				if GLOBAL_GAME.debug_inf_jump:
					GLOBAL_SOUNDS.play_sound("sndBouncyBlock")
			
			# Toggle hitbox view
			if event.keycode == KEY_3:
				GLOBAL_GAME.debug_hitbox = !GLOBAL_GAME.debug_hitbox
				$playerMask/ColorRect.visible = GLOBAL_GAME.debug_hitbox
				
				# Sound for debug hitbox
				if GLOBAL_GAME.debug_hitbox:
					GLOBAL_SOUNDS.play_sound("sndFadingBlock")
			
			# Debug save
			if event.keycode == KEY_4:
				GLOBAL_SAVELOAD.save_game(true)
				GLOBAL_SOUNDS.play_sound("sndSave")
			
			# Add or reduce 1px to the player's horizontal position
			if event.keycode == KEY_5:
				position.x -= 1
			if event.keycode == KEY_6:
				position.x += 1



"""
---------- MAIN LOGIC LOOP ----------
"""
func _physics_process(delta):
	
	# Method for handling all movement and collisions. Should be called before
	# any kind of collision check
	move_and_slide()
	
	# State machine
	match current_state:
		
		# Grounded
		# Gives d_jump
		# No horizontal velocity
		# Can fall
		# Affected by gravity
		STATE.IDLE:
			animated_sprite.play("idle")
			velocity.x = 0
			d_jump = true
			if !is_on_floor():
				current_state = STATE.FALLING
			add_gravity(delta)
	
	
		# Grounded
		# Gives d_jump
		# Has horizontal velocity
		# Can fall
		# Affected by gravity
		STATE.RUNNING:
			animated_sprite.play("running")
			d_jump = true
			handle_horizontal_movement()
			if !is_on_floor():
				current_state = STATE.FALLING
			add_gravity(delta)
	
	
		# Either grounded or on air
		# Can have horizontal velocity (when not frozen). Stops otherwise
		# Changes to "falling" state when vertical velocity is positive
		# Changes to "idle" or "running" state when on floor. For platform snap
		# Affected by gravity
		STATE.JUMPING:
			animated_sprite.play("jump")
			if !frozen:
				handle_horizontal_movement()
			else:
				velocity.y = 0
			if velocity.y > 0:
				current_state = STATE.FALLING
			if is_on_floor():
				if velocity.x == 0:
					current_state = STATE.IDLE
				else:
					current_state = STATE.RUNNING
			add_gravity(delta)
	
	
		# On air only
		# Can have horizontal velocity (when not frozen)
		# Changes to "idle" or "running" state when on floor
		# Affected by gravity
		STATE.FALLING:
			animated_sprite.play("fall")
			if !frozen:
				handle_horizontal_movement()
			if is_on_floor():
				if velocity.x == 0:
					current_state = STATE.IDLE
				else:
					current_state = STATE.RUNNING
			add_gravity(delta)
	
	
		# Standalone state, called from colliding with a walljump surface
		# Does not take any user input to change velocity
		# Falls slowly at a constant velocity
		# Not affected by gravity
		STATE.WALLJUMPING:
			animated_sprite.play("slidding")
			velocity.y = 90
			if is_on_floor():
				current_state = STATE.IDLE
		
		
		# Standalone state, called from colliding with a climbable surface and pressing "button_up" / "button_down"
		# Either grounded or on air
		# Not affected by gravity
		# Takes directional inputs, allowing for movement in 8 directions
		# Orients masks and bullet direction on horizontal movement
		# Stops animation when there's no movement/velocity
		# Changes state to "falling" when no longer colliding with a climbable surface
		STATE.CLIMBING:
			animated_sprite.play("climbing")
			
			var direction_x = Input.get_axis("button_left", "button_right")
			var direction_y = Input.get_axis("button_up", "button_down")
			velocity.x = sign(direction_x) * h_speed
			velocity.y = sign(direction_y) * h_speed
			
			if velocity.x != 0:
				animated_sprite.set_flip_h(velocity.x < 0)
				orient_player()
				
			if velocity == Vector2.ZERO:
				animated_sprite.pause()
				
			if !can_climb:
				current_state = STATE.FALLING
	
	
	# If frozen and on air, sets state to "falling". If grounded, sets it to "idle"
	if frozen:
		if !is_on_floor():
			current_state = STATE.FALLING
		else:
			current_state = STATE.IDLE
	
	# Water checks for constant collisions. We only do when we're actually
	# inside of water. We also change the falling speed
	if in_water:
		v_speed_modifier = 0.32
		handle_water()
	else:
		v_speed_modifier = 1
	
	# If we are colliding with a climbable surface and we press "button_up" or
	# "button_down", we stop our vertical velocity and enter the climbing state
	# if we weren't there before
	if (Input.is_action_pressed("button_up") or Input.is_action_pressed("button_down")) and can_climb:
		if current_state != STATE.CLIMBING:
			velocity.y = 0
			current_state = STATE.CLIMBING
			
			# Emit the "player_jumped" signal
			player_climbing.emit()
	
	# Teleports the player to the mouse position when "button_debug_teleport"
	# is pressed (only on debug mode)
	debug_mouse_teleport()



"""
---------- CUSTOM METHODS ----------
"""
# Handles horizontal movement, also orienting and flipping the player sprite
func handle_horizontal_movement():
	
	# Get the input direction and handle the movement
	var main_direction: float = Input.get_axis("button_left", "button_right")
	
	# Adds horizontal velocity. Also handles controller stick deadzone (values
	# go from -1.0 to 1.0)
	velocity.x = sign(main_direction) * h_speed
	
	# Player needs to be moving in order to flip things around
	if velocity.x != 0:
		animated_sprite.set_flip_h(velocity.x < 0)
		
		# Orients masks and bullets
		orient_player()


# Orient masks and bullets
func orient_player() -> void:
	var orient_masks = func(orientation: int):
		$playerMask.position.x = orientation
		$extraCollisions.scale.x = orientation
		looking_at = orientation
	
	if velocity.x > 0:
		orient_masks.call(1)
	else:
		orient_masks.call(-1)


# Handles gravity / falling
func add_gravity(delta) -> void:
	
	# Adds the gravity when you're grounded or not on a platform
	if (is_on_floor() == false):
		velocity.y += gravity * delta
		
		# Clamps the falling value to max_fall_speed, which is also modified by 
		# water physics. Check _handle_water().
		velocity.y = min(v_speed * v_speed_modifier, velocity.y)


# Jumping logic
func handle_jumping() -> void:
	
	# Check if player is on floor (or inside a platform) to single jump
	if is_on_floor() or inside_platform_jump:
		velocity.y = -s_jump_speed
		GLOBAL_SOUNDS.play_sound("sndJump")
		
		# Emit the "player_jumped" signal
		player_jumped.emit()
	else:
		
		# If not grounded and either d_jump, non-catharsis water or infinite
		# jumping is enabled, we make a double jump
		if (d_jump) or (in_water and !is_catharsis_water) or (GLOBAL_GAME.debug_inf_jump):
			velocity.y = -d_jump_speed
			d_jump = false
			GLOBAL_SOUNDS.play_sound("sndDJump")
			
			# Emit the "player_djumped" signal
			player_djumped.emit()
			
			# Jump particles on djump, as long as the player is not in water
			if (in_water == false):
				var jump_particle_id = jump_particle.instantiate()
				get_parent().add_child(jump_particle_id)
				jump_particle_id.global_position = Vector2(global_position.x, global_position.y + 12)


# Classic fangame bullet attack
func handle_shooting() -> void:
	
	# An equivalent to gamemaker's "instance_number() < 4"
	# It checks how many nodes belonging to the "Bullet" group
	# exist in the current scene
	if get_tree().get_nodes_in_group("Bullet").size() < 4:
		
		# Loads the bullet scene, instances it, assigns the shooting direction
		# and global position, makes a sound and then adds it to the main scene 
		# (the actual game)
		var create_bullet_id: AnimatableBody2D = create_bullet.instantiate()
		create_bullet_id.looking_at = looking_at
		
		# Bullet's x coordinate:
		#	-Takes into account the global x
		#	-The bullet spacing, relative to where we are looking at 
		create_bullet_id.global_position = Vector2(global_position.x, global_position.y + 5)
		GLOBAL_SOUNDS.play_sound("sndShoot")
		
		# After everything is set and done, creates the bullet
		get_parent().add_child(create_bullet_id)
		
		# Emit the "player_shot" signal
		player_shot.emit()


# Interaction with water
func handle_water() -> void:
	
	# Gets the water type from objWater, setting its interaction
	var obj_water = water_collider.get_overlapping_areas()
	for obj_water_type in obj_water:
		match obj_water_type.get_parent().water_type:
			1:
				is_catharsis_water = false
			2:
				is_catharsis_water = false
				d_jump = true
			3:
				is_catharsis_water = true


# Teleports the player to the mouse position when "button_debug_teleport"
# is pressed (only on debug mode)
func debug_mouse_teleport() -> void:
	if GLOBAL_GAME.debug_mode:
		if Input.is_action_pressed("button_debug_teleport"):
			position = get_global_mouse_position()
			velocity.y = 0


# Everything that should happen when the player dies
func on_death():
	
	# Death should only happen if we're out of godmode
	if !GLOBAL_GAME.debug_godmode:
		
		# We load a particle emitter, which does the visual stuff we want
		var blood_emitter = load("res://Objects/Player/objBloodEmitter.tscn")
		var blood_emitter_id = blood_emitter.instantiate()
		blood_emitter_id.position = Vector2(position.x, position.y)
		blood_emitter_id.side = looking_at
		
		# We add a sibling node to the player, not a child node, since the
		# player object gets freed!
		add_sibling(blood_emitter_id)
		GLOBAL_SOUNDS.play_sound("sndDeath")
		
		# Adds an extra death to the global death counter
		GLOBAL_GAME.deaths += 1
		
		# Emit "player_died"
		player_died.emit()
		
		# Destroys the player
		queue_free()


# Moves the player if we're not warping from another room (to spawn at the
# correct initial position).
# If it is our first time saving, it calls a function to make a special type
# of save, preparing data for future use
func set_position_on_load():
		
	# If we're warping from another room, then we don't want this object
	# to read and teleport to our last saved position. However, as soon
	# as we load the room and finish teleporting, we want to be able to
	# read those positions again.
	if (GLOBAL_GAME.is_changing_rooms == false):
		position.x = GLOBAL_SAVELOAD.variableGameData.player_x
		position.y = GLOBAL_SAVELOAD.variableGameData.player_y
	else:
		
		# If the warp we teleported from changed warp_to_point, we teleport
		# to those coordinates and then set them to 0,0 again
		if GLOBAL_GAME.warp_to_point != Vector2.ZERO:
			position = GLOBAL_GAME.warp_to_point
		
		GLOBAL_GAME.warp_to_point = Vector2.ZERO
		GLOBAL_GAME.is_changing_rooms = false


# We make a save with this player's current coordinates, sprite state, and room
# name (without taking a screenshot).
# This is done to prevent a common issue that happens when restarting with a 
# clean save (otherwise it would teleport the player to 0,0 and to an undefined
# room).
func set_first_time_saving():
	
	GLOBAL_SAVELOAD.variableGameData.player_x = position.x
	GLOBAL_SAVELOAD.variableGameData.player_y = position.y
	GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped = looking_at
	GLOBAL_SAVELOAD.variableGameData.room_name = get_tree().get_current_scene().get_scene_file_path()
	GLOBAL_SAVELOAD.variableGameData.first_time_saving = false
	GLOBAL_SAVELOAD.take_screenshot()
	
	# After changing the variable game data to the proper values, we save them.
	GLOBAL_SAVELOAD.save_data()
	
	# Then, after saving for the fist time in-game, a reload is needed.
	# What this does is replacing the old default values with the new ones
	# we just saved, reading them once through loading.
	GLOBAL_SAVELOAD.load_data()



"""
---------- EXTRA COLLISIONS ----------
"""
# Killers
# Calls "on_death"
func _on_killers_body_entered(_body: Node2D) -> void:
	on_death()


# Walljumps
# Indicates whether the player is touching a walljump surface
func _on_walljumps_body_entered(_body: Node2D) -> void:
	if !is_on_floor():
		current_state = STATE.WALLJUMPING
func _on_walljumps_body_exited(_body: Node2D) -> void:
	if current_state != STATE.JUMPING:
		current_state = STATE.FALLING


# Water
# Indicates whether the player is inside of water
func _on_water_area_entered(_area: Area2D) -> void:
	in_water = true

# Checks if we're no longer touching water after leaving another body of
# water, only then setting in_water to false
func _on_water_area_exited(_area: Area2D) -> void:
	if !$extraCollisions/Water.has_overlapping_areas():
		in_water = false
		is_catharsis_water = false


# IsCrushed
# Checks if the player is inside of walls, calling "on_death" if true.
# It has a smaller collision shape
func _on_is_crushed_body_entered(_body: Node2D) -> void:
	on_death()


# SheepBlocks
# Activates sheep blocks from the player
func _on_sheep_blocks_body_entered(body: Node2D) -> void:
	if !body.activated:
		GLOBAL_SOUNDS.play_sound("sndSheepBlock")
		body.animation_player.play("animSheepBlock")
		body.activated = true


# Platforms
# Gives infinite djump while touching them
func _on_platforms_body_entered(_body: Node2D) -> void:
	inside_platform_jump = true

# Checks if we're no longer touching a platform after leaving another 
# platform, only then setting inside_platform_jump to false
func _on_platforms_body_exited(_body: Node2D) -> void:
	if !$extraCollisions/Platforms.has_overlapping_bodies():
		inside_platform_jump = false


# PlatformSnap
# Allows "magnetic snapping" for platforms
func _on_platform_snap_body_exited(body: Node2D) -> void:
	
	# If platforms have a "snap" property, and it's enabled
	if "snap" in body:
		if body.snap:
			
			# Will only snap while jumping. Stops velocity, sets position and
			# snaps to the colliding platform
			if current_state == STATE.JUMPING:
				velocity.y = 0
				
				# Regular moving platforms will use move_speed, so we have a
				# special case for them. Other types of platforms won't use
				# move_speed.y directly, so we don't need to calculate it in
				# order to snap the player to them
				if body.move_speed != Vector2.ZERO:
					global_position.y = body.global_position.y - 16 - abs(body.move_speed.y)
				else:
					global_position.y = body.global_position.y - 16
				
				# This function "tests" if the player is above and close to the
				# floor, including platforms, and if true, teleports and
				# instantly grounds him
				apply_floor_snap()


# ClimbSurface
# Detects a climbable surface, allowing climbing when "button_up" / "button_down" is pressed
func _on_climb_surface_body_entered(_body: Node2D) -> void:
	can_climb = true
func _on_climb_surface_body_exited(_body: Node2D) -> void:
	can_climb = false
