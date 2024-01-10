extends AnimatableBody2D

@export var velocity: Vector2 = Vector2.ZERO
@export var trigger_id: int = 0
var triggered: bool = false

func _physics_process(_delta):
	if (velocity != Vector2.ZERO):
		if GLOBAL_GAME.triggered_events.has(trigger_id):
			move_and_collide(velocity)
			


# Destroys itself when outside of the view
func _on_visible_on_screen_notifier_2d_screen_exited():
	if triggered:
		queue_free()
