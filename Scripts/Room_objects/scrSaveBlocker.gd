extends StaticBody2D

var sprite_alpha: float = 0.0
var activate_visual: bool = false
var fade_amount: float = 0.1


func _ready():
	modulate.a = sprite_alpha

func _physics_process(_delta):
	
	
	
	modulate.a = sprite_alpha
	
	if (activate_visual == true):
		sprite_alpha -= fade_amount
		
		if sprite_alpha <= 0:
			sprite_alpha = 0
			activate_visual = false
		


func react_to_hit(_attack_type, _attack_damage):
	if (activate_visual == false):
		sprite_alpha = 1
		GLOBAL_SOUNDS.play_sound(GLOBAL_SOUNDS.sndSaveBlocker)
		activate_visual = true
#		print(_attack_type)

