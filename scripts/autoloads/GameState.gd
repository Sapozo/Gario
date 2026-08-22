extends Node

signal coins_changed(new_total: int)
signal player_health_changed(current_hp: int, max_hp: int)

var coins: int = 0



func add_coins(amount: int) -> void:
	if amount > 0:
		coins += amount
		coins_changed.emit(coins)


func update_player_health(current_hp: int, max_hp: int) -> void:
	player_health_changed.emit(current_hp, max_hp)
