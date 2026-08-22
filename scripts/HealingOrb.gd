extends Area2D

@export var value: int = 2



func _on_body_entered(body: Node2D) -> void:
	if body.has_method("heal"):
		var was_healed: bool = body.heal(value)
		if was_healed:
			queue_free()
