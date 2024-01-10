extends Node2D

@export var dialog_scene: PackedScene = null
@export var dialog_ID: int = 0
var global_dialog: Array = []



# Uses a local variable to change GLOBAL_GAME's dialog_events, and if the
# dialog_ID is already part of the global dialog array, it destroys itself
func _ready():
	global_dialog = GLOBAL_GAME.dialog_events
	
	if global_dialog.has(dialog_ID):
		queue_free()



func _on_body_entered(_body):
	
	# Checks if GLOBAL_GAME has the dialog_ID number. If it does, it means
	# the dialog was shown already so it doesn't do it until the game restarts
	# (not to be confused with resetting!)
	if !global_dialog.has(dialog_ID):
		global_dialog.append(dialog_ID)
		
		# Shows the dialog scene, if there isn't one already instantiated
		if dialog_scene != null:
			if get_tree().get_nodes_in_group("Dialog").size() < 1:
				var dialog_box_id = dialog_scene.instantiate()
				get_parent().add_child(dialog_box_id)
				queue_free()
	
