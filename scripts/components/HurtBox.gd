extends Area2D
class_name HurtBox

signal hurt(damage: int, hit_position: Vector2)

func take_hit(amount: int = 1, hit_position: Vector2 = Vector2.ZERO) -> void:
	hurt.emit(amount, hit_position)
