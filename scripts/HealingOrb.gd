extends Area2D

@export var value: int = 2

# Armazena a altura original do item
var base_y: float
# Contador de tempo para onda do sin()
var float_offset:float = 0.0
var is_floating: bool



func _ready() -> void:
	base_y = position.y
	var tween = create_tween()
	# Animação momentânea de entrada do item, subindo e desacelerando
	tween.tween_property(self, "position:y", base_y - 24.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	is_floating = true


func _process(delta: float) -> void:
	if not is_floating:
		return
	float_offset += delta * 4.0
	position.y = (base_y - 16.0) + sin(float_offset) * 7.0 # Flutuação do objeto - BASE / OSCILAÇÃO / AMPLITUDE


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("heal"):
		var was_healed: bool = body.heal(value)
		if was_healed:
			queue_free()
