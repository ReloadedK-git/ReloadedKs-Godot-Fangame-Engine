extends ParallaxBackground

@export var parallax_amount: float = 0.2
@export var background_size: Vector2 = Vector2(64, 64)
@export var background_index: CompressedTexture2D


func _ready():
	$ParallaxLayer.motion_scale = Vector2(parallax_amount, parallax_amount)
	$ParallaxLayer.motion_mirroring = background_size
	
	if background_index != null:
		$ParallaxLayer/TextureRect.texture = background_index
	else:
		print("objScrollingBackground's texture was not set. Using default grid texture")
	
	# Sets the background's size to the the equivalent of a single room.
	# We get the width and height from our project settings directly, so
	# the background gets adjusted no matter what (default: 800x608)
	var viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	$ParallaxLayer/TextureRect.size = Vector2(viewport_width, viewport_height)
