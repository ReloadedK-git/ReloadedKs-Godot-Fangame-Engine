extends CharacterBody2D

"""
---------- VARIABLE DECLARATIONS ---------- 
"""
var gravity: int = 1000
var v_speed: int = 470
var h_speed: int = 150
var s_jump_speed: int = 405
var d_jump_speed: int = 350
var jump_release_falloff: float = 0.45
var xscale: bool = true
var frozen: bool = false
var d_jump: bool = true
var d_jump_aux: bool = false
var in_water: bool = false
var in_water_djump: bool = false
var v_speed_modifier: float = 1.0
var can_walljump: bool = false
var is_walljumping: bool = false
var create_bullet := preload("res://Objects/Player/objBullet.tscn")
var jump_particle := preload("res://Objects/Player/objJumpParticle.tscn")
@onready var animated_sprite = $playerSprites

# Signals emitted by the player's actions
signal player_died
signal player_jumped
signal player_djumped
signal player_walljumped
signal player_shot



func _ready():
	
	# If a savefile exists (we've saved at least once), we move the player to
	# the saved position, and also set its sprite state (flipped or not).
	if !GLOBAL_SAVELOAD.variableGameData.first_time_saving:
		set_position_on_load()
		flip_sprites_on_creation()
	
	# Sets a very important global variable. Lets everything know that the
	# player does in fact exist and assigns it with its "id"
	GLOBAL_INSTANCES.objPlayerID = self
	
	# Turns hitbox visible if debug setting is enabled
	if GLOBAL_GAME.debug_hitbox:
		$playerMask/ColorRect.visible = GLOBAL_GAME.debug_hitbox


"""
---------- MAIN LOGIC LOOP ----------
"""
func _physics_process(delta):
	
	# If we haven't saved before, it makes a special type of save which sets
	# things up for the rest of the game. 
	# NOTE: This function used to be executed in _ready(), but due to some of 
	# the timing related changes made in v4.2, this was moved here and works
	# again.
	if (GLOBAL_SAVELOAD.variableGameData.first_time_saving == true):
		set_first_time_saving()
	
	# More specific logic is handled inside of methods, which keeps the main
	# loop clean and easier to read.
	# These methods should only work if the player isn't in the middle of a
	# dialog sequence/cutscene
	if !frozen:
		
		# These movement modules should only work if the player is not
		# walljumping
		if !is_walljumping:
			handle_movement()
			handle_jumping()
			handle_shooting()
			handle_water()
		
		# Walljumping is its own special case. If we are in a walljumping
		# state, it deactivates the previous methods/modules
		handle_walljumping()
	
	# These methods should be called before "move_and_slide()", and should
	# always work (even if the player is frozen)
	handle_masks()
	handle_gravity(delta)
	debug_mouse_teleport()
	
	# "move_and_slide()" handles all sorts of movement, using velocity values
	# which includes running, jumping and more.
	# Call it before "_handle_animations()". Doing so will properly check for
	# "is_on_floor()", which requires collision data. This prevents a 1 frame
	# animation bug when resetting.
	move_and_slide()
	handle_animations()


# Debug key inputs
func _unhandled_key_input(event: InputEvent):
	handle_debug_keys(event)


"""
---------- CUSTOM METHODS ----------
"""
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
	GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped = xscale
	GLOBAL_SAVELOAD.variableGameData.room_name = get_tree().get_current_scene().get_scene_file_path()
	GLOBAL_SAVELOAD.variableGameData.first_time_saving = false
	
	# After changing the variable game data to the proper values, we save them.
	GLOBAL_SAVELOAD.save_data()
	
	# Then, after saving for the fist time in-game, a reload is needed.
	# What this does is replacing the old default values with the new ones
	# we just saved, reading them once through loading.
	GLOBAL_SAVELOAD.load_data()


# Handles gravity / falling
func handle_gravity(delta) -> void:
	
	# Adds the gravity when you're grounded or not on a platform
	if (is_on_floor() == false):
		velocity.y += gravity * delta
		
		# Clamps the falling value to v_speed, which is also modified by 
		# water physics. Check _handle_water()
		velocity.y = min(v_speed * v_speed_modifier, velocity.y)


# Main movement logic (walking/running)
func handle_movement() -> void:
	
	# Get the input direction and handle the movement
	var main_direction: float = Input.get_axis("button_left", "button_right")
	var extra_direction_keys: float = Input.get_axis("button_left_extra", "button_right_extra")
	
	# Lambda function, also called "anonymous function".
	# It's a method that only works inside of this event, declared inside
	# of a variable and executed by using "call()".
	# Useful for keeping code cleaner and less repetitive in certain cases,
	# but it's not mandatory.
	# Changes xscale using a direction argument, as long as the player is
	# moving
	var xscale_to_direction = func(h_direction):
		
		# Player needs to be moving in order to flip the xscale
		if velocity.x != 0:
			xscale = h_direction > 0
	
	# Extra keys off/on
	if !GLOBAL_SETTINGS.EXTRA_KEYS:
		velocity.x = main_direction * h_speed
		xscale_to_direction.call(main_direction)
	else:
		
		# If not pressing/activating extra keys, use normal direction vector
		if extra_direction_keys == 0:
			velocity.x = main_direction * h_speed
			xscale_to_direction.call(main_direction)
		else:
			
			# Controller stick deadzone correction (values go from -1.0 to 1.0)
			if extra_direction_keys > 0:
				extra_direction_keys = 1
			if extra_direction_keys < 0:
				extra_direction_keys = -1
			
			# Adds velocity from extra_direction_keys, the secondary direction 
			# vector
			velocity.x = extra_direction_keys * h_speed
			xscale_to_direction.call(extra_direction_keys)


# Jumping logic
func handle_jumping() -> void:
	
	# Always allow djump if you're grounded
	if (is_on_floor() == true):
		d_jump = true
	
	# Adds vertical velocity when jumping
	if Input.is_action_just_pressed("button_jump"):
		if (is_on_floor() == true):
			velocity.y = -s_jump_speed
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndJump)
			
			# Emit the "player_jumped" signal
			player_jumped.emit()
			
		# If d_jump is available or you're inside a platform, the player now
		# jumps with d_jump_speed. Inside of platforms you can jump infinitely,
		# and they are the ones who set d_jump_aux to true or false.
		elif d_jump or d_jump_aux or in_water_djump or GLOBAL_GAME.debug_inf_jump:
			velocity.y = -d_jump_speed
			d_jump = false
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndDJump)
			
			# Emit the "player_djumped" signal
			player_djumped.emit()
			
			# Jump particles on djump, as long as the player is not in water
			if (in_water == false):
				var jump_particle_id = jump_particle.instantiate()
				get_parent().add_child(jump_particle_id)
				jump_particle_id.global_position = Vector2(global_position.x, global_position.y + 12)
	
	# Adds some "gravity" if you release the jump button mid-jump
	if Input.is_action_just_released("button_jump") and (velocity.y < 0):
		velocity.y *= jump_release_falloff


# Method that handles the walljumping gimmick. It's divided into 2 parts:
# 1) Setting walljumping (whether it should be active or not)
# 2) The "walljumping" action
func handle_walljumping():
	
	# 1) Setting the walljump state:
	# If we collided with a vine
	if can_walljump:
	
		# Walljumping shouldn't activate if we're grounded. Otherwise,
		# it if wasn't active before, it now is. Also sets the vertical
		# velocity to 0, so we don't slide with inertia
		if is_on_floor():
			is_walljumping = false
		else:
			
			if !is_walljumping:
				velocity.y = 0
				is_walljumping = true
	else:
		is_walljumping = false
	
	
	
	# 2) "Walljumping" action:
	# If we are in a walljumping state, it slows our vertical speed down and
	# prepares us for walljumping or leaving it altogether
	if is_walljumping:
		v_speed_modifier = 0.2
		var jump_direction = get_wall_normal()
		
		# Lambda function, also called "anonymous function".
		# It's a method that only works inside of this event, declared inside
		# of a variable and executed by using "call()".
		# Useful for keeping code cleaner and less repetitive in certain cases,
		# but it's not mandatory
		var walljumping_action = func():
			velocity.x = jump_direction.x * h_speed
			velocity.y = -s_jump_speed
			is_walljumping = false
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndJump)
			
			# Emit the "player_walljumped" signal
			player_walljumped.emit()
		
		# Walljumping should only happen if we hold the jump button first
		if Input.is_action_pressed("button_jump"):
			
			# Extra keys off/on
			if !GLOBAL_SETTINGS.EXTRA_KEYS:
				
				# Walljump to the right
				if (Input.is_action_pressed("button_right")) and (jump_direction == Vector2.RIGHT):
					if !Input.is_action_pressed("button_left"):
						walljumping_action.call()
				
				# Walljump to the left
				if Input.is_action_pressed("button_left") and (jump_direction == Vector2.LEFT):
					if !Input.is_action_pressed("button_right"):
						walljumping_action.call()
			else:
				
				# Walljump to the right
				if (Input.is_action_pressed("button_right") or Input.is_action_pressed("button_right_extra")) and (jump_direction == Vector2.RIGHT):
					if (!Input.is_action_pressed("button_left") or !Input.is_action_pressed("button_left_extra")):
						walljumping_action.call()
				
				# Walljump to the left
				if (Input.is_action_pressed("button_left") or Input.is_action_pressed("button_left_extra")) and (jump_direction == Vector2.LEFT):
					if (!Input.is_action_pressed("button_right") or !Input.is_action_pressed("button_right_extra")):
						walljumping_action.call()
		else:
			
			# Extra keys off/on
			if !GLOBAL_SETTINGS.EXTRA_KEYS:
				
				# Not holding the jump button, but pressing left or right on the 
				# opposite direction to the vine, leaves it and stops the
				# walljumping state.
				# This won't work if both the left and right buttons are pressed 
				# at the same time. Feels cleaner this way
				if Input.is_action_pressed("button_right") and (jump_direction == Vector2.RIGHT):
					if !Input.is_action_pressed("button_left"):
						is_walljumping = false
				
				if Input.is_action_pressed("button_left") and (jump_direction == Vector2.LEFT):
					if !Input.is_action_pressed("button_right"):
						is_walljumping = false
			else:
				if (Input.is_action_pressed("button_right") or Input.is_action_pressed("button_right_extra")) and (jump_direction == Vector2.RIGHT):
					if (!Input.is_action_pressed("button_left") or !Input.is_action_pressed("button_left_extra")):
						is_walljumping = false
				
				if (Input.is_action_pressed("button_left") or Input.is_action_pressed("button_left_extra")) and (jump_direction == Vector2.LEFT):
					if (!Input.is_action_pressed("button_right") or !Input.is_action_pressed("button_right_extra")):
						is_walljumping = false
	else:
		
		# Sets things back to normal (not walljumping anymore).
		# handle_water() sets the "v_speed_modifier" variable properly, so we
		# just call it here instead of re-setting things manually
		handle_water()


# Shooting logic
func handle_shooting():
	if Input.is_action_just_pressed("button_shoot"):
		
		# An equivalent to gamemaker's "instance_number() < 4"
		# It checks how many nodes belonging to the "Bullet" group
		# exist in the current scene
		if get_tree().get_nodes_in_group("Bullet").size() < 4:
			
			# Loads the bullet scene, instances it, assigns the shooting direction
			# and global position, makes a sound and then adds it to the main scene 
			# (the actual game)
			var create_bullet_id: AnimatableBody2D = create_bullet.instantiate()
			if xscale:
				create_bullet_id.looking_at = 1
			else:
				create_bullet_id.looking_at = -1
			
			# Bullet's x coordinate:
			#	-Takes into account the global x
			#	-The bullet spacing, relative to where we are looking at 
			create_bullet_id.global_position = Vector2(global_position.x, global_position.y + 5)
			GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndShoot)
			
			# After everything is set and done, creates the bullet
			get_parent().add_child(create_bullet_id)
			
			# Emit the "player_shot" signal
			player_shot.emit()


# Method to handle sprite animations
func handle_animations() -> void:
	
	# We assign each sprite animation, unless we are slidding/walljumping
	if !is_walljumping:
		
		# If on the air, checks Y velocity for the jumping or falling animations
		if (is_on_floor() == false):
			if (velocity.y < 0):
				animated_sprite.play("jump")
			else:
				animated_sprite.play("fall")
		else:
			# If grounded or on a platform, checks X velocity for the idle or 
			# running animations
			if (velocity.x == 0):
				animated_sprite.play("idle")
			else:
				animated_sprite.play("running")
	else:
		
		# If we are slidding/walljumping, we set the proper animation
		animated_sprite.play("slidding")
		
	# Flips the player sprite using the "xscale" variable
	animated_sprite.flip_h = !xscale


# Checks the scrGlobalSaveload autoload in order to know if the sprite should
# be flipped horizontally on creation
func flip_sprites_on_creation() -> void:
	
	animated_sprite.flip_h = !GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped
	xscale = GLOBAL_SAVELOAD.variableGameData.player_sprite_flipped
	
	# Also rotates masks
	handle_masks()


# Handles masks specifically. Looks cleaner if put into its own method rather
# than placing it inside the animations one.
# Keep in mind, masks inside $extraCollisions might have different shapes,
# intended for different purposes
func handle_masks() -> void:
	if xscale:
		$playerMask.position.x = 1
	else:
		$playerMask.position.x = -1
	
	# We rotate the scale for the collision containers, so we don't have to
	# reference each one of them
	$extraCollisions.scale.x = $playerMask.position.x


# Interaction with water
func handle_water() -> void:
	
	# Changes the player's falling speed when on water, and returns it to 
	# normal when outside of it. Values can get changed here, for convenience
	if in_water:
		v_speed_modifier = 0.4
	else:
		v_speed_modifier = 1.0


# Teleports the player to the mouse position when "button_debug_teleport"
# is pressed (only on debug mode)
func debug_mouse_teleport() -> void:
	if GLOBAL_GAME.debug_mode:
		if Input.is_action_pressed("button_debug_teleport"):
			position = get_global_mouse_position()
			velocity.y = 0


# Handles all debug key toggles. Keys are hardcoded.
func handle_debug_keys(event: InputEvent) -> void:
	
	# Debug keys are activated only in debug mode
	if GLOBAL_GAME.debug_mode:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			
			# Toggle godmode
			if event.keycode == KEY_1:
				GLOBAL_GAME.debug_godmode = !GLOBAL_GAME.debug_godmode
				
				# Sound for godmode
				if GLOBAL_GAME.debug_godmode:
					GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndBlockChange)
			
			# Toggle infjump
			if event.keycode == KEY_2:
				GLOBAL_GAME.debug_inf_jump = !GLOBAL_GAME.debug_inf_jump
				
				# Sound for infinite jump
				if GLOBAL_GAME.debug_inf_jump:
					GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndBouncyBlock)
			
			# Toggle hitbox view
			if event.keycode == KEY_3:
				GLOBAL_GAME.debug_hitbox = !GLOBAL_GAME.debug_hitbox
				$playerMask/ColorRect.visible = GLOBAL_GAME.debug_hitbox
				
				# Sound for debug hitbox
				if GLOBAL_GAME.debug_hitbox:
					GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndFadingBlock)
			
			# Debug save
			if event.keycode == KEY_4:
				GLOBAL_SAVELOAD.save_game(true)
				GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndSave)


# Everything that should happen after the player dies
func on_death():
	
	# Death should only happen if we're out of godmode
	if !GLOBAL_GAME.debug_godmode:
		
		# We load a particle emitter, which does the visual stuff we want
		var blood_emitter = load("res://Objects/Player/objBloodEmitter.tscn")
		var blood_emitter_id = blood_emitter.instantiate()
		blood_emitter_id.position = Vector2(position.x, position.y)
		if xscale:
			blood_emitter_id.side = 1
		else:
			blood_emitter_id.side = -1
		
		# We add a sibling node to the player, not a child node, since the
		# player object gets freed!
		add_sibling(blood_emitter_id)
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndDeath)
		
		# Adds an extra death to the global death counter
		GLOBAL_GAME.deaths += 1
		
		# Emit "player_died"
		player_died.emit()
		
		# Destroys the player
		queue_free()



"""
---------- EXTRA COLLISIONS ----------
"""
# Platforms: 
# -> Gives infinite djump while touching them
func _on_platforms_body_entered(_body):
	d_jump_aux = true

# Checks if we're no longer touching a platform after leaving another 
# platform, only then setting d_jump_aux to false
func _on_platforms_body_exited(_body):
	if !$extraCollisions/Platforms.has_overlapping_bodies():
		d_jump_aux = false
		
		# The player will snap to platforms only if they have it set to true.
		# NOTE: Snapping works well enough in most situations, but due to how
		# Godot handles physics, they're not as consistent as gamemaker's. Keep
		# that in mind if you plan to make things like needle and you need
		# lots of precision!
		if _body.snap:
			
			# Margin variables. Makes platforms feel more "natural" and tight
			var horizontal_margin = 22 * _body.get_scale().x
			var vertical_margin = 16
			
			# Horizontal and vertical detection
			if (position.x > _body.position.x - horizontal_margin) and (position.x < _body.position.x + horizontal_margin):
				if _body.position.y - vertical_margin > position.y:
					
					# Checks if we're moving upwards after leaving a platform
					if (velocity.y < 0):
						if _body.move_speed.y < 0:
							
							# If the platform is going up and so are we, it simply 
							# sets the velocity to 0
							velocity.y = 0
						else:
							
							# If the platform is going down but we are going up,
							# it sets the velocity to the platform's, times 100.
							# Brute force approach that somehow works well enough
							velocity.y = (_body.move_speed.y + 1) * 100


# Killers
# -> Calls "on_death"
func _on_killers_body_entered(_body):
	on_death()


# Water
# -> Indicates whether the player is inside of water
func _on_water_area_entered(_area):
	in_water = true
	
	# If the water type is not catharsis (type 3)
	if _area.get_parent().water_type != 3:
		in_water_djump = true

# Checks if we're no longer touching water after leaving another body of
# water, only then setting in_water to false
func _on_water_area_exited(_area):
	if !$extraCollisions/Water.has_overlapping_areas():
		in_water = false
		in_water_djump = false
		
		# If the water type is refresh (type 2)
		if _area.get_parent().water_type == 2:
			d_jump = true


# IsCrushed
# -> Checks if the player is inside of walls, calling "on_death" if true.
#    It has a smaller collision shape
func _on_is_crushed_body_entered(_body):
	on_death()


# Vines
# -> Indicates whether the player is touching a vine, for walljumping
func _on_vines_body_entered(_body):
	if !can_walljump:
		can_walljump = true
func _on_vines_body_exited(_body):
	can_walljump = false


func _on_sheep_blocks_body_entered(body):
	if !body.activated:
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndSheepBlock)
		body.animation_player.play("animSheepBlock")
		body.activated = true
