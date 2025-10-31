extends TileMapLayer

@export var scenes_to_destroy: Array[Node] = []

# If a scene to destroy is assigned, and there are no more coins to collect,
# it destroys it, plays a sound and then destroys itself
func _physics_process(_delta: float) -> void:
	if scenes_to_destroy != null:
		if get_child_count() < 1:
			for i in range(scenes_to_destroy.size()):
				scenes_to_destroy[i].queue_free()
			GLOBAL_SOUNDS.play_sound("sndBlockChange")
			queue_free()
