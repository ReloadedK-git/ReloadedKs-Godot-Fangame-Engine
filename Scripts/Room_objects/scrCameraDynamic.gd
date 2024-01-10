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
@export_category("Border Limits")
@export var stop_left_at: int = -10000000
@export var stop_up_at: int = -10000000
@export var stop_right_at: int = -10000000
@export var stop_down_at: int = -10000000
var focus_speed: float = 0.1
var get_xy: Vector2 = Vector2.ZERO



func _ready():
		
		# Gets camera target (player object, mostly)
		# We know from objPlayerStart that objPlayer gets created alongside
		# this camera object, so we just check in there if it actually exists
		if is_instance_valid(target_node):
			position = target_node.position
		else:
			target_node = self
		
		# Camera zoom at start
		if !ignore_global_zoom:
			zoom = Vector2(GLOBAL_SETTINGS.ZOOM_SCALING, GLOBAL_SETTINGS.ZOOM_SCALING)
		else:
			zoom = manual_zoom_amount
		
		# Invisible sprite, just for room creation
		$Sprite2D.visible = false
		
		# Sets the camera's limits
		for limit_array_1 in 4:
			var limit_array_2 = [stop_left_at, stop_up_at, stop_right_at, stop_down_at]
			set_limit(limit_array_1, limit_array_2[limit_array_1])
	


# Updates the camera target
func _physics_process(_delta):
	
	# Godot's "instance_exists"
	# Gets objPlayer's position, stores it on a local variable, follows it while
	# adding some linear interpolation
	if is_instance_valid(target_node):
		get_xy = target_node.position
		position = lerp(position, target_node.position, focus_speed)
	else:
		
		# If the player no longer exists, it gets the values of the variable
		# get_xy, which no longer updates, but it still stored the player's
		# last position, so we continue lerping to it
		position = lerp(position, get_xy, focus_speed)
	
