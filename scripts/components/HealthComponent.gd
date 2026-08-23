extends Node
class_name HealthComponent

signal health_changed(new_health: int)
signal died	

@export var max_health: int = 5

var current_health: int


# Início da cena
func _ready() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	if current_health > 0:
		print(owner.name, " tomou ", amount, " de dano! HP: ", current_health)
		_on_health_changed()
	else:
		_on_health_changed()
		_on_died()


func heal(amount: int) -> bool:
	if current_health >= max_health:
		return false
	else:
		current_health = min(max_health, current_health + amount)
		print(get_parent().name, " healou ", amount, " de vida! HP: ", current_health)
		_on_health_changed()
		return true
	
func _on_health_changed() -> void:
	health_changed.emit(current_health)


func _on_died() -> void:
	died.emit()
