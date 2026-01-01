extends Control

@export_multiline var dialog: Array[String]
@export var portrait: Array[Texture2D]
@onready var text_node = $CanvasLayer/Panel/RichTextLabel
@onready var portrait_node = $CanvasLayer/Panel/Sprite2D
var typewritter_on = false
var typewritter_timer: float = 0.02
var dialog_index = 0
var dialog_skipping: bool = false



func _ready():
	
	# Freezes objPlayer in place
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		GLOBAL_INSTANCES.objPlayerID.frozen = true
		GLOBAL_INSTANCES.objPlayerID.main_velocity = Vector2.ZERO
	
	# Shows the text as soon as the node is loaded
	load_dialog()


func _physics_process(_delta):
	
	if Input.is_action_just_pressed("button_jump"):
		
		# If the text is not being typed already, it executes the dialog
		# writting function
		if !typewritter_on:
			load_dialog()
		else:
			
			# Otherwise, while the dialog loop is being executed and "awaits" for
			# each timer to timeout, we asynchronously set this variable to true,
			# which will change the way the for loop works, writting the entire
			# string and setting the array to 0 (working as a skip). 
			# When it finishes, it will set this variable to false again,
			# resetting its behaviour to the normal typewritter one
			dialog_skipping = true
	
	# Full dialog skip
	if Input.is_action_just_pressed("button_shoot"):
		dialog_finished()


func load_dialog():
	
	# The typewritter effect will work as long as we're not skipping the dialog.
	# If we do skip it, we'll be changing the way the for loop works down below,
	# but the code will still execute and eventually reset until it's finished
	# all of the dialog
	if !dialog_skipping:
	
	# Checks if dialog_index's value is smaller than the one on dialog (which
	# is the max size of our array, or the last string of dialogue)
		if dialog_index < dialog.size():
			
			# Checks if text is currently being added. We can't add new text until
			# it finishes, otherwise we'll get an out of bounds error in our array
			typewritter_on = true
			
			# We set our portrait sprite first
			portrait_node.texture = portrait[dialog_index]
			
			# Resets the text
			text_node.text = ""
			
			# Creates a loop with a timer inside of it. Once the timer is up, it
			# adds to the text one letter at a time, until the string is completed
			for chars in dialog[dialog_index].length():
				
				# If we want to skip the dialog, by pressing "button_jump" while
				# the text is still getting typed, we complete the string and
				# finish the for loop
				if dialog_skipping:
					text_node.text = dialog[dialog_index]
					chars = 0
				else:
					
					# If we don't skip anything, we create a timer which will
					# wait until its timeout signal to type one character at a
					# time.
					# "await" can work asynchronously. If we set dialog_skipping
					# to true while we're awaiting, it will be read and we'll
					# finish the loop
					await get_tree().create_timer(typewritter_timer).timeout
					text_node.text += dialog[dialog_index][chars]
			
			# After our for loop is done, we jump to the next value in our
			# dialog array and allow the typewritter to work again
			dialog_index += 1
			typewritter_on = false
			dialog_skipping = false
			
		else:
			
			# Function triggered once the dialog has finished
			dialog_finished()


func dialog_finished():
	
	# Unfreezes objPlayer so it can move again
	if is_instance_valid(GLOBAL_INSTANCES.objPlayerID):
		GLOBAL_INSTANCES.objPlayerID.frozen = false
		
	queue_free()
