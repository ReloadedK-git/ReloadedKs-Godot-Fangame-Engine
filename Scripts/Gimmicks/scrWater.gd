@tool
extends Area2D

"""
The way to use this water object is rather simple:
	1) You put this where you want to in your level
	2) Go to the "Transform" tab in the editor properties and modify the
	   scene's scale
	3) Copy it as many times as you see fit depending on your level.
	
You can also make the sprite invisible, in case you don't need it, and add some
other visual effects. The objPlayer object handles the water collision and
interaction anyways.
This object draws even on top of the player. Check the "Ordering" tab of the
scene's properties.

"""

func _ready():
	$Sprite2D.modulate = 'ffffff60'
	
	# This is so we can check how the water really looks, inside of the editor
	# Check the very first line of the script (@tool) and what it does.
	# This also turns the little script icons on the scene tree blue
#	if Engine.is_editor_hint():
#		$Sprite2D.modulate = 'ffffff60'
#	else:
#		$Sprite2D.modulate = 'ffffff60'
