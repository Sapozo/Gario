extends Node2D

@export var level_music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if level_music != null:
		GameState.play_bgm(level_music)
