extends Path2D

@onready var path = $PathFollow2D
@export var progress_speed: float = 3.0
@export var path_loop: bool = false
@export var show_path: bool = false
@export var snap: bool = true



# Snap setting and path visuals
func _ready() -> void:
	
	# Whether the platform should snap the player or not
	$objMovingPlatform.snap = snap
	
	# Only get and set path points if show_path is enabled
	if show_path:
		var path_points: PackedVector2Array = get_curve().get_baked_points()
		$Visuals/Line2D.set_points(path_points)
		$Visuals/Line2D2.set_points(path_points)
		$Visuals/Line2D.set_visible(true)
		$Visuals/Line2D2.set_visible(true)
		
		# Corrects the offset of the moving platform's sprite
		$Visuals/Line2D.position.y += 8
		$Visuals/Line2D2.position.y += 8


# Path progress
func _physics_process(_delta: float) -> void:
	
	# Adds to the path progress each physics frame
	path.progress += progress_speed
	
	# If not looping, goes from A to B, and then from B to A
	if !path_loop:
		if (path.progress_ratio >= 1) or (path.progress_ratio <= 0):
			progress_speed = -progress_speed
	else:
		
		# Otherwise, just loops
		path.loop = true
