@tool
extends Polygon2D

var global_trigger: Array = []
@export var needs_activation: bool = true
@onready var multitrigger_polygon: Polygon2D = $"."
@onready var multitrigger_collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D

# Defines an activation value, one to show in the label and then turns it into
# a string, for visual feedback
@export var activation_id: int = 0:
	set(activation_property_id):
		activation_id = activation_property_id
		$Area2D/Label.text = str(activation_id)

# Defines a trigger value, one to show in the label and then turns it into a
# string, for visual feedback
@export var trigger_id: int = 0:
	set(trigger_property_id):
		trigger_id = trigger_property_id
		$Area2D/Label2.text = str(trigger_id)

# For sounds, you probably want to use WAV files
@export var trigger_sound: AudioStreamWAV = null



# This makes the trigger invisible when the game is running, but not in the
# editor itself.
# Also sets global_trigger from GLOBAL_GAME's main array (ONLY if the game is
# running. Otherwise it will return lots of errors, because GLOBAL_GAME isn't
# loaded on editor mode)
func _ready():
	if not Engine.is_editor_hint():
		hide()
		
		# Be careful when you use @tool. Make sure this is set only when the
		# game is running, and not in the editor
		global_trigger = GLOBAL_GAME.triggered_events
		
		# Gets collision points from the drawn polygon
		multitrigger_collision_polygon.polygon = multitrigger_polygon.get_polygon()


func _physics_process(_delta):
	if Engine.is_editor_hint():
		
		if needs_activation == false:
			$Area2D/Label.visible = false
			$Area2D/Label2.position.y = 2
		else:
			$Area2D/Label.visible = true
			$Area2D/Label2.position.y = 10



# Sets the way the multitrigger should operate
func trigger_behaviour():
	if !global_trigger.has(trigger_id):
		global_trigger.append(trigger_id)
		
		# Play a sound when triggered, if we loaded one previously
		if trigger_sound != null:
			GLOBAL_SOUNDS.play_sound(trigger_sound.get_path().get_file().trim_suffix('.wav'))
	
	queue_free()


func _on_area_2d_body_entered(_body):
	# Checks if the triggers needs to activate from other trigger
	if needs_activation == true:
		
		# Searchs the activation value it needs inside the global trigger
		# array
		if global_trigger.has(activation_id):
			trigger_behaviour()
	else:
		trigger_behaviour()
