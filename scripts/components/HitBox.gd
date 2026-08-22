extends Area2D
class_name HitBox

@export var damage: int = 1



func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		area.take_hit(damage, global_position) 
