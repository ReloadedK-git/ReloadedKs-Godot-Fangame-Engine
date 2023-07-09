extends Camera2D

@export var target_node: Node = null
@export var camera_width: float = 800
@export var camera_height: float = 608
@export var scrolling_speed: int = 10
@export var camera_zoom: Vector2 = Vector2(1, 1)


func _ready():
	
	# Sets initial zoom and scrolling speed
	zoom = camera_zoom
	position_smoothing_speed = scrolling_speed
	
	# Sets the camera target. If it's valid, it then sets the initial position
	# to the center of the screen relative to the target's position
	if is_instance_valid(target_node):
		set_camera_target()
		
		# Turns off smoothing temporarily, until the camera is placed correctly
		position_smoothing_enabled = false
	else:
		target_node = self
	
	# Invisible sprite, just for room creation
	$Sprite2D.visible = false
	
	# Sets position smoothing after the camera is already set to the initial
	# position
	await get_tree().create_timer(0.01).timeout
	position_smoothing_enabled = true


func _physics_process(_delta):
	if is_instance_valid(target_node):
		set_camera_target()


# Sets the camera target. If it's valid, it then sets the position to the
# center of the screen relative to the target's position
func set_camera_target():
	position.x = floor(target_node.position.x / camera_width) * camera_width + (camera_width / 2)
	position.y = floor(target_node.position.y / camera_height) * camera_height + (camera_height / 2)
