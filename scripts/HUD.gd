extends CanvasLayer

# Referencia o node CoinLabel
@onready var coin_label: Label = $CoinDisplay/CoinLabel
# HEALTHBAR
@onready var health_bar: TextureProgressBar = $HealthBar




# Conecta o sinal em uma função
func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(GameState.coins)
	GameState.player_health_changed.connect(_on_player_health_changed)



# Atualiza o CoinLabel com o valor do sinal
func _on_coins_changed(new_total: int) -> void:
	coin_label.text = str(new_total)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp
