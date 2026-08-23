extends Area2D

signal collected(value: int)

@export var value:int = 1

var base_y: float
var float_offset: float
var is_floating: bool



func _ready() -> void:
	collected.connect(GameState.add_coins)
	base_y = position.y
	var tween = create_tween()
	# Animação momentânea de entrada do item, subindo e desacelerando
	tween.tween_property(self, "position:y", base_y - 24.0, 0.3 ).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	is_floating = true


func _process(delta: float) -> void:
	if not is_floating:
		return
	float_offset += delta * 4.0
	position.y = (base_y - 16.0) + sin(float_offset) * 7.0 # Flutuação do objeto - BASE / OSCILAÇÃO / AMPLITUDE


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		collected.emit(value)
		queue_free()
