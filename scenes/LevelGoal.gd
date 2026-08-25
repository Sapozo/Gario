extends Area2D

@export_file("*.tscn") var next_level_path: String


var is_triggered: bool = false



func _on_body_entered(body: Node2D) -> void:
	print(body.name," foi detectado.")
	if is_triggered == true:
		return
	else:
		if body.is_in_group("player"):
			is_triggered = true
			GameState.stop_bgm()
			GameState.victory.play()
			await get_tree().create_timer(0.5).timeout
			SceneTransition.change_scene_with_fade(next_level_path, 1.0)
