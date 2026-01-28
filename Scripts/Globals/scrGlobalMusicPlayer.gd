extends AudioStreamPlayer

var song_playing: AudioStream = null
var song_id: AudioStream = null
var loop_start: float = 0.0
var loop_end: float = 0.0


# Music should keep on playing/processing even if the game is paused
func _ready():
	process_mode = PROCESS_MODE_ALWAYS


# Updates the volume level from the "Music" audio bus. Also checks if the music
# is paused or not
func _physics_process(_delta):
	
	volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	
	# Set the start and end positions for the music loop
	set_loop_positions()



# Checks if song_playing is the same as song_id. If this is the case, then its
# song_playing value gets replaced and streamed. If we warp to a different room
# with the same song_id, it keeps playing the same song and doesn't reset it
func music_update_and_play() -> void:
	if song_playing != song_id:
		song_playing = song_id
		
		autoplay = true
		stream = song_playing
		play()


# If we set a loop end position from objMusicPlayer, we then set the playback
# position once we reach the loop end position, and loop between those points
func set_loop_positions():
	if loop_end != 0.0:
		if get_playback_position() > loop_end:
			seek(loop_start)
