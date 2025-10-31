@tool
extends TileMapLayer

@onready var animation_player: Node = get_node("AnimationPlayer")
@export var tilemap_color: Color = Color.BLUE
var tilemap_blinking: bool = false
var activated: bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	
	if Engine.is_editor_hint():
		
		# Duplicates the shader material, so when editing we don't share the
		# shader if we have multiple sheep blocks
		material = material.duplicate()
	else:
		$".".material.set_shader_parameter("new_color", tilemap_color)
		$".".material.set_shader_parameter("blinking", tilemap_blinking)
		
		# Stop sheep block sound
		GLOBAL_SOUNDS.stop_sound("sndSheepBlock")


# Updates shader color on the editor
func _physics_process(_delta):
	
	# Updates shader color on the editor
	if Engine.is_editor_hint():
		$".".material.set_shader_parameter("new_color", tilemap_color)
	


# Uses an AnimationPlayer node to animate the blinking effect when activated,
# updating a shader parameter and destroying the block 1.5 seconds later
func tilemap_blink():
	tilemap_blinking = !tilemap_blinking
	$".".material.set_shader_parameter("blinking", tilemap_blinking)
