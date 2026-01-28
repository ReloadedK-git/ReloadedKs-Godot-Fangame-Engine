extends Camera2D

@export var target_node: Node = null

# Zoom related variables. You can ignore the global zoom from the settings and
# add the zoom amount manually
@export_category("Zoom")
@export var ignore_global_zoom: bool = false
@export var manual_zoom_amount: Vector2 = Vector2.ONE

# The big numbers inside of these variables means the camera will scroll freely
# inside of a room, without any border limit.
# If you want the camera to stop at a certain point, you set the limits inside
# of each room in the object's properties
@export_category("Limits")
@export var stop_left_at: int = -10000000
@export var stop_up_at: int = -10000000
@export var stop_right_at: int = 10000000
@export var stop_down_at: int = 10000000
var focus_speed: float = 0.1
var get_xy: Vector2 = Vector2.ZERO



func _ready():
	
	# If you want to target the player, you should make sure it's instanced
	# before the camera. This is so the camera instantly focuses on it,
	# preventing a strange effect each time you restart.
	# Always place the player above the camera scene inside the node tree:
	# -> Room_related
	# |--> objPlayer
	# |--> objCameraDynamic
	# If you don't do this, you should get a warning
	if target_node.is_in_group("Player"):
		if get_index() < target_node.get_index():
			push_error("\n\n Remember to place the player BEFORE the camera! \n Example: \n -objPlayer \n -objCameraDynamic")
			pass
	
	# Gets camera target (player object, mostly)
	# We know from objPlayerStart that objPlayer gets created alongside
	# this camera object, so we just check in there if it actually exists
	if is_instance_valid(target_node):
		global_position = target_node.global_position
	else:
		target_node = self
	
	camera_zoom()
	
	# Invisible sprite, just for room creation
	$Sprite2D.visible = false
	
	# Global limits are all 0 by default. If we load and they are all 0,
	# limits from the camera object are used. If they're not 0, it means
	# they were changed and saved, so we read and use those values to set
	# the limits instantly
	if GLOBAL_GAME.global_camera_limits == [0, 0, 0, 0]:
	
		# Sets the camera's limits
		for limit_array_1 in 4:
			var limit_array_2 = [stop_left_at, stop_up_at, stop_right_at, stop_down_at]
			set_limit(limit_array_1, limit_array_2[limit_array_1])
	else:
		
		# Sets updated limits from the current savefile
		for limit_array_1 in 4:
			var limit_array_2 = GLOBAL_GAME.global_camera_limits
			set_limit(limit_array_1, limit_array_2[limit_array_1])


# Updates the camera target
func _physics_process(_delta):
	
	camera_zoom()
	
	# Godot's "instance_exists"
	# Gets objPlayer's global_position, stores it on a local variable, follows it while
	# adding some linear interpolation
	if is_instance_valid(target_node):
		get_xy = target_node.global_position
		global_position = lerp(global_position, target_node.global_position, focus_speed)
	else:
		
		# If the player no longer exists, it gets the values of the variable
		# get_xy, which no longer updates, but it still stored the player's
		# last global_position, so we continue lerping to it
		global_position = lerp(global_position, get_xy, focus_speed)



func camera_zoom() -> void:
	
	# Camera zoom at start
	if !ignore_global_zoom:
		zoom = Vector2(GLOBAL_GAME.global_camera_zoom, GLOBAL_GAME.global_camera_zoom)
	else:
		zoom = manual_zoom_amount
