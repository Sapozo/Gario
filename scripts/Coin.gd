extends Area2D

signal collected(value: int)

@export var value:int = 1



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
			collected.emit(value)
			print('money!')
			queue_free()
