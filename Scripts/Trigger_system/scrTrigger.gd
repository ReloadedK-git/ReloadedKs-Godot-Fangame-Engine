@tool
extends Polygon2D

var global_trigger: Array = []
@onready var trigger_polygon: Polygon2D = $"."
@onready var trigger_collision_polygon: CollisionPolygon2D = $Area2D/CollisionPolygon2D



# Defines a trigger value, one to show in the label and then turns it into a
# string, for visual feedback
@export var trigger_id: int = 0:
	set(trigger_property_id):
		trigger_id = trigger_property_id
		$Area2D/Label.text = str(trigger_id)

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
		trigger_collision_polygon.polygon = trigger_polygon.get_polygon()



# Adds its value to the global trigger array, which triggered objects read
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if !global_trigger.has(trigger_id):
			global_trigger.append(trigger_id)
			
			# Play a sound when triggered, if we loaded one previously
			if trigger_sound != null:
				GLOBAL_SOUNDS.play_sound(trigger_sound)
		
		queue_free()
