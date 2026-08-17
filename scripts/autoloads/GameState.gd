extends Node

signal coins_changed(new_total: int)

var coins: int = 0



func add_coins(amount: int):
	if amount > 0:
		coins += amount
		coins_changed.emit(coins)
