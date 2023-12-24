extends Camera2D

@export var target_node: Node = null
@export var scrolling_speed: int = 10
var camera_width: float = 800
var camera_height: float = 608



# Sets the zoom scaling and position smoothing speed once
func _ready():
	
	# Sets the camera for each reset
	if is_instance_valid(target_node):
		set_camera_target()
	else:
		target_node = self
	
	# Sets initial zoom and scrolling speed
	zoom = Vector2(GLOBAL_SETTINGS.ZOOM_SCALING, GLOBAL_SETTINGS.ZOOM_SCALING)
	position_smoothing_speed = scrolling_speed
	
	# Hides the sprite
	$Sprite2D.visible = false


# Updates the camera target and enables position smoothing if disabled
func _physics_process(_delta):
	if is_instance_valid(target_node):
		set_camera_target()
	
	if !is_position_smoothing_enabled():
		position_smoothing_enabled = true



# Sets the camera target. If it's valid, it then sets the position to the
# center of the screen relative to the target's position
func set_camera_target():
	
	var camera_width_zoom: float = camera_width / GLOBAL_SETTINGS.ZOOM_SCALING
	var camera_height_zoom: float = camera_height / GLOBAL_SETTINGS.ZOOM_SCALING
	
	position.x = floor(target_node.position.x / camera_width_zoom) * camera_width_zoom + (camera_width_zoom / 2)
	position.y = floor(target_node.position.y / camera_height_zoom) * camera_height_zoom + (camera_height_zoom / 2)
