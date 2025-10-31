extends Node

# We get the audioPlayerList node from this variable. A little cleaner
@onready var audioPlayers: Node = $audioPlayerList


# Sound should keep on playing/processing even if the game is paused
func _ready():
	process_mode = PROCESS_MODE_ALWAYS


# This function loops through the 8 audioStreamPlayer nodes, gets one that's 
# not on use, assigns it the sound we want and then plays it.
# NOTE: The sfx resources are loaded into memory, cached and reused until
# they're not needed anymore, to avoid loading all sound effects at startup
func play_sound(sound) -> void:
	for audioStreamPlayers in audioPlayers.get_children():
		if not audioStreamPlayers.playing:
			audioStreamPlayers.stream = ResourceLoader.load("res://Audio/Sounds/" + sound + ".wav", ".wav", ResourceLoader.CACHE_MODE_REUSE)
			audioStreamPlayers.play()
			break


# Loops through the 8 audioStreamPlayer nodes, gets ones being used to play
# the sound "sound" and stops it
func stop_sound(sound) -> void:
	for audioStreamPlayers in audioPlayers.get_children():
		if audioStreamPlayers.get_stream() != null:
			if audioStreamPlayers.get_stream().get_path() == str("res://Audio/Sounds/" + sound + ".wav"):
				audioStreamPlayers.stop()
