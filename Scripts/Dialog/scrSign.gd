extends Area2D

@export var dialog_scene: PackedScene = null
var player_is_colliding: bool = false
var dialog_box


# Sets the label and turns it invisible at startup
func _ready():
	$Label.text = 'Press "' + handle_text("button_up") +'"'
	$Label.visible = false


func _physics_process(_delta):
	
	# This is repeated here because it will update the text if we changed our
	# input device (keyboard to controller, or controller to keyboard)
	$Label.text = 'Press "' + handle_text("button_up") +'"'
	
	
	# Creates a dialog scene when the player is colliding and button_up is
	# pressed
	if player_is_colliding:
		if dialog_scene != null:
			if Input.is_action_just_pressed("button_up"):
				if get_tree().get_nodes_in_group("Dialog").size() < 1:
					var dialog_box_id = dialog_scene.instantiate()
					get_parent().add_child(dialog_box_id)
		
		# Toggles the label's visibility by checking if the player exists and
		# is frozen
		if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
			if !GLOBAL_INSTANCES.objPlayerID.frozen:
				$Label.visible = true
			else:
				$Label.visible = false
	else:
		$Label.visible = false



# Gets a string with the name of the input we want to use by using a function
# inside of GLOBAL_GAME
func handle_text(button_id):
	var key_to_interact = GLOBAL_GAME.get_input_name(button_id, GLOBAL_GAME.global_input_device)
	return key_to_interact


# Detects if a player is colliding or not using signals
func _on_body_entered(body):
	if (body.name == "objPlayer"):
		player_is_colliding = true

func _on_body_exited(body):
	if (body.name == "objPlayer"):
		player_is_colliding = false
	
