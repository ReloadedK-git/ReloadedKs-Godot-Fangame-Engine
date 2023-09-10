extends Node2D

@export var song_id: AudioStream = null
@export var loop_start: float = 0.0
@export var loop_end: float = 0.0


func _ready():
	$Sprite2D.visible = false
	
	GLOBAL_MUSIC.song_id = song_id
	GLOBAL_MUSIC.loop_start = loop_start
	GLOBAL_MUSIC.loop_end = loop_end
	GLOBAL_MUSIC.music_update_and_play()
