extends CanvasLayer



# Camada toda preta para efeito fade-in e fade-out
@onready var color_rect: ColorRect = $ColorRect



func change_scene_with_fade(target_scene_path: String, duration: float = 0.5) -> void:
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "modulate:a", 1.0, (duration)).set_trans(Tween.TRANS_SINE)
	await tween_out.finished
	get_tree().change_scene_to_file(target_scene_path)
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 0.0, (duration)).set_trans(Tween.TRANS_SINE)
	await tween_in.finished
