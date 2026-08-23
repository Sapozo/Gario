extends Camera2D


# Rapidez que o 'Camera-Shake' diminui por segundo
@export var decay: float = 0.8
# O deslocamento máximo em pixels
@export var max_offset: Vector2 = Vector2(16.0, 12.0)

var trauma: float = 0.0



func _ready() -> void:
	GameState.camera_shake_request.connect(_add_trauma)


func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(0.0, trauma - decay * delta)
		var shake_amount: float = trauma * trauma
		offset.x = max_offset.x * shake_amount * randf_range(-1.0, 1.0)
		offset.y = max_offset.y * shake_amount * randf_range(-1.0, 1.0)
	
	if trauma == 0.0:
		offset = Vector2.ZERO


func _add_trauma(amount: float):
	trauma = min(1.0, trauma + amount)
