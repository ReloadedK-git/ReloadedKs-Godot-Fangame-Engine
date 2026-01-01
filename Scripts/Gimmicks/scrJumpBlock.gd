@tool
extends StaticBody2D

@export_enum("All jumps:1", "Single jumps:2", "Double jumps:3") var switch_on: int = 1
var is_solid: bool = true
@onready var block_sprite: Sprite2D = $Sprite2D



# Colorizes block and connects to the player's jump signals relative to the
# "switch_on" enum
func _ready() -> void:
	
	if not Engine.is_editor_hint():
		colorize_block()
		
		# Set a listener to the player's jump signals
		match switch_on:
			1:
				GLOBAL_SIGNALS.connect("player_jumped", block_switch)
				GLOBAL_SIGNALS.connect("player_djumped", block_switch)
			2:
				GLOBAL_SIGNALS.connect("player_jumped", block_switch)
			3:
				GLOBAL_SIGNALS.connect("player_djumped", block_switch)
	else:
		colorize_block()


# Updates block color
func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		colorize_block()



# Block switch behaviour
func block_switch():
	is_solid = !is_solid
	change_block()


func change_block():
	if is_solid:
		block_sprite.frame = 0
		$CollisionShape2D.set_disabled(false)
		$playerCrusher/CollisionShape2D.set_disabled(false)
	else:
		block_sprite.frame = 1
		$CollisionShape2D.set_disabled(true)
		$playerCrusher/CollisionShape2D.set_disabled(true)

# Sets the block's color
func colorize_block() -> void:
	match switch_on:
		1:
			block_sprite.set_self_modulate(Color.CORAL)
		2:
			block_sprite.set_self_modulate(Color.DODGER_BLUE)
		3:
			block_sprite.set_self_modulate(Color.GREEN)


# Crushes the player
func _on_player_crusher_body_entered(body: Node2D) -> void:
	if body.has_method("on_death"):
		body.on_death()
