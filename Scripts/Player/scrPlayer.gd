extends CharacterBody2D

"""----------------------------------------
---------- VARIABLE DECLARATIONS ---------- 
----------------------------------------"""
var gravity: int = 1000
var v_speed: int = 470
var h_speed: int = 150
var main_velocity: Vector2 = Vector2.ZERO
var max_fall_speed: int = 470
var s_jump_speed: int = 405
var d_jump_speed: int = 350
var jump_release_falloff: float = 0.45
var horizontal_movement_direction: float = 0
var vertical_movement_direction: float = 0
var is_player_alive: bool = true
var looking_at: int = 1
var frozen: bool = false
var d_jump: bool = true
var inside_platform_jump: bool = false
var can_walljump: bool = false
var in_water: bool = false
var is_catharsis_water: bool = false
var v_speed_modifier: float = 1.0
var can_climb: bool = false
var is_ice_physics: bool = false
var on_ice_velocity: float = 0.0
var is_pushing_physics_object: bool = false
var is_on_wind: bool = false
var wind_velocity: Vector2 = Vector2.ZERO
var stored_wind_velocity: Vector2 = Vector2.ZERO
var sprite_offset: float = -1.1
var create_bullet := preload("res://Objects/Player/objBullet.tscn")
var jump_particle := preload("res://Objects/Player/objJumpParticle.tscn")
@onready var animated_sprite = $playerSpriteOrigin/playerSprites
@onready var player_mask: CollisionShape2D = $playerMask
@onready var water_collider: Area2D = $extraCollisions/Water
@onready var sprite_origin = $playerSpriteOrigin

# State machine's states
enum STATE {
	ON_CREATION,
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	WALLJUMPING,
	CLIMBING
}

# Initial state
var current_state: STATE = STATE.ON_CREATION

# Horizontal movement input behaviour
# RIGHT_TAKES_PRIORITY: same as every classic fangame engine
# FIRST_DIRECTION_KEEPS_PRIORITY: player keeps moving towards its initial direction
# LAST_DIRECTION_TAKES_PRIORITY: last key press replaces the player direction
# STOP_ON_BOTH: pressing both keys stops movement entirely
enum MOVEMENT_TYPE {
	RIGHT_TAKES_PRIORITY,
	FIRST_DIRECTION_KEEPS_PRIORITY,
	LAST_DIRECTION_TAKES_PRIORITY,
	STOP_ON_BOTH
}

# Changes how the player should move when pressing both left and right
var current_movement_type: MOVEMENT_TYPE = MOVEMENT_TYPE.RIGHT_TAKES_PRIORITY



"""---------------------------------
---------- CREATION EVENT ----------
---------------------------------"""
func _ready():
	
	# If a savefile exists (we've saved at least once), we move the player to
	# the saved position, and also orient its sprite and masks
	if !GLOBAL_SAVELOAD.variableGameData.first_time_saving:
		set_position_on_load()
		orient_player(GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped)
		animated_sprite.offset.x = sprite_offset
	else:
		# If we haven't saved before, it makes a special type of save which sets
		# things up for the rest of the game. 
		await Engine.get_main_loop().physics_frame
		set_first_time_saving()
	
	# Sets a very important global variable. Lets everything know that the
	# player does in fact exist and assigns it with its "id"
	GLOBAL_INSTANCES.objPlayerID = self
	
	# Set sprite on the first frame by reading the savefile.
	# If jumping or climbing, we set the sprite to "fall" since we'll be 
	# instantly falling on reset.
	# If running or idle, check if there's directional input to set the proper
	# sprite
	# For any other case, read the savefile and set the sprite directly
	var set_sprite_on_horizotal_input = func():
		if Input.get_axis("button_left", "button_right"):
			animated_sprite.animation = "running"
		else:
			animated_sprite.animation = "idle"
	
	# Match the sprite by name
	match GLOBAL_SAVELOAD.variableGameData.player_initial_sprite:
		"jump":
			animated_sprite.animation = "fall"
		"climbing":
			animated_sprite.animation = "fall"
		"running":
			set_sprite_on_horizotal_input.call()
		"idle":
			set_sprite_on_horizotal_input.call()
		_:
			animated_sprite.animation = GLOBAL_SAVELOAD.variableGameData.player_initial_sprite
	
	# Turns hitbox visible if debug setting is enabled
	if GLOBAL_GAME.debug_hitbox:
		$playerSpriteOrigin/ColorRect.visible = GLOBAL_GAME.debug_hitbox
	
	# Signal connections
	GLOBAL_SIGNALS.player_jumped.connect(wind_reset.bind())
	GLOBAL_SIGNALS.player_djumped.connect(wind_reset.bind())




"""-------------------------------
---------- INPUT EVENTS ----------
-------------------------------"""
func _unhandled_input(event: InputEvent) -> void:
	
	# Disables inputs when frozen (for dialogs events/cutscenes)
	if !frozen:
		match current_state:
			
			# Changes to "running" if there's movement input, grounded
			# Changes to "jumping" if there's jumping input, grounded
			STATE.IDLE:
				if is_on_floor():
					if handle_horizontal_input() != 0:
						current_state = STATE.RUNNING
					if event.is_action_pressed("button_jump"): 
						d_jump = true
						handle_jumping()
						current_state = STATE.JUMPING
			
			
			# Changes to "idle" if there's no movement input, grounded
			# Changes to "jumping" if there's jumping input, grounded
			STATE.RUNNING:
				if is_on_floor():
					if handle_horizontal_input() == 0:
						current_state = STATE.IDLE
					if event.is_action_pressed("button_jump"):
						d_jump = true
						handle_jumping()
						current_state = STATE.JUMPING
			
			
			# Adds downwards velocity if jumping input is released
			# Can jump again mid-air
			STATE.JUMPING:
				if event.is_action_released("button_jump") and (main_velocity.y < 0):
					if main_velocity.y < 0:
						main_velocity.y *= jump_release_falloff
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
					main_velocity.x = jump_direction.x * h_speed
					main_velocity.y = -s_jump_speed
					can_walljump = false
					GLOBAL_SOUNDS.play_sound("sndJump")
					
					# Emit the "player_walljumped" signal
					GLOBAL_SIGNALS.player_walljumped.emit()
				
				# Walljumping should only happen if we hold the jump button first
				if Input.is_action_pressed("button_jump"):
				
					# Walljump to the right
					if Input.is_action_just_pressed("button_right") and jump_direction == Vector2.RIGHT:
						horizontal_movement_direction = 1.0
						walljumping_action.call()
						current_state = STATE.JUMPING
					
					# Walljump to the left
					if Input.is_action_just_pressed("button_left") and (jump_direction == Vector2.LEFT):
						horizontal_movement_direction = -1.0
						walljumping_action.call()
						current_state = STATE.JUMPING
				else:
					# While not holding the jump button, pressing left or right on
					# the opposite direction to the vine leaves it and stops the
					# walljumping state.
					var drop_walljump = func():
						main_velocity.y = 0
						can_walljump = false
						current_state = STATE.FALLING
					
					# Drop right walljump
					if (Input.get_axis("button_left", "button_right") < 0) and (jump_direction == Vector2.LEFT):
						drop_walljump.call()
						
					# Drop left walljump
					if (Input.get_axis("button_left", "button_right") > 0) and (jump_direction == Vector2.RIGHT):
						drop_walljump.call()
			
			
			# Changes to "falling" if there's jumping input
			STATE.CLIMBING:
				if event.is_action_pressed("button_jump"):
					current_state = STATE.FALLING
		
		
		# Extra input actions
		# Shooting
		if event.is_action_pressed("button_shoot"):
			if current_state != STATE.WALLJUMPING:
				handle_shooting()




"""-----------------------------------
---------- DEBUG KEY INPUTS ----------
-----------------------------------"""
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
				$playerSpriteOrigin/ColorRect.visible = GLOBAL_GAME.debug_hitbox
				
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




"""----------------------------------
---------- MAIN LOGIC LOOP ----------
----------------------------------"""
func _physics_process(delta):
	
	# Method for handling velocity calculations. Should be called before
	# move_and_slide()
	set_velocities()
	
	# Method for handling all movement and collisions. Should be called before
	# any kind of collision check
	move_and_slide()
	
	# Resets vertical speed from main_velocity manually, by checking if the
	# player is on the ground or touching the ceiling.
	# Should be called AFTER move_and_slide()
	reset_velocities()
	
	# Handles sprite, bullet and mask directions via input
	if handle_horizontal_input() != 0:
		orient_player(handle_horizontal_input())
		animated_sprite.offset.x = sprite_offset
	
	# State machine
	match current_state:
		
		# Fixes on creation sprite visuals by having a transitional state
		# Only active for a single physics frame
		# If grounded, checks horizontal velocity to set the proper state
		# If on air, changes to "falling"
		STATE.ON_CREATION:
			if is_on_floor():
				if handle_horizontal_input() != 0:
					current_state = STATE.RUNNING
				else:
					current_state = STATE.IDLE
			else:
				current_state = STATE.FALLING
		
		
		# Grounded
		# Gives d_jump
		# No horizontal velocity
		# Checks for 0 horizontal velocity (for ice physics)
		# Can fall
		# Affected by gravity
		STATE.IDLE:
			animated_sprite.play("idle")
			d_jump = true
			if !frozen:
				handle_horizontal_movement()
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
			if !frozen:
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
				main_velocity.y = 0
			if main_velocity.y > 0:
				current_state = STATE.FALLING
			if is_on_floor():
				if main_velocity.x == 0:
					current_state = STATE.IDLE
				else:
					current_state = STATE.RUNNING
			add_gravity(delta)
	
	
		# On air only
		# Can have horizontal velocity (when not frozen)
		# Changes to "idle" or "running" state when on floor
		# If there is horizontal velocity, accounts for ice physics for state transitions
		# Affected by gravity
		STATE.FALLING:
			animated_sprite.play("fall")
			if !frozen:
				handle_horizontal_movement()
			if is_on_floor():
				if main_velocity.x == 0:
					current_state = STATE.IDLE
				else:
					if !is_ice_physics:
						current_state = STATE.RUNNING
					else:
						current_state = STATE.IDLE
			if can_walljump:
				current_state = STATE.WALLJUMPING
			add_gravity(delta)
	
	
		# Standalone state, called from colliding with a walljump surface
		# Does not take any user input to change velocity
		# Falls slowly at a constant velocity
		# Not affected by gravity
		STATE.WALLJUMPING:
			animated_sprite.play("slidding")
			main_velocity.y = 90
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
			
			main_velocity.x = handle_horizontal_input() * h_speed
			main_velocity.y = handle_vertical_input() * h_speed
			
			if main_velocity == Vector2.ZERO:
				animated_sprite.pause()
			
			if !can_climb:
				current_state = STATE.FALLING
	
	
	
	# If we are colliding with a climbable surface and we press "button_up" or
	# "button_down", we stop our vertical velocity and enter the climbing state
	# if we weren't there before
	if can_climb and (Input.is_action_pressed("button_up") or Input.is_action_pressed("button_down")):
		if current_state != STATE.CLIMBING:
			main_velocity.y = 0
			current_state = STATE.CLIMBING
			
			# Emit the "player_climbed" signal
			GLOBAL_SIGNALS.player_climbed.emit()
	
	
	# If frozen and on air, sets state to "falling". If grounded, sets it to "idle"
	if frozen:
		if !is_on_floor():
			current_state = STATE.FALLING
		else:
			current_state = STATE.IDLE
	
	
	# Water checks for constant collisions. We only do when we're actually
	# inside of water. We also change the falling speed
	if in_water:
		v_speed_modifier = 0.22
		handle_water()
	else:
		v_speed_modifier = 1
	
	
	# If ice physics are enabled, we get constant collisions from the IceBlocks
	# node. If it returns an empty array while the player is floored, disables
	# them. When disabled, on_ice_velocity is reset
	if is_ice_physics:
		var overlapping_bodies = $extraCollisions/IceBlocks.get_overlapping_bodies()
		if overlapping_bodies == [] and is_on_floor():
			is_ice_physics = false
	else:
		on_ice_velocity = 0.0
	
	
	# If we're close to a physics block, enables constant collisions and
	# applies central impulse 
	if is_pushing_physics_object:
		var PUSH_FORCE = 15.0
		var MIN_PUSH_FORCE = 10.0
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() is RigidBody2D:
				var physics_block = collision.get_collider() as RigidBody2D
				var push_force = (PUSH_FORCE * velocity.length() / h_speed) + MIN_PUSH_FORCE
				physics_block.apply_central_impulse(-collision.get_normal() * push_force)
	
	
	# Wind physics. When on a wind field, checks if there's stored wind
	# velocity. If so, accelerates towards it.
	# While climbing, wind speed is applied directly without acceleration.
	# If wind physics are no longer active, sets stored wind velocity to 0 and
	# decelerates towards it, but only while on air. When grounded, sets wind
	# velocity to 0
	var wind_easing = 0.05
	if is_on_wind:
		if stored_wind_velocity != Vector2.ZERO:
			if current_state != STATE.CLIMBING:
				wind_velocity = wind_velocity.lerp(stored_wind_velocity, wind_easing)
			else:
				wind_velocity = stored_wind_velocity
	else:
		stored_wind_velocity = Vector2.ZERO
		if !is_on_floor() and current_state != STATE.CLIMBING:
			wind_velocity = wind_velocity.lerp(Vector2.ZERO, wind_easing)
		else:
			wind_velocity = Vector2.ZERO
	
	
	# Teleports the player to the mouse position when "button_debug_teleport"
	# is pressed (only on debug mode)
	debug_mouse_teleport()




"""---------------------------------
---------- CUSTOM METHODS ----------
---------------------------------"""
# Sets velocity by adding every velocity vector variable
func set_velocities() -> void:
	velocity = main_velocity + wind_velocity


# Resets vertical main_velocity manually when touching the floor or ceiling, 
# since we don't use velocity directly
func reset_velocities() -> void:
	if is_on_floor() or is_on_ceiling():
		main_velocity.y = 0


# Sets input direction for handling horizontal movement
func handle_horizontal_input():
	match current_movement_type:
		
		# Right direction always takes priority. Resembles classic fangame engines
		MOVEMENT_TYPE.RIGHT_TAKES_PRIORITY:
			if Input.is_action_pressed("button_right"):
				horizontal_movement_direction = 1.0
			elif Input.is_action_pressed("button_left"):
				horizontal_movement_direction = -1.0
			else:
				horizontal_movement_direction = 0.0
		
		
		# If pressing "button_left" or "button_right", gets horizontal input and sets
		# horizontal_movement_direction.
		# Keeps horizontal_movement_direction even when pressing both directional
		# keys. It can only reset if we stop pressing them both
		MOVEMENT_TYPE.FIRST_DIRECTION_KEEPS_PRIORITY:
			if Input.get_axis("button_left", "button_right") != 0:
				horizontal_movement_direction = Input.get_axis("button_left", "button_right")
			else:
				if not Input.is_action_pressed("button_left") and not Input.is_action_pressed("button_right"):
					horizontal_movement_direction = 0
		
		
		# When pressing both directional keys at the same time, the last key
		# pressed will take priority, changing to its direction
		MOVEMENT_TYPE.LAST_DIRECTION_TAKES_PRIORITY:
			if Input.is_action_pressed("button_right") and not Input.is_action_pressed("button_left"):
				horizontal_movement_direction = 1.0
			elif Input.is_action_just_pressed("button_left"):
					horizontal_movement_direction = -1.0
			
			if Input.is_action_pressed("button_left") and not Input.is_action_pressed("button_right"):
				horizontal_movement_direction = -1.0
			elif Input.is_action_just_pressed("button_right"):
					horizontal_movement_direction = 1.0
			
			if not Input.is_action_pressed("button_left") and not Input.is_action_pressed("button_right"):
				horizontal_movement_direction = 0.0
		
		
		# Stops movement when both left and right keys are pressed
		MOVEMENT_TYPE.STOP_ON_BOTH:
			horizontal_movement_direction = Input.get_axis("button_left", "button_right")
	
	return sign(horizontal_movement_direction)


# Sets input direction for handling vertical movement
func handle_vertical_input():
	
	# If pressing "button_up" or "button_down", gets vertical input and sets
	# vertical_movement_direction.
	# Keeps vertical_movement_direction even when pressing both directional
	# keys. It can only reset if we stop pressing them both
	if Input.get_axis("button_up", "button_down") != 0:
		vertical_movement_direction = Input.get_axis("button_up", "button_down")
	else:
		if not Input.is_action_pressed("button_up") and not Input.is_action_pressed("button_down"):
			vertical_movement_direction = 0
	
	return sign(vertical_movement_direction)


# Handles horizontal movement
func handle_horizontal_movement():
	
	# The amount of "floor friction" for ice physics
	var ice_speed: float = 10
	
	# Regular and ice physics horizontal velocity
	if !is_ice_physics:
		
		# Adds horizontal velocity. Also handles controller stick deadzone (values
		# go from -1.0 to 1.0)
		main_velocity.x = handle_horizontal_input() * h_speed
	else:
		
		# Adds horizontal velocity with acceleration/deceleration
		if handle_horizontal_input() != 0:
			main_velocity.x = move_toward(main_velocity.x, handle_horizontal_input() * h_speed, ice_speed)
			on_ice_velocity = main_velocity.x
		else:
			main_velocity.x = move_toward(on_ice_velocity, 0, ice_speed / 3)
			on_ice_velocity = main_velocity.x


# Orient sprite origin, masks and bullets
func orient_player(direction) -> void:
	sprite_origin.scale.x = direction
	$extraCollisions.scale.x = direction
	looking_at = direction


# Handles gravity / falling
func add_gravity(delta) -> void:
	
	# Adds the gravity when you're grounded or not on a platform
	if (is_on_floor() == false):
		main_velocity.y += gravity * delta
		
		# Clamps the falling value to max_fall_speed, which is also modified by 
		# water physics. Check _handle_water().
		main_velocity.y = min(v_speed * v_speed_modifier, main_velocity.y)


# Jumping logic
func handle_jumping() -> void:
	
	# Check if player is on floor (or inside a platform) to single jump
	if is_on_floor() or inside_platform_jump:
		main_velocity.y = -s_jump_speed
		GLOBAL_SOUNDS.play_sound("sndJump")
		
		# Sets d_jump when jumping while inside of a platform
		if inside_platform_jump:
			d_jump = true
		
		# Emit the "player_jumped" signal
		GLOBAL_SIGNALS.player_jumped.emit()
	else:
		
		# If not grounded and either d_jump, non-catharsis water or infinite
		# jumping is enabled, we make a double jump
		if (d_jump) or (in_water and !is_catharsis_water) or (GLOBAL_GAME.debug_inf_jump):
			main_velocity.y = -d_jump_speed
			d_jump = false
			GLOBAL_SOUNDS.play_sound("sndDJump")
			
			# Emit the "player_djumped" signal
			GLOBAL_SIGNALS.player_djumped.emit()
			
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
		GLOBAL_SIGNALS.player_shot.emit()


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


# Resets wind physics values on jump/djump
# Called from signals, keeping logic outside of the jump method
func wind_reset() -> void:
	wind_velocity = Vector2.ZERO
	stored_wind_velocity = Vector2.ZERO


# Teleports the player to the mouse position when "button_debug_teleport"
# is pressed (only on debug mode)
func debug_mouse_teleport() -> void:
	if GLOBAL_GAME.debug_mode:
		if Input.is_action_pressed("button_debug_teleport"):
			position = get_global_mouse_position()
			main_velocity.y = 0


# Everything that should happen when the player dies
func on_death():
	
	# Death should only happen if we're out of godmode and the player is alive
	if !GLOBAL_GAME.debug_godmode and is_player_alive:
		
		# We load a particle emitter, which does the visual stuff we want
		var blood_emitter = load("res://Objects/Player/objBloodEmitter.tscn")
		var blood_emitter_id = blood_emitter.instantiate()
		blood_emitter_id.position = Vector2(position.x, position.y)
		blood_emitter_id.side = looking_at
		
		# We add a sibling node to the player, not a child node, since the
		# player object gets freed!
		add_sibling(blood_emitter_id)
		
		# Adds screen shaking. Feel free to comment the following lines if you
		# don't like the effect
		var screen_shake = load("res://Objects/System/objScreenShake.tscn")
		var screen_shake_id = screen_shake.instantiate()
		add_sibling(screen_shake_id)
		
		# Plays gameover music
		GLOBAL_GAME.play_gameover_music()
		
		# Adds an extra death to the global death counter
		GLOBAL_GAME.deaths += 1
		
		# Emit "player_died"
		GLOBAL_SIGNALS.player_died.emit()
		
		# Sets is_player_alive to false, preventing multiple deaths when
		# colliding with several Killer objects on the same frame
		is_player_alive = false
		
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
	GLOBAL_SAVELOAD.variableGameData.player_initial_sprite = animated_sprite.get_animation()
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




"""-----------------------------------
---------- EXTRA COLLISIONS ----------
-----------------------------------"""
# Killers
# Calls "on_death"
func _on_killers_body_entered(_body: Node2D) -> void:
	on_death()


# Walljumps
# Indicates whether the player is touching a walljump surface
func _on_walljumps_body_entered(_body: Node2D) -> void:
	can_walljump = true
	if !is_on_floor():
		current_state = STATE.WALLJUMPING
func _on_walljumps_body_exited(_body: Node2D) -> void:
	can_walljump = false
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
				main_velocity.y = 0
				
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


# IceBlocks
# Detects ice/slippery floors
func _on_ice_blocks_body_entered(_body: Node2D) -> void:
	is_ice_physics = true


# PhysicsObject
# Detects objects affected by the physics engine and its properties
func _on_physics_object_body_entered(_body: Node2D) -> void:
	is_pushing_physics_object = true
func _on_physics_object_body_exited(_body: Node2D) -> void:
	is_pushing_physics_object = false


# Wind
# Detects wind fields
func _on_wind_area_entered(_area: Area2D) -> void:
	is_on_wind = true
func _on_wind_area_exited(_area: Area2D) -> void:
	var get_areas = $extraCollisions/Wind.get_overlapping_areas()
	if get_areas == []:
		is_on_wind = false
