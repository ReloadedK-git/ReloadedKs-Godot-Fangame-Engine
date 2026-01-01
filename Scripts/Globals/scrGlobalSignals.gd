"""
This script is used for handling signals. Objects should emit and receive 
signals from here.
"""

extends Node

# Prevents warning messages for unused signals
@warning_ignore_start("UNUSED_SIGNAL")

# Player
signal player_died
signal player_jumped
signal player_djumped
signal player_walljumped
signal player_shot
signal player_climbed
