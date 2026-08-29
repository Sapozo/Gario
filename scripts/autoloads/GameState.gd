extends Node

signal coins_changed(new_total: int)
signal player_health_changed(current_hp: int, max_hp: int)
signal camera_shake_request(amount: float)

# SFXs & BMGs
@onready var coin: AudioStreamPlayer = $SFX/Coin
@onready var healing_orb: AudioStreamPlayer = $SFX/HealingOrb
@onready var victory: AudioStreamPlayer = $SFX/Victory
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var apex_sprint: AudioStreamPlayer = $BGMPlayer/ApexSprint
@onready var final_corridor_sprint: AudioStreamPlayer = $BGMPlayer/FinalCorridorSprint

var banked_coins: int = 0
var coins: int = 0
var level_start_coins: int
var level_coins: int = 0

func _ready() -> void:
	level_start_coins = coins


# CONTADOR DE COINS LOCAL DA FASE
func add_level_coins(amount: int) -> void:
	if amount > 0:
		level_coins += amount
		coins = banked_coins + level_coins
		coin.pitch_scale = randf_range(0.95, 1.05)
		coin.play()
		coins_changed.emit(coins)


# CONTADOR DE COINS GLOBAL DO JOGADOR
func add_coins(amount: int ) -> void:
	if amount > 0:
		coins += amount
		coin.pitch_scale = randf_range(0.95, 1.05)
		coin.play()
		coins_changed.emit(coins)


func bank_coins() -> void:
		banked_coins = coins
		level_start_coins = banked_coins
		level_coins = 0


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


# Tocador de BGM
func play_bgm(stream: AudioStream) -> void:
	if bgm_player.stream == stream and bgm_player.playing == true:
		return
	else:
		bgm_player.stream = stream
		bgm_player.play()


# Silenciador de BGM
func stop_bgm() -> void:
	bgm_player.stop()
