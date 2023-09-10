@tool
extends Area2D

var global_trigger: Array = []

# Defines a trigger value, one to show in the label and then turns it into a
# string, for visual feedback
@export var trigger_id: int = 0:
	set(trigger_property_id):
		trigger_id = trigger_property_id
		$Label.text = str(trigger_id)

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



# Adds its value to the global trigger array, which triggered objects read
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if !global_trigger.has(trigger_id):
			global_trigger.append(trigger_id)
			
			# Play a sound when triggered, if we loaded one previously
			if trigger_sound != null:
				GLOBAL_SOUNDS.play_sound(trigger_sound)
		
		queue_free()

