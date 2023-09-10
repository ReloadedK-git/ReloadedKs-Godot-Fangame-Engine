extends Camera2D

@export var target_node: Node = null
@export var camera_zoom: Vector2 = Vector2(2, 2)

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
		zoom = camera_zoom
		
		# Invisible sprite, just for room creation
		$Sprite2D.visible = false
		
		# Sets the camera's limits
		set_limit(SIDE_LEFT, stop_left_at)
		set_limit(SIDE_TOP, stop_up_at)
		set_limit(SIDE_RIGHT, stop_right_at)
		set_limit(SIDE_BOTTOM, stop_down_at)
		

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
		
