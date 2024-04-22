extends Node


# Add sound effects here!
const sndDeath = preload("res://Audio/Sounds/sndDeath.wav")
const sndDJump = preload("res://Audio/Sounds/sndDJump.wav")
const sndJump = preload("res://Audio/Sounds/sndJump.wav")
const sndShoot = preload("res://Audio/Sounds/sndShoot.wav")
const sndJumpRefresher = preload("res://Audio/Sounds/sndJumpRefresher.wav")
const sndMenuButton = preload("res://Audio/Sounds/sndMenuButton.wav")
const sndSave = preload("res://Audio/Sounds/sndSave.wav")
const sndSaveBlocker = preload("res://Audio/Sounds/sndSaveBlocker.wav")
const sndPause = preload("res://Audio/Sounds/sndPause.wav")
const sndHit = preload("res://Audio/Sounds/sndHit.wav")
const sndCherry = preload("res://Audio/Sounds/sndCherry.wav")
const sndCoin = preload("res://Audio/Sounds/sndCoin.wav")
const sndItem = preload("res://Audio/Sounds/sndItem.wav")
const sndWarp = preload("res://Audio/Sounds/sndWarp.wav")
const sndBlockChange = preload("res://Audio/Sounds/sndBlockChange.wav")
const sndSheepBlock = preload("res://Audio/Sounds/sndSheepBlock.wav")
const sndBouncyBlock = preload("res://Audio/Sounds/sndBouncyBlock.wav")
const sndSpikeBlock = preload("res://Audio/Sounds/sndSpikeBlock.wav")
const sndFadingBlock = preload("res://Audio/Sounds/sndFadingBlock.wav")

# We get the audioPlayerList node from this variable. A little cleaner
@onready var audioPlayers: Node = $audioPlayerList



# Sound should keep on playing/processing even if the game is paused
func _ready():
	process_mode = PROCESS_MODE_ALWAYS



# This function loops through the 8 audioStreamPlayer nodes, gets one that's 
# not on use, assigns it the sound we want and then plays it
func play_sound(sound) -> void:
	for audioStreamPlayers in audioPlayers.get_children():
		if not audioStreamPlayers.playing:
			audioStreamPlayers.stream = sound
			audioStreamPlayers.play()
			break


# Loops through the 8 audioStreamPlayer nodes, gets ones being used to play
# the sound "sound" and stops it
func stop_sound(sound) -> void:
	for audioStreamPlayers in audioPlayers.get_children():
		if audioStreamPlayers.get_stream() == sound:
			audioStreamPlayers.stop()
	
