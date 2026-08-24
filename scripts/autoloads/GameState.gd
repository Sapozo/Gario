extends Node

signal coins_changed(new_total: int)
signal player_health_changed(current_hp: int, max_hp: int)
signal camera_shake_request(amount: float)

# SFX - Coin
@onready var coin: AudioStreamPlayer = $SFX/Coin


var coins: int = 0



# CONTADOR DE COINS GLOBAL DO JOGADOR
func add_coins(amount: int) -> void:
	if amount > 0:
		coins += amount
		coin.pitch_scale = randf_range(0.95, 1.05)
		coin.play()
		coins_changed.emit(coins)


# ATUALIZA HP NA HUD
func update_player_health(current_hp: int, max_hp: int) -> void:
	player_health_changed.emit(current_hp, max_hp)


# Camera Shake Effect
func request_camera_shake(amount: float) -> void:
	camera_shake_request.emit(amount)


# Hit-Stop Effect
func freeze_time(duration: float = 0.05 ) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
